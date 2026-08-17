import SwiftUI

/// Palette transcribed from taskflow-styling-tokens.md.
public enum TFColor {
    public static let background = Color(hex: "#F7F4EE")
    public static let ink = Color(hex: "#1C1B19")
    public static let terracotta = Color(hex: "#C15F3C")
    public static let sage = Color(hex: "#7C8B6F")

    /// Medium-priority accent — pixel-sampled approximation, not yet
    /// confirmed against the prototype's CSS export. Do not treat as final;
    /// see taskflow-styling-tokens.md "Open item before closing T4".
    public static let amber = Color(hex: "#B98D4B")
}
