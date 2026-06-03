// EYFSCoverageBarChartView.swift
// NurseryConnect — Setting Manager (macOS)
// Swift Charts — BarMark for EYFS learning area coverage

import SwiftUI
import Charts

struct EYFSCoverageBarChartView: View {
    let data: [(area: EYFSArea, count: Int)]
    
    var body: some View {
        Chart(data, id: \.area) { item in
            BarMark(
                x: .value(ManagerText.Charts.eyfsAreaAxisLabel, item.area.shortName),
                y: .value(ManagerText.Charts.entriesAxisLabel, item.count)
            )
            .foregroundStyle(barColor(count: item.count))
            .cornerRadius(6)
            .annotation(position: .top) {
                Text("\(item.count)")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel()
                    .font(.caption2)
                AxisGridLine()
                    .foregroundStyle(.gray.opacity(0.15))
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .font(.caption)
            }
        }
    }
    
    private func barColor(count: Int) -> Color {
        switch count {
        case 0: return .ncSecondary.opacity(0.6)
        case 1...2: return .ncWarning
        case 3...5: return .ncPrimary
        default: return .ncSuccess
        }
    }
}
