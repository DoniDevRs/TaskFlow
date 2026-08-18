import Charts
import Core
import SwiftUI

public struct StatsView: View {
    @StateObject private var viewModel: StatsViewModel

    public init(viewModel: @autoclosure @escaping () -> StatsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TFSpacing.lg) {
                if let stats = viewModel.stats {
                    completionRing(stats)
                    overdueCallout(stats)
                    weeklyChart(stats)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, TFSpacing.xl)
                }
            }
            .padding(TFSpacing.md)
        }
        .background(TFColor.background.ignoresSafeArea())
        .task { await viewModel.loadStats() }
    }

    private func completionRing(_ stats: TaskStats) -> some View {
        VStack(alignment: .leading, spacing: TFSpacing.sm) {
            SectionLabel(title: "Completion rate")
            ZStack {
                Circle()
                    .stroke(TFColor.ink.opacity(0.1), lineWidth: 12)
                Circle()
                    .trim(from: 0, to: stats.completionRate)
                    .stroke(TFColor.sage, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int((stats.completionRate * 100).rounded()))%")
                    .font(TFTypography.screenTitle())
                    .foregroundStyle(TFColor.ink)
                    .accessibilityIdentifier("stats.completionRateLabel")
            }
            .frame(width: 140, height: 140)
        }
    }

    private func overdueCallout(_ stats: TaskStats) -> some View {
        HStack(spacing: TFSpacing.sm) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(TFColor.terracotta)
            Text("\(stats.overdueCount) overdue")
                .font(TFTypography.body())
                .foregroundStyle(TFColor.ink)
        }
    }

    private func weeklyChart(_ stats: TaskStats) -> some View {
        VStack(alignment: .leading, spacing: TFSpacing.sm) {
            SectionLabel(title: "Completed this week")
            Chart(stats.weeklyCompleted) { day in
                BarMark(
                    x: .value("Day", day.day, unit: .day),
                    y: .value("Completed", day.count)
                )
                .foregroundStyle(TFColor.terracotta)
            }
            .frame(height: 160)
        }
    }
}
