import Core
import SwiftUI

/// Selection/add actions are exposed as callbacks rather than embedding
/// NavigationLink/sheet state — navigation is owned by AppCoordinator's
/// UIKit push, per plan.md §5 (wired up in T9).
public struct TaskListView: View {
    private enum Layout: String, CaseIterable, Identifiable {
        case list = "List"
        case board = "Board"
        var id: String { rawValue }
    }

    @StateObject private var viewModel: TaskListViewModel
    @State private var layout: Layout = .list

    private let onSelectTask: (TodoItem) -> Void
    private let onAddTask: () -> Void

    public init(
        viewModel: @autoclosure @escaping () -> TaskListViewModel,
        onSelectTask: @escaping (TodoItem) -> Void,
        onAddTask: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.onSelectTask = onSelectTask
        self.onAddTask = onAddTask
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TFColor.background.ignoresSafeArea()

            VStack(spacing: TFSpacing.md) {
                Picker("Layout", selection: $layout) {
                    ForEach(Layout.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, TFSpacing.md)

                SearchField(query: $viewModel.searchQuery)
                    .padding(.horizontal, TFSpacing.md)

                Group {
                    switch layout {
                    case .list: listContent
                    case .board: boardContent
                    }
                }
            }
            .padding(.top, TFSpacing.md)

            FloatingActionButton(action: onAddTask)
                .padding(TFSpacing.lg)
        }
        .task { await viewModel.loadTasks() }
    }

    private var listContent: some View {
        ScrollView {
            LazyVStack(spacing: TFSpacing.sm) {
                ForEach(viewModel.tasks) { task in
                    TaskRowView(task: task) {
                        Task { await viewModel.toggleCompletion(id: task.id) }
                    }
                    .onTapGesture { onSelectTask(task) }
                }
            }
            .padding(.horizontal, TFSpacing.md)
            .padding(.bottom, TFSpacing.xl)
        }
    }

    private var boardContent: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: TFSpacing.md) {
                ForEach(Priority.allCases.reversed(), id: \.self) { priority in
                    boardColumn(for: priority)
                }
            }
            .padding(.horizontal, TFSpacing.md)
            .padding(.bottom, TFSpacing.xl)
        }
    }

    private func boardColumn(for priority: Priority) -> some View {
        let columnTasks = viewModel.tasks.filter { $0.priority == priority }
        return VStack(alignment: .leading, spacing: TFSpacing.sm) {
            SectionLabel(title: "\(priority.rawValue) priority")
            ForEach(columnTasks) { task in
                TaskRowView(task: task) {
                    Task { await viewModel.toggleCompletion(id: task.id) }
                }
                .onTapGesture { onSelectTask(task) }
            }
        }
        .frame(width: 260, alignment: .leading)
    }
}
