import XCTest
@testable import Core

final class PasscodeHasherTests: XCTestCase {
    func test_hash_isDeterministic() {
        XCTAssertEqual(PasscodeHasher.hash("1234"), PasscodeHasher.hash("1234"))
    }

    func test_hash_differsForDifferentInput() {
        XCTAssertNotEqual(PasscodeHasher.hash("1234"), PasscodeHasher.hash("4321"))
    }

    func test_hash_doesNotReturnPlaintext() {
        let hashed = PasscodeHasher.hash("1234")
        XCTAssertNotEqual(hashed, Data("1234".utf8))
    }
}
