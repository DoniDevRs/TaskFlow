import Combine
import Foundation

@MainActor
public final class StatsViewModel: ObservableObject {
    @Published public private(set) var stats: TaskStats?
    @Published public var errorMessage: String?

    private let fetchStatsUseCase: FetchStatsUseCase

    public init(fetchStatsUseCase: FetchStatsUseCase) {
        self.fetchStatsUseCase = fetchStatsUseCase
    }

    public func loadStats() async {
        do {
            stats = try await fetchStatsUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
