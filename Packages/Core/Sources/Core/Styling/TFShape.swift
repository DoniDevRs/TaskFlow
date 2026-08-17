import CoreGraphics

/// Shape tokens per taskflow-styling-tokens.md: soft-cornered cards/rows and
/// the FAB follow the strict soft-corner rule; segmented controls/pickers are
/// fully rounded pills, matching the shipped prototype rather than the
/// original soft-corner brief.
public enum TFShape {
    public static let cardCornerRadius: CGFloat = 12
    public static let fabCornerRadius: CGFloat = 18
    public static let hairlineWidth: CGFloat = 1
    public static let priorityIndicatorWidth: CGFloat = 3
    public static let pillCornerRadius: CGFloat = 999
}
