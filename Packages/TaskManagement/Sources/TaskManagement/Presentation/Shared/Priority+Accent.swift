import Core
import SwiftUI

extension Priority {
    /// terracotta (high) / amber (medium) / sage (low), per taskflow-styling-tokens.md.
    var accentColor: Color {
        switch self {
        case .high: TFColor.terracotta
        case .medium: TFColor.amber
        case .low: TFColor.sage
        }
    }

    /// A LocalizedStringKey, not String — Text(priority.rawValue.capitalized)
    /// would resolve to Text's verbatim (non-localizing) initializer since
    /// rawValue is a String, not a literal.
    var displayName: LocalizedStringKey {
        switch self {
        case .high: "High"
        case .medium: "Medium"
        case .low: "Low"
        }
    }

    /// A full phrase per case, not "\(displayName) priority" — concatenating
    /// translated fragments doesn't hold up across languages with different
    /// word order (e.g. adjective placement in pt-BR).
    var boardColumnTitle: LocalizedStringKey {
        switch self {
        case .high: "High priority"
        case .medium: "Medium priority"
        case .low: "Low priority"
        }
    }
}
