import Core
import SwiftUI

struct ProjectRowView: View {
    let project: Project
    let taskCount: Int
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: TFSpacing.sm) {
            HStack(spacing: TFSpacing.sm) {
                Circle()
                    .fill(accentColor)
                    .frame(width: 12, height: 12)
                Text(project.name)
                    .font(TFTypography.projectName())
                    .foregroundStyle(TFColor.ink)
                Spacer()
                Text("\(taskCount)")
                    .font(TFTypography.label())
                    .foregroundStyle(TFColor.ink.opacity(0.6))
            }

            ProgressView(value: progress)
                .tint(accentColor)
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

    private var accentColor: Color {
        switch project.colorTag {
        case "terracotta": TFColor.terracotta
        case "sage": TFColor.sage
        case "amber": TFColor.amber
        default: TFColor.ink
        }
    }
}
