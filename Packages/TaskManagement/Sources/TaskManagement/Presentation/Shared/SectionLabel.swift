import Core
import SwiftUI

/// Small-caps, tracked section headers — "UPCOMING", "COMPLETED", "SUBTASKS", etc.
///
/// title is LocalizedStringKey, not String — a String parameter would erase
/// whether the caller passed a literal, silently falling back to Text's
/// verbatim (non-localizing) initializer for every single call site.
/// .textCase(.uppercase) applies the small-caps transform after
/// localization resolves, rather than uppercasing the raw English key.
struct SectionLabel: View {
    let title: LocalizedStringKey

    var body: some View {
        Text(title)
            .textCase(.uppercase)
            .tfSectionLabelStyle()
            .foregroundStyle(TFColor.ink.opacity(0.6))
    }
}
