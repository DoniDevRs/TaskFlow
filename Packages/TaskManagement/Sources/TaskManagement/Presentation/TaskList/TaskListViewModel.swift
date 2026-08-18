import Combine
import Foundation

@MainActor
public final class TaskListViewModel: ObservableObject {
    @Published public private(set) var tasks: [TodoItem] = []
    @Published public var searchQuery: String = ""
    @Published public var filter = TaskFilter()
    @Published public private(set) var isLoading = false
    @Published public var errorMessage: String?

    private let searchTasksUseCase: SearchTasksUseCase
    private let toggleTaskCompletionUseCase: ToggleTaskCompletionUseCase
    private let deleteTaskUseCase: DeleteTaskUseCase
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?

    public init(
        searchTasksUseCase: SearchTasksUseCase,
        toggleTaskCompletionUseCase: ToggleTaskCompletionUseCase,
        deleteTaskUseCase: DeleteTaskUseCase
    ) {
        self.searchTasksUseCase = searchTasksUseCase
        self.toggleTaskCompletionUseCase = toggleTaskCompletionUseCase
        self.deleteTaskUseCase = deleteTaskUseCase

        // Combine debounce per plan.md §4 — the one deliberate Combine use
        // site in an otherwise async/await codebase.
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.runSearch(query: query)
            }
            .store(in: &cancellables)
    }

    public func loadTasks() async {
        await performSearch(query: searchQuery)
    }

    public func toggleCompletion(id: UUID) async {
        do {
            let updated = try await toggleTaskCompletionUseCase.execute(id: id)
            if let index = tasks.firstIndex(where: { $0.id == id }) {
                tasks[index] = updated
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func deleteTask(id: UUID) async {
        do {
            try await deleteTaskUseCase.execute(id: id)
            tasks.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func runSearch(query: String) {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            await self?.performSearch(query: query)
        }
    }

    private func performSearch(query: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            tasks = try await searchTasksUseCase.execute(query: query, filter: filter)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
