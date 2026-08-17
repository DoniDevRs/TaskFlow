import XCTest
@testable import Core

private protocol Greeting {
    func greet() -> String
}

private final class EnglishGreeting: Greeting {
    func greet() -> String { "hello" }
}

final class ContainerTests: XCTestCase {
    func test_resolve_transientScope_returnsNewInstanceEachTime() {
        let container = Container()
        container.register(Greeting.self, scope: .transient) { EnglishGreeting() as Greeting }

        let first = container.resolve(Greeting.self) as! EnglishGreeting
        let second = container.resolve(Greeting.self) as! EnglishGreeting

        XCTAssertFalse(first === second)
    }

    func test_resolve_singletonScope_returnsSameInstance() {
        let container = Container()
        container.register(Greeting.self, scope: .singleton) { EnglishGreeting() as Greeting }

        let first = container.resolve(Greeting.self) as! EnglishGreeting
        let second = container.resolve(Greeting.self) as! EnglishGreeting

        XCTAssertTrue(first === second)
    }

    func test_resolve_returnsRegisteredBehavior() {
        let container = Container()
        container.register(Greeting.self) { EnglishGreeting() as Greeting }

        XCTAssertEqual(container.resolve(Greeting.self).greet(), "hello")
    }
}
