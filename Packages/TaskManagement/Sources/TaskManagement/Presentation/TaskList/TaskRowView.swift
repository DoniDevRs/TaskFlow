import Core
import SwiftUI

struct TaskRowView: View {
    let task: TodoItem
    let onToggleCompletion: () -> Void

    var body: some View {
        HStack(spacing: TFSpacing.sm) {
            Rectangle()
                .fill(task.priority.accentColor)
                .frame(width: TFShape.priorityIndicatorWidth)
                .clipShape(RoundedRectangle(cornerRadius: TFShape.priorityIndicatorWidth / 2))

            Button(action: onToggleCompletion) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(task.isCompleted ? TFColor.sage : TFColor.ink.opacity(0.4))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(task.isCompleted ? "Mark incomplete" : "Mark complete")
            .accessibilityIdentifier("taskRow.toggleCompletion.\(task.id)")

            VStack(alignment: .leading, spacing: TFSpacing.xs) {
                Text(task.title)
                    .font(TFTypography.taskTitle())
                    .foregroundStyle(TFColor.ink)
                    .strikethrough(task.isCompleted)
                    .lineLimit(2)

                if let dueDate = task.dueDate {
                    Text(dueDate, style: .date)
                        .font(TFTypography.label())
                        .foregroundStyle(TFColor.ink.opacity(0.6))
                }
            }

            Spacer(minLength: TFSpacing.sm)

            if task.syncStatus == .conflict {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(TFColor.terracotta)
                    .accessibilityLabel("Sync conflict")
            }
        }
        .padding(TFSpacing.md)
        .background(TFColor.background)
        .clipShape(RoundedRectangle(cornerRadius: TFShape.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: TFShape.cardCornerRadius)
                .stroke(TFColor.ink.opacity(0.1), lineWidth: TFShape.hairlineWidth)
        )
        .contentShape(Rectangle())
    }
}
