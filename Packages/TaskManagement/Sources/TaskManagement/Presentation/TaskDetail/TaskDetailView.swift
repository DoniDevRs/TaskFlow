import Core
import SwiftUI

public struct TaskDetailView: View {
    @StateObject private var viewModel: TaskDetailViewModel
    private let onEdit: (TodoItem) -> Void

    public init(
        viewModel: @autoclosure @escaping () -> TaskDetailViewModel,
        onEdit: @escaping (TodoItem) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.onEdit = onEdit
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TFSpacing.lg) {
                if viewModel.hasConflict {
                    conflictBanner
                }

                header

                if let description = viewModel.task.description, !description.isEmpty {
                    Text(description)
                        .font(TFTypography.body())
                        .foregroundStyle(TFColor.ink.opacity(0.8))
                }

                metadataRow

                if !viewModel.task.subtasks.isEmpty {
                    subtasksSection
                }

                syncSection
            }
            .padding(TFSpacing.md)
        }
        .background(TFColor.background.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { onEdit(viewModel.task) }
            }
        }
    }

    private var conflictBanner: some View {
        HStack(spacing: TFSpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(TFColor.terracotta)
            Text("This task changed on another device too. Your local version was kept.")
                .font(TFTypography.label())
                .foregroundStyle(TFColor.ink)
        }
        .padding(TFSpacing.md)
        .background(TFColor.terracotta.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: TFShape.cardCornerRadius))
    }

    private var header: some View {
        HStack(alignment: .top, spacing: TFSpacing.sm) {
            Rectangle()
                .fill(viewModel.task.priority.accentColor)
                .frame(width: TFShape.priorityIndicatorWidth)

            VStack(alignment: .leading, spacing: TFSpacing.xs) {
                Text(viewModel.task.title)
                    .font(TFTypography.screenTitle())
                    .foregroundStyle(TFColor.ink)
                    .strikethrough(viewModel.task.isCompleted)
            }

            Spacer()

            Button {
                Task { await viewModel.toggleCompletion() }
            } label: {
                Image(systemName: viewModel.task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 28))
                    .foregroundStyle(viewModel.task.isCompleted ? TFColor.sage : TFColor.ink.opacity(0.4))
            }
            .buttonStyle(.plain)
        }
    }

    private var metadataRow: some View {
        HStack(spacing: TFSpacing.md) {
            if let dueDate = viewModel.task.dueDate {
                Label {
                    Text(dueDate, style: .date)
                } icon: {
                    Image(systemName: "calendar")
                }
                .font(TFTypography.label())
                .foregroundStyle(TFColor.ink.opacity(0.7))
            }

            ForEach(viewModel.task.tags, id: \.self) { tag in
                Text(tag)
                    .font(TFTypography.label())
                    .padding(.horizontal, TFSpacing.sm)
                    .padding(.vertical, TFSpacing.xs)
                    .background(TFColor.ink.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: TFShape.pillCornerRadius))
            }
        }
    }

    private var subtasksSection: some View {
        VStack(alignment: .leading, spacing: TFSpacing.sm) {
            SectionLabel(title: "Subtasks")
            ForEach(viewModel.task.subtasks) { subtask in
                Button {
                    Task { await viewModel.toggleSubtask(id: subtask.id) }
                } label: {
                    HStack(spacing: TFSpacing.sm) {
                        Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(subtask.isCompleted ? TFColor.sage : TFColor.ink.opacity(0.4))
                        Text(subtask.title)
                            .font(TFTypography.body())
                            .foregroundStyle(TFColor.ink)
                            .strikethrough(subtask.isCompleted)
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var syncSection: some View {
        VStack(alignment: .leading, spacing: TFSpacing.sm) {
            SectionLabel(title: "Sync")
            Text(syncStatusDescription)
                .font(TFTypography.label())
                .foregroundStyle(TFColor.ink.opacity(0.6))
        }
    }

    private var syncStatusDescription: String {
        switch viewModel.task.syncStatus {
        case .synced: "Synced"
        case .pending: "Waiting to sync"
        case .conflict: "Conflict — local version kept"
        }
    }
}
