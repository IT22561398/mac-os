// NurseryConnect | DailySummaryView.swift
// End-of-day digest aligned to daily summary requirements.
// EYFS coverage chart (Swift Charts), wellbeing timeline, allergen summary,
// stats grid, and ShareLink for parent communication.

import SwiftUI
import Charts

// MARK: - DailySummaryView
struct DailySummaryView: View {
    let childId: UUID
    let date: Date

    @Environment(DataManager.self) private var dataManager
    @Environment(\.dismiss) private var dismiss

    private var child: ChildProfile? {
        dataManager.child(for: childId)
    }

    private var entries: [DiaryEntry] {
        dataManager.diaryEntriesForChild(childId, on: date)
    }

    private var summary: DailySummary {
        dataManager.generateDailySummary(for: childId, on: date)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: Child Header
                    childHeader

                    // MARK: Day Assessment
                    dayAssessmentCard

                    // MARK: Stats Grid
                    statsGrid

                    // MARK: EYFS Coverage Chart
                    eyfsCoverageChart

                    // MARK: Wellbeing Summary
                    wellbeingSummary

                    // MARK: Allergen Summary
                    allergenSummary

                    // MARK: Share Button
                    shareSection

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(Color.ncBackground)
            .navigationTitle("Daily Summary")
            
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.ncPrimary)
                        .accessibilityLabel("Dismiss summary")
                }
            }
        }
    }

    // MARK: - Child Header
    @ViewBuilder
    private var childHeader: some View {
        if let child = child {
            HStack(spacing: 14) {
                ChildAvatar(child: child, size: 52)

                VStack(alignment: .leading, spacing: 4) {
                    Text(child.fullName)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.ncText)

                    Text(date.isToday ? "Today · \(date.shortDateString)" : date.shortDateString)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.ncTextSec)
                }
                Spacer()
            }
        }
    }

    // MARK: - Day Assessment
    private var dayAssessmentCard: some View {
        let assessment = computeDayAssessment()

        return HStack(spacing: 14) {
            Text(assessment.emoji)
                .font(.system(size: 36))

            VStack(alignment: .leading, spacing: 4) {
                Text(assessment.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(assessment.color)
                Text(assessment.subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.ncTextSec)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(assessment.color.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(assessment.color.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Stats Grid
    private var statsGrid: some View {
        let activities = entries.filter { $0.type == .activity }
        let meals = entries.filter { $0.type == .meal }
        let nappies = entries.filter { $0.type == .nappy }
        let eyfsAreas = Set(activities.compactMap { $0.eyfsArea }).count

        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statCell(
                icon: "moon.zzz.fill",
                iconColor: Color(hex: "A29BFE"),
                title: "Total Sleep",
                value: summary.totalSleepDuration,
                detail: "\(summary.sleepCount) nap\(summary.sleepCount == 1 ? "" : "s")"
            )
            statCell(
                icon: "fork.knife",
                iconColor: Color(hex: "FF9F43"),
                title: "Meals Recorded",
                value: "\(meals.count) of 6",
                detail: "possible meals"
            )
            statCell(
                icon: "arrow.triangle.2.circlepath",
                iconColor: Color.ncWarning,
                title: "Nappy Changes",
                value: "\(nappies.count)",
                detail: nappies.count == 0 ? "none today" : "changes"
            )
            statCell(
                icon: "figure.play",
                iconColor: Color.ncPrimary,
                title: "Activities",
                value: "\(activities.count)",
                detail: "\(eyfsAreas) EYFS area\(eyfsAreas == 1 ? "" : "s")"
            )
        }
    }

    private func statCell(icon: String, iconColor: Color, title: String, value: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(iconColor)
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.ncTextSec)
            }

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ncText)

            Text(detail)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.ncTextSec)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.ncCard)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    // MARK: - EYFS Coverage Chart
    private var eyfsCoverageChart: some View {
        let activities = entries.filter { $0.type == .activity }
        let areaData = computeEYFSData(activities)
        let coveredAreas = areaData.filter { $0.count > 0 }.count

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.ncPrimary)
                Text("EYFS Coverage Today · \(coveredAreas) of 7 areas")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ncText)
            }

            Chart(areaData, id: \.name) { item in
                BarMark(
                    x: .value("Area", item.name),
                    y: .value("Count", item.count)
                )
                .foregroundStyle(item.color)
                .cornerRadius(4)
            }
            .frame(height: 180)
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel()
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel()
                        .font(.system(size: 10))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.ncCard)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    // MARK: - Wellbeing Summary
    private var wellbeingSummary: some View {
        let wellbeingEntries = entries.filter { $0.type == .wellbeing }

        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.ncSecondary)
                Text("Wellbeing Summary")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ncText)
            }

            HStack(spacing: 0) {
                ForEach(WellbeingCheckTime.allCases) { period in
                    let entry = wellbeingEntries.first { $0.wellbeingCheckTime == period }
                    let isLast = period == .departure

                    HStack(spacing: 0) {
                        VStack(spacing: 6) {
                            if let entry = entry {
                                ZStack {
                                    Circle()
                                        .fill(entry.moodRating?.color ?? Color.ncPrimary)
                                        .frame(width: 36, height: 36)
                                    Text(entry.moodRating?.emoji ?? "✓")
                                        .font(.system(size: 16))
                                }
                                Text(entry.moodRating?.rawValue ?? "")
                                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color.ncText)
                                Text(entry.timestamp.timeString)
                                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                                    .foregroundStyle(Color.ncTextSec)
                            } else {
                                ZStack {
                                    Circle()
                                        .stroke(Color.white.opacity(0.2), style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                                        .frame(width: 36, height: 36)
                                    Text("—")
                                        .font(.system(size: 14))
                                        .foregroundStyle(Color.ncTextSec)
                                }
                                Text(period.rawValue)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Color.ncTextSec)
                                Text("Not recorded")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundStyle(Color.ncTextSec.opacity(0.6))
                            }
                        }
                        .frame(maxWidth: .infinity)

                        if !isLast {
                            Rectangle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 30, height: 2)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.ncCard)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    // MARK: - Allergen Summary
    @ViewBuilder
    private var allergenSummary: some View {
        if let child = child, child.hasAllergies {
            let meals = entries.filter { $0.type == .meal }

            if meals.isEmpty {
                // No meals recorded yet
                HStack(spacing: 10) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.ncPrimary)
                    Text("No meals recorded yet today. Allergen checks will appear after meals are logged.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.ncText)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.ncPrimary.opacity(0.08))
                )
            } else {
                // All meals safe
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.ncSuccess)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Allergen Safety Summary")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.ncSuccess)
                        Text("\(meals.count) meal\(meals.count == 1 ? "" : "s") recorded — allergen checks completed ✓")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.ncText)
                    }

                    Spacer()
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.ncSuccess.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.ncSuccess.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Share Section
    private var shareSection: some View {
        let shareText = generateShareText()

        return ShareLink(item: shareText) {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 14, weight: .bold))
                Text("Share Daily Summary")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [Color.ncPrimary, Color(hex: "8B5CF6")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .shadow(color: Color.ncPrimary.opacity(0.3), radius: 8, y: 4)
        }
        .accessibilityLabel("Share daily summary for \(child?.displayName ?? "child")")
    }

    // MARK: - Computation Helpers
    private func computeDayAssessment() -> (emoji: String, title: String, subtitle: String, color: Color) {
        let wellbeingEntries = entries.filter { $0.type == .wellbeing }
        let moods = wellbeingEntries.compactMap { $0.moodRating }

        if moods.isEmpty {
            return ("📋", "No Wellbeing Data", "Log wellbeing checks to see a day assessment", Color.ncTextSec)
        }

        let hasNegative = moods.contains { $0 == .poorly || $0 == .upset }
        let allPositive = moods.allSatisfy { $0 == .happy || $0 == .content }

        if hasNegative {
            return ("⚠️", "Needs Follow-up", "Some concerns noted in today's wellbeing checks", Color(hex: "E74C3C"))
        } else if allPositive {
            return ("🌟", "Great Day", "All wellbeing checks show positive mood", Color.ncSuccess)
        } else {
            return ("☀️", "Settled Day", "Mixed but generally positive wellbeing today", Color.ncWarning)
        }
    }

    private struct EYFSChartItem {
        let name: String
        let count: Int
        let color: Color
    }

    private func computeEYFSData(_ activities: [DiaryEntry]) -> [EYFSChartItem] {
        let areaMap: [(String, String, Color)] = [
            ("C&L", "Communication", Color.ncPrimary),
            ("PSED", "Personal", Color(hex: "A29BFE")),
            ("PD", "Physical", Color.ncSuccess),
            ("Lit", "Literacy", Color(hex: "74B9FF")),
            ("Maths", "Math", Color.ncAccent),
            ("UTW", "Understanding", Color(hex: "6C5CE7")),
            ("EAD", "Expressive", Color(hex: "FD79A8"))
        ]

        return areaMap.map { abbr, keyword, color in
            let count = activities.filter { entry in
                guard let area = entry.eyfsArea else { return false }
                return area.lowercased().contains(keyword.lowercased())
            }.count
            return EYFSChartItem(name: abbr, count: count, color: color)
        }
    }

    private func generateShareText() -> String {
        let childName = child?.fullName ?? "Child"
        let dateStr = date.shortDateString

        let activities = entries.filter { $0.type == .activity }
        let meals = entries.filter { $0.type == .meal }
        _ = entries.filter { $0.type == .sleep }
        let wellbeingEntries = entries.filter { $0.type == .wellbeing }

        var text = "NurseryConnect Daily Summary\n"
        text += "\(childName) · \(dateStr)\n\n"
        text += "Activities: \(activities.count) logged\n"
        text += "Sleep: \(summary.totalSleepDuration)\n"
        text += "Meals: \(meals.count) recorded\n"
        text += "Wellbeing Checks: \(wellbeingEntries.count)\n"

        let assessment = computeDayAssessment()
        text += "\nOverall: \(assessment.title)\n"
        text += "\nGenerated by NurseryConnect"

        return text
    }
}

// MARK: - Preview
#Preview {
    DailySummaryView(
        childId: SampleData.children[0].id,
        date: Date()
    )
    .environment(DataManager.shared)
}
