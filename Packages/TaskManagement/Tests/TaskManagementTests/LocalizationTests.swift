import XCTest
@testable import TaskManagement

final class LocalizationTests: XCTestCase {
    func test_localizableCatalog_everyEntryHasEnglishAndPortugueseTranslations() throws {
        guard let url = TaskManagementResources.bundle.url(forResource: "Localizable", withExtension: "xcstrings") else {
            XCTFail("Localizable.xcstrings not found in TaskManagement's resource bundle")
            return
        }

        let data = try Data(contentsOf: url)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let strings = try XCTUnwrap(json?["strings"] as? [String: Any])
        XCTAssertFalse(strings.isEmpty)

        for (key, value) in strings {
            let entry = try XCTUnwrap(value as? [String: Any], "malformed entry for \(key)")
            let localizations = try XCTUnwrap(entry["localizations"] as? [String: Any], "\(key) has no localizations")
            XCTAssertNotNil(localizations["en"], "\(key) missing en translation")
            XCTAssertNotNil(localizations["pt-BR"], "\(key) missing pt-BR translation")
        }
    }
}
