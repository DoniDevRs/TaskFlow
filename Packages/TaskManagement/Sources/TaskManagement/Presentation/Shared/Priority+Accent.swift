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
}
