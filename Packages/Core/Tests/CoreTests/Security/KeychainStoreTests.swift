import XCTest
@testable import Core

final class KeychainStoreTests: XCTestCase {
    private var sut: KeychainStore!
    // Unique service per test run so parallel/repeated runs don't collide.
    private let service = "com.donidevrs.TaskFlow.tests.\(UUID().uuidString)"
    private let key = "test-key"

    override func setUp() {
        super.setUp()
        sut = KeychainStore(service: service)
    }

    override func tearDown() {
        try? sut.delete(forKey: key)
        sut = nil
        super.tearDown()
    }

    func test_get_whenNothingStored_returnsNil() throws {
        XCTAssertNil(try sut.get(forKey: key))
    }

    func test_setThenGet_returnsStoredData() throws {
        let data = Data("secret".utf8)

        try sut.set(data, forKey: key)

        XCTAssertEqual(try sut.get(forKey: key), data)
    }

    func test_set_overwritesExistingValue() throws {
        try sut.set(Data("first".utf8), forKey: key)
        try sut.set(Data("second".utf8), forKey: key)

        XCTAssertEqual(try sut.get(forKey: key), Data("second".utf8))
    }

    func test_delete_removesStoredValue() throws {
        try sut.set(Data("secret".utf8), forKey: key)

        try sut.delete(forKey: key)

        XCTAssertNil(try sut.get(forKey: key))
    }

    func test_delete_whenNothingStored_doesNotThrow() {
        XCTAssertNoThrow(try sut.delete(forKey: key))
    }
}
