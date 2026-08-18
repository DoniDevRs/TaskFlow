import Core
import SwiftUI

/// Squircle FAB, terracotta fill — per taskflow-styling-tokens.md.
struct FloatingActionButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(TFColor.terracotta)
                .clipShape(RoundedRectangle(cornerRadius: TFShape.fabCornerRadius))
                .shadow(color: TFColor.ink.opacity(0.25), radius: 8, y: 4)
        }
        .accessibilityLabel("Add task")
    }
}
