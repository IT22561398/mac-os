// MoodDistributionChartView.swift
// NurseryConnect — Setting Manager (macOS)
// Swift Charts — SectorMark (pie chart) for mood distribution

import SwiftUI
import Charts

struct MoodDistributionChartView: View {
    let data: [(mood: MoodRating, count: Int)]
    
    var body: some View {
        if data.isEmpty || data.allSatisfy({ $0.count == 0 }) {
            VStack(spacing: 8) {
                Image(systemName: "chart.pie")
                    .font(.title)
                    .foregroundStyle(.tertiary)
                Text(ManagerText.Charts.noMoodData)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            HStack(spacing: 20) {
                Chart(data, id: \.mood) { item in
                    SectorMark(
                        angle: .value(ManagerText.Charts.moodCountAxisLabel, item.count),
                        innerRadius: .ratio(0.5),
                        angularInset: 2
                    )
                    .foregroundStyle(item.mood.color)
                    .cornerRadius(4)
                }
                .frame(width: 140, height: 140)
                
                // Legend
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(data.filter { $0.count > 0 }, id: \.mood) { item in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(item.mood.color)
                                .frame(width: 10, height: 10)
                            
                            Text("\(item.mood.emoji) \(item.mood.rawValue)")
                                .font(.caption)
                            
                            Spacer()
                            
                            Text("\(item.count)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 8)
        }
    }
}
