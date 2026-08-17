import Foundation

public final class SearchTasksUseCase {
    private let repository: TaskRepository

    public init(repository: TaskRepository) {
        self.repository = repository
    }

    public func execute(query: String = "", filter: TaskFilter = TaskFilter()) async throws -> [TodoItem] {
        let tasks = try await repository.fetchAll()
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return tasks.filter { task in
            matchesQuery(task, trimmedQuery) && matchesFilter(task, filter)
        }
    }

    private func matchesQuery(_ task: TodoItem, _ query: String) -> Bool {
        guard !query.isEmpty else { return true }
        return task.title.lowercased().contains(query)
            || (task.description?.lowercased().contains(query) ?? false)
            || task.tags.contains { $0.lowercased().contains(query) }
    }

    private func matchesFilter(_ task: TodoItem, _ filter: TaskFilter) -> Bool {
        if let projectID = filter.projectID, task.projectID != projectID { return false }
        if let priority = filter.priority, task.priority != priority { return false }
        if let tag = filter.tag, !task.tags.contains(tag) { return false }
        if let isCompleted = filter.isCompleted, task.isCompleted != isCompleted { return false }
        if let dueBefore = filter.dueBefore {
            guard let dueDate = task.dueDate, dueDate <= dueBefore else { return false }
        }
        return true
    }
}
