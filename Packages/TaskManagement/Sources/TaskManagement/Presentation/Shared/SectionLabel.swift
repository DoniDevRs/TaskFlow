import Core
import SwiftUI

/// Small-caps, tracked section headers — "UPCOMING", "COMPLETED", "SUBTASKS", etc.
struct SectionLabel: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .tfSectionLabelStyle()
            .foregroundStyle(TFColor.ink.opacity(0.6))
    }
}
