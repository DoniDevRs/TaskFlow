import XCTest
@testable import TaskManagement

@MainActor
final class StatsViewModelTests: XCTestCase {
    func test_loadStats_populatesStatsFromUseCase() async {
        let repository = MockTaskRepository()
        let task = TodoItem(title: "Done", isCompleted: true)
        repository.tasks[task.id] = task
        let sut = StatsViewModel(fetchStatsUseCase: FetchStatsUseCase(repository: repository))

        await sut.loadStats()

        XCTAssertEqual(sut.stats?.completionRate, 1.0)
    }

    func test_loadStats_whenRepositoryFails_setsErrorMessage() async {
        let repository = MockTaskRepository()
        repository.fetchAllError = TestError.stub
        let sut = StatsViewModel(fetchStatsUseCase: FetchStatsUseCase(repository: repository))

        await sut.loadStats()

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertNil(sut.stats)
    }
}
