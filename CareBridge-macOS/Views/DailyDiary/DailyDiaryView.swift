// NurseryConnect | DailyDiaryView.swift
// Full diary timeline with child selector, wellbeing slots,
// EYFS area tags, allergen warnings, and timeline visual.
// EYFS 2024 Section 7.3 — daily diary module.

import SwiftUI

// MARK: - DailyDiaryView
struct DailyDiaryView: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(SleepTrackerManager.self) private var sleepTracker
    @State private var viewModel = DiaryViewModel()
    @State private var showEntryForm = false
    @State private var showSummary = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ncBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // MARK: Header
                        headerSection

                        // MARK: Child Selector
                        childSelectorRow

                        // MARK: Date Selector
                        dateSelectorRow

                        // MARK: Wellbeing Slots
                        wellbeingSlotsRow

                        // MARK: Timeline
                        if viewModel.todayEntries.isEmpty {
                            emptyStateSection
                        } else {
                            timelineSection
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Daily Diary")
            
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    HStack(spacing: 4) {
                        // Summary button
                        Button {
                            showSummary = true
                        } label: {
                            Image(systemName: "chart.bar.doc.horizontal.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.ncPrimary)
                                .frame(width: 44, height: 44)
                        }
                        .accessibilityLabel("View daily summary")

                        // Add entry
                        Button {
                            viewModel.prepareNewEntry(type: .activity)
                            showEntryForm = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(Color.ncPrimary)
                                .frame(width: 44, height: 44)
                        }
                        .accessibilityLabel("Add diary entry")
                    }
                }
            }
            .sheet(isPresented: $showEntryForm) {
                DiaryEntryFormView(
                    viewModel: viewModel,
                    preselectedChildId: viewModel.selectedChildId
                )
            }
            .sheet(isPresented: $showSummary) {
                if let childId = viewModel.selectedChildId {
                    DailySummaryView(
                        childId: childId,
                        date: viewModel.selectedDate
                    )
                }
            }
            .onAppear {
                viewModel.dataManager = dataManager
            }
            .onReceive(NotificationCenter.default.publisher(for: .entrySaved)) { _ in
                // Refresh on entry saved
                let _ = viewModel.todayEntries
            }
            .toast($viewModel.toast)
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Daily Diary")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ncText)
            
            Text("Log activities, naps, meals, and wellbeing checks for the day.")
                .font(.system(size: 13))
                .foregroundStyle(Color.ncTextSec)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 4)
    }

    // MARK: - Child Selector Row
    private var childSelectorRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(dataManager.children) { child in
                    let isSelected = viewModel.selectedChildId == child.id
                    Button {
                        viewModel.selectedChildId = child.id
                        HapticManager.selection()
                    } label: {
                        VStack(spacing: 5) {
                            ZStack(alignment: .topTrailing) {
                                ChildAvatar(child: child, size: 44)

                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 13))
                                        .foregroundStyle(Color.ncPrimary)
                                        .background(Circle().fill(Color.ncCard).padding(-2))
                                        .offset(x: 4, y: -4)
                                }
                            }

                            Text(child.displayName)
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundStyle(isSelected ? Color.ncText : Color.ncTextSec)
                                .lineLimit(1)

                            // Sleep indicator
                            if sleepTracker.isAsleep(child.id) {
                                Text("💤 Sleeping")
                                    .font(.system(size: 8, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color(hex: "6C5CE7"))
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(Color(hex: "6C5CE7").opacity(0.12)))
                            }
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isSelected ? Color.ncPrimary.opacity(0.1) : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.ncPrimary : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(minWidth: 44, minHeight: 44)
                    .accessibilityLabel("Select \(child.displayName)")
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
            .padding(.horizontal, 4)
        }
    }

    // MARK: - Date Selector
    private var dateSelectorRow: some View {
        HStack {
            Button {
                viewModel.selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: viewModel.selectedDate) ?? viewModel.selectedDate
                HapticManager.lightTap()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.ncPrimary)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Previous day")

            Spacer()

            VStack(spacing: 2) {
                Text(viewModel.selectedDate.isToday ? "Today" : viewModel.selectedDate.dayName)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ncText)
                Text(viewModel.selectedDate.shortDateString)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.ncTextSec)
            }

            Spacer()

            Button {
                viewModel.selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: viewModel.selectedDate) ?? viewModel.selectedDate
                HapticManager.lightTap()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(viewModel.selectedDate.isToday ? Color.ncTextSec.opacity(0.3) : Color.ncPrimary)
                    .frame(width: 44, height: 44)
            }
            .disabled(viewModel.selectedDate.isToday)
            .accessibilityLabel("Next day")
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Wellbeing Slots
    private var wellbeingSlotsRow: some View {
        HStack(spacing: 12) {
            ForEach(WellbeingCheckTime.allCases) { period in
                let entry = wellbeingEntry(for: period)
                let isCompleted = entry != nil

                VStack(spacing: 6) {
                    // Period label
                    Text(period.rawValue.uppercased())
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.ncTextSec)
                        .tracking(0.8)

                    // Circle
                    ZStack {
                        if isCompleted {
                            Circle()
                                .fill(Color.ncPrimary)
                                .frame(width: 40, height: 40)
                            Text(entry?.moodRating?.emoji ?? "✓")
                                .font(.system(size: 18))
                        } else {
                            Circle()
                                .stroke(Color.white.opacity(0.2), style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                                .frame(width: 40, height: 40)
                        }
                    }

                    if isCompleted {
                        Text(entry?.timestamp.timeString ?? "")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color.ncTextSec)
                    } else {
                        Button {
                            viewModel.wellbeingTime = period
                            viewModel.prepareNewEntry(type: .wellbeing)
                            showEntryForm = true
                        } label: {
                            Text("Log")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.ncPrimary)
                                .frame(minWidth: 44, minHeight: 24)
                        }
                        .accessibilityLabel("Log \(period.rawValue) wellbeing check")
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(14)
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

    // MARK: - Timeline Section
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Text("Timeline")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ncText)
                Spacer()
                Text("\(viewModel.todayEntries.count) entries")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.ncTextSec)
            }
            .padding(.bottom, 12)

            let sorted = viewModel.todayEntries.sorted { $0.timestamp < $1.timestamp }

            ForEach(Array(sorted.enumerated()), id: \.element.id) { index, entry in
                timelineRow(entry: entry, isLast: index == sorted.count - 1)
            }
        }
    }

    // MARK: - Timeline Row
    private func timelineRow(entry: DiaryEntry, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Timeline dot + line
            VStack(spacing: 0) {
                Circle()
                    .fill(entryTypeColor(entry.type))
                    .frame(width: 12, height: 12)
                    .padding(.top, 4)

                if !isLast {
                    Rectangle()
                        .fill(Color.ncPrimary.opacity(0.3))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 12)

            // Entry card
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    // Type icon
                    Image(systemName: entry.displayIcon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(entryTypeColor(entry.type))

                    Text(entry.displayTitle)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.ncText)
                        .lineLimit(1)

                    // EYFS area tag (for activities)
                    if entry.type == .activity, let area = entry.eyfsArea {
                        eyfsChip(area)
                    }

                    Spacer()

                    // Time chip
                    Text(entry.timestamp.timeString)
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color.ncTextSec)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            Capsule().fill(Color.white.opacity(0.06))
                        )

                    // Allergen warning
                    if entry.type == .meal, let child = selectedChild, child.hasAllergies {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(Color(hex: "FB7185"))
                    }
                }

                // Subtitle
                let sub = entry.displaySubtitle
                if !sub.isEmpty {
                    Text(sub)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color.ncTextSec)
                        .lineLimit(2)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.ncCard)
                    .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.04), lineWidth: 1)
            )
        }
        .padding(.bottom, 8)
    }

    // MARK: - Empty State
    private var emptyStateSection: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 40)

            ZStack {
                Circle()
                    .fill(Color.ncPrimary.opacity(0.06))
                    .frame(width: 120, height: 120)
                Image(systemName: "book.pages")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.ncPrimary)
                    .pulse()
            }

            VStack(spacing: 6) {
                Text("No diary entries for \(selectedChild?.displayName ?? "this child") today")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.ncText)
                    .multilineTextAlignment(.center)

                Text("Tap + to start logging activities, meals, and more.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.ncTextSec)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)

            Spacer(minLength: 40)
        }
    }

    // MARK: - Helpers
    private var selectedChild: ChildProfile? {
        guard let id = viewModel.selectedChildId else { return nil }
        return dataManager.child(for: id)
    }

    private func wellbeingEntry(for period: WellbeingCheckTime) -> DiaryEntry? {
        viewModel.todayEntries.first { entry in
            entry.type == .wellbeing && entry.wellbeingCheckTime == period
        }
    }

    private func entryTypeColor(_ type: DiaryEntryType) -> Color {
        switch type {
        case .arrival: return Color.ncSuccess
        case .departure: return Color.ncWarning
        case .activity: return Color.ncPrimary           // teal
        case .meal: return Color(hex: "FF9F43")           // orange
        case .sleep: return Color(hex: "6C5CE7")         // indigo
        case .nappy: return Color.ncWarning               // amber
        case .wellbeing: return Color(hex: "FB7185")      // coral
        case .milestone: return Color.ncAccent
        case .note: return Color.ncTextSecondary           // gray
        }
    }

    private func eyfsChip(_ area: String) -> some View {
        let chipData: (String, Color) = {
            let lower = area.lowercased()
            if lower.contains("communication") { return ("C&L", .ncPrimary) }
            if lower.contains("personal") || lower.contains("psed") { return ("PSED", Color(hex: "A29BFE")) }
            if lower.contains("physical") { return ("PD", .ncSuccess) }
            if lower.contains("literacy") { return ("Lit", Color(hex: "74B9FF")) }
            if lower.contains("math") { return ("Maths", .ncAccent) }
            if lower.contains("understanding") { return ("UTW", Color(hex: "6C5CE7")) }
            if lower.contains("expressive") || lower.contains("art") { return ("EAD", Color(hex: "FD79A8")) }
            return ("EYFS", .ncPrimary)
        }()

        return Text(chipData.0)
            .font(.system(size: 9, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Capsule().fill(chipData.1))
    }
}

// MARK: - Preview
#Preview {
    DailyDiaryView()
        .environment(DataManager.shared)
}
