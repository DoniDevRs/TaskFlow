import Core
import SwiftUI

public struct ProjectListView: View {
    @StateObject private var viewModel: ProjectListViewModel
    @State private var isPresentingAddProject = false
    @State private var newProjectName = ""

    private let onSelectProject: (Project) -> Void

    public init(
        viewModel: @autoclosure @escaping () -> ProjectListViewModel,
        onSelectProject: @escaping (Project) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.onSelectProject = onSelectProject
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TFColor.background.ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: TFSpacing.sm) {
                    ForEach(viewModel.projects) { project in
                        ProjectRowView(
                            project: project,
                            taskCount: viewModel.taskCounts[project.id] ?? 0,
                            progress: viewModel.completionProgress[project.id] ?? 0
                        )
                        .onTapGesture { onSelectProject(project) }
                    }
                }
                .padding(TFSpacing.md)
                .padding(.bottom, TFSpacing.xl)
            }

            FloatingActionButton { isPresentingAddProject = true }
                .padding(TFSpacing.lg)
        }
        .task { await viewModel.loadProjects() }
        .sheet(isPresented: $isPresentingAddProject) {
            addProjectSheet
        }
    }

    private var addProjectSheet: some View {
        NavigationStack {
            Form {
                TextField("Project name", text: $newProjectName)
                    .accessibilityIdentifier("addProject.nameField")
            }
            .navigationTitle("New Project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        newProjectName = ""
                        isPresentingAddProject = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        Task {
                            await viewModel.createProject(name: newProjectName, colorTag: "terracotta")
                            newProjectName = ""
                            isPresentingAddProject = false
                        }
                    }
                    .disabled(newProjectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier("addProject.save")
                }
            }
        }
    }
}
