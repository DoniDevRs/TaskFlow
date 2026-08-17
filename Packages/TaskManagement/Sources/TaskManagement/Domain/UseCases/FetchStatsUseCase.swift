import Foundation

public final class FetchStatsUseCase {
    private let repository: TaskRepository
    private let clock: () -> Date
    private let calendar: Calendar

    public init(
        repository: TaskRepository,
        clock: @escaping () -> Date = Date.init,
        calendar: Calendar = .current
    ) {
        self.repository = repository
        self.clock = clock
        self.calendar = calendar
    }

    public func execute() async throws -> TaskStats {
        let tasks = try await repository.fetchAll()
        let now = clock()

        let completedTasks = tasks.filter(\.isCompleted)
        let completionRate = tasks.isEmpty ? 0 : Double(completedTasks.count) / Double(tasks.count)
        let overdueCount = tasks.filter { task in
            guard !task.isCompleted, let dueDate = task.dueDate else { return false }
            return dueDate < now
        }.count

        return TaskStats(
            completionRate: completionRate,
            overdueCount: overdueCount,
            weeklyCompleted: weeklyCompletedCounts(completedTasks: completedTasks, referenceDate: now)
        )
    }

    /// Uses lastModified as a completion-date proxy — the domain model has
    /// no dedicated completedAt field. Editing a task after completing it
    /// will shift which day it's bucketed into.
    private func weeklyCompletedCounts(completedTasks: [TodoItem], referenceDate: Date) -> [TaskStats.DayCount] {
        let today = calendar.startOfDay(for: referenceDate)
        let days = (0..<7)
            .compactMap { offset in calendar.date(byAdding: .day, value: -offset, to: today) }
            .reversed()

        return days.map { day in
            let count = completedTasks.filter { calendar.isDate($0.lastModified, inSameDayAs: day) }.count
            return TaskStats.DayCount(day: day, count: count)
        }
    }
}
