import XCTest
@testable import TaskManagement

final class FetchStatsUseCaseTests: XCTestCase {
    private var repository: MockTaskRepository!
    private let fixedNow = Date(timeIntervalSince1970: 1_700_000_000) // arbitrary fixed instant
    private let calendar = Calendar(identifier: .gregorian)

    override func setUp() {
        super.setUp()
        repository = MockTaskRepository()
    }

    private func makeSUT() -> FetchStatsUseCase {
        FetchStatsUseCase(repository: repository, clock: { self.fixedNow }, calendar: calendar)
    }

    func test_execute_withNoTasks_returnsZeroedStats() async throws {
        let sut = makeSUT()

        let stats = try await sut.execute()

        XCTAssertEqual(stats.completionRate, 0)
        XCTAssertEqual(stats.overdueCount, 0)
        XCTAssertEqual(stats.weeklyCompleted.count, 7)
        XCTAssertTrue(stats.weeklyCompleted.allSatisfy { $0.count == 0 })
    }

    func test_execute_computesCompletionRate() async throws {
        let tasks = [
            TodoItem(title: "1", isCompleted: true),
            TodoItem(title: "2", isCompleted: true),
            TodoItem(title: "3", isCompleted: false)
        ]
        tasks.forEach { repository.tasks[$0.id] = $0 }
        let sut = makeSUT()

        let stats = try await sut.execute()

        XCTAssertEqual(stats.completionRate, 2.0 / 3.0, accuracy: 0.0001)
    }

    func test_execute_countsOverdueIncompleteTasksOnly() async throws {
        let overdue = TodoItem(title: "Overdue", dueDate: fixedNow.addingTimeInterval(-86_400), isCompleted: false)
        let overdueButDone = TodoItem(title: "Done late", dueDate: fixedNow.addingTimeInterval(-86_400), isCompleted: true)
        let notYetDue = TodoItem(title: "Future", dueDate: fixedNow.addingTimeInterval(86_400), isCompleted: false)
        [overdue, overdueButDone, notYetDue].forEach { repository.tasks[$0.id] = $0 }
        let sut = makeSUT()

        let stats = try await sut.execute()

        XCTAssertEqual(stats.overdueCount, 1)
    }

    func test_execute_bucketsCompletedTasksByDayOverLastSevenDays() async throws {
        let today = calendar.startOfDay(for: fixedNow)
        let completedToday = TodoItem(title: "Today", isCompleted: true, lastModified: today.addingTimeInterval(3600))
        let completedThreeDaysAgo = TodoItem(
            title: "Three days ago",
            isCompleted: true,
            lastModified: calendar.date(byAdding: .day, value: -3, to: today)!.addingTimeInterval(3600)
        )
        let completedTooLongAgo = TodoItem(
            title: "Ten days ago",
            isCompleted: true,
            lastModified: calendar.date(byAdding: .day, value: -10, to: today)!
        )
        [completedToday, completedThreeDaysAgo, completedTooLongAgo].forEach { repository.tasks[$0.id] = $0 }
        let sut = makeSUT()

        let stats = try await sut.execute()

        XCTAssertEqual(stats.weeklyCompleted.count, 7)
        XCTAssertEqual(stats.weeklyCompleted.last?.day, today)
        XCTAssertEqual(stats.weeklyCompleted.last?.count, 1)
        let totalBucketed = stats.weeklyCompleted.reduce(0) { $0 + $1.count }
        XCTAssertEqual(totalBucketed, 2, "the 10-day-old completion should fall outside the 7-day window")
    }

    func test_execute_whenRepositoryFails_propagatesError() async {
        repository.fetchAllError = TestError.stub
        let sut = makeSUT()

        do {
            _ = try await sut.execute()
            XCTFail("Expected repository error to propagate")
        } catch TestError.stub {
            // expected
        } catch {
            XCTFail("Expected TestError.stub, got \(error)")
        }
    }
}
