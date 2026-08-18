import Combine
import Foundation

@MainActor
public final class ProjectListViewModel: ObservableObject {
    @Published public private(set) var projects: [Project] = []
    @Published public private(set) var taskCounts: [UUID: Int] = [:]
    @Published public private(set) var completionProgress: [UUID: Double] = [:]
    @Published public var errorMessage: String?

    private let projectRepository: ProjectRepository
    private let taskRepository: TaskRepository
    private let createProjectUseCase: CreateProjectUseCase

    public init(
        projectRepository: ProjectRepository,
        taskRepository: TaskRepository,
        createProjectUseCase: CreateProjectUseCase
    ) {
        self.projectRepository = projectRepository
        self.taskRepository = taskRepository
        self.createProjectUseCase = createProjectUseCase
    }

    public func loadProjects() async {
        do {
            async let fetchedProjects = projectRepository.fetchAll()
            async let fetchedTasks = taskRepository.fetchAll()
            let (loadedProjects, loadedTasks) = try await (fetchedProjects, fetchedTasks)

            var counts: [UUID: Int] = [:]
            var progress: [UUID: Double] = [:]
            for project in loadedProjects {
                let projectTasks = loadedTasks.filter { $0.projectID == project.id }
                counts[project.id] = projectTasks.count
                let completed = projectTasks.filter(\.isCompleted).count
                progress[project.id] = projectTasks.isEmpty ? 0 : Double(completed) / Double(projectTasks.count)
            }

            projects = loadedProjects
            taskCounts = counts
            completionProgress = progress
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func createProject(name: String, colorTag: String) async {
        do {
            _ = try await createProjectUseCase.execute(name: name, colorTag: colorTag)
            await loadProjects()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
