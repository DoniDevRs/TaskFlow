import Core
import SwiftUI

struct SearchField: View {
    @Binding var query: String

    var body: some View {
        HStack(spacing: TFSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(TFColor.ink.opacity(0.5))
            TextField("Search tasks", text: $query)
                .font(TFTypography.body())
                .accessibilityIdentifier("taskList.searchField")
            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(TFColor.ink.opacity(0.4))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, TFSpacing.md)
        .padding(.vertical, TFSpacing.sm)
        .background(TFColor.ink.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: TFShape.pillCornerRadius))
    }
}
