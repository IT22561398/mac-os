// WellbeingTrendChartView.swift
// NurseryConnect — Setting Manager (macOS)
// Swift Charts — LineMark + AreaMark with gradient fill (14-day rolling)

import SwiftUI
import Charts

struct WellbeingTrendChartView: View {
    let data: [(date: Date, score: Double)]
    
    var body: some View {
        Chart {
            // Area fill with gradient
            ForEach(data.indices, id: \.self) { index in
                AreaMark(
                    x: .value(ManagerText.Charts.dateAxisLabel, data[index].date),
                    y: .value(ManagerText.Charts.scoreAxisLabel, data[index].score)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.ncPrimary.opacity(0.3), .ncPrimary.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }
            
            // Line on top
            ForEach(data.indices, id: \.self) { index in
                LineMark(
                    x: .value(ManagerText.Charts.dateAxisLabel, data[index].date),
                    y: .value(ManagerText.Charts.scoreAxisLabel, data[index].score)
                )
                .foregroundStyle(.ncPrimary)
                .lineStyle(StrokeStyle(lineWidth: 2.5))
                .interpolationMethod(.catmullRom)
                .symbol {
                    Circle()
                        .fill(.ncPrimary)
                        .frame(width: 6, height: 6)
                }
            }
            
            // Threshold lines
            RuleMark(y: .value(ManagerText.Wellbeing.goodThreshold, ManagerConstants.wellbeingScoreHighThreshold))
                .foregroundStyle(.ncSuccess.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .annotation(position: .trailing, alignment: .leading) {
                    Text(ManagerText.Wellbeing.goodThreshold)
                        .font(.system(size: 9))
                        .foregroundStyle(.ncSuccess)
                }
            
            RuleMark(y: .value(ManagerText.Wellbeing.alertThreshold, ManagerConstants.wellbeingScoreLowThreshold))
                .foregroundStyle(.ncSecondary.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .annotation(position: .trailing, alignment: .leading) {
                    Text(ManagerText.Wellbeing.alertThreshold)
                        .font(.system(size: 9))
                        .foregroundStyle(.ncSecondary)
                }
            
            // Annotation on lowest point
            if let minPoint = data.min(by: { $0.score < $1.score }) {
                PointMark(
                    x: .value(ManagerText.Charts.dateAxisLabel, minPoint.date),
                    y: .value(ManagerText.Charts.scoreAxisLabel, minPoint.score)
                )
                .foregroundStyle(.ncSecondary)
                .symbolSize(60)
                .annotation(position: .top) {
                    Text(ManagerText.Wellbeing.reviewRecommended)
                        .font(.system(size: 8, weight: .medium))
                        .foregroundStyle(.ncSecondary)
                        .padding(2)
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .fill(.ncSecondary.opacity(0.1))
                        )
                }
            }
        }
        .chartYScale(domain: 0...100)
        .chartYAxis {
            AxisMarks(values: [0, 25, 50, 75, 100]) { value in
                AxisValueLabel()
                    .font(.caption2)
                AxisGridLine()
                    .foregroundStyle(.gray.opacity(0.2))
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 2)) { _ in
                AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                    .font(.caption2)
                AxisGridLine()
                    .foregroundStyle(.gray.opacity(0.1))
            }
        }
    }
}
