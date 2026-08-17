import SwiftUI

/// Serif (New York, via `.design: .serif`) for display; grotesk (SF Pro, via
/// `.design: .default`) for UI — per taskflow-styling-tokens.md.
public enum TFTypography {
    public static func screenTitle() -> Font { .system(size: 28, weight: .semibold, design: .serif) }
    public static func projectName() -> Font { .system(size: 20, weight: .semibold, design: .serif) }
    public static func taskTitle() -> Font { .system(size: 17, weight: .medium, design: .serif) }

    public static func body() -> Font { .system(size: 15, weight: .regular, design: .default) }
    public static func label() -> Font { .system(size: 13, weight: .medium, design: .default) }
    public static func button() -> Font { .system(size: 15, weight: .semibold, design: .default) }
    public static func sectionLabel() -> Font { .system(size: 11, weight: .semibold, design: .default).smallCaps() }
}

extension View {
    /// Section labels ("UPCOMING", "COMPLETED", ...) per styling-tokens.md.
    public func tfSectionLabelStyle() -> some View {
        font(TFTypography.sectionLabel()).tracking(1.2)
    }
}
