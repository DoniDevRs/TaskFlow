import XCTest
import SwiftUI
@testable import Core

final class StylingTests: XCTestCase {
    func test_spacingScale_isMonotonicallyIncreasing() {
        let scale = [TFSpacing.xs, TFSpacing.sm, TFSpacing.md, TFSpacing.lg, TFSpacing.xl]
        XCTAssertEqual(scale, scale.sorted())
        XCTAssertEqual(Set(scale).count, scale.count, "spacing steps should be distinct")
    }

    func test_colorHexInit_matchesUIColorComponents() {
        let color = UIColor(Color(hex: "#C15F3C"))
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        XCTAssertEqual(Double(red), Double(0xC1) / 255, accuracy: 0.01)
        XCTAssertEqual(Double(green), Double(0x5F) / 255, accuracy: 0.01)
        XCTAssertEqual(Double(blue), Double(0x3C) / 255, accuracy: 0.01)
    }
}
