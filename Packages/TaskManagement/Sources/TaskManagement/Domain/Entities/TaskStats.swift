import Foundation

public struct TaskStats: Equatable {
    public struct DayCount: Equatable, Identifiable {
        public let day: Date
        public let count: Int
        public var id: Date { day }

        public init(day: Date, count: Int) {
            self.day = day
            self.count = count
        }
    }

    /// 0...1; 0 when there are no tasks.
    public let completionRate: Double
    public let overdueCount: Int
    /// Last 7 days, oldest first, keyed by day start in the calendar used to compute it.
    public let weeklyCompleted: [DayCount]

    public init(completionRate: Double, overdueCount: Int, weeklyCompleted: [DayCount]) {
        self.completionRate = completionRate
        self.overdueCount = overdueCount
        self.weeklyCompleted = weeklyCompleted
    }
}
