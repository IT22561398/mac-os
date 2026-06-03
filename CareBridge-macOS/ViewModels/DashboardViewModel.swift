// NurseryConnect | DashboardViewModel.swift
// All computed properties derive from DataManager in real time — zero hardcoded values.
// Refreshed on .onAppear and on Notification.entrySaved from DiaryEntryFormView.
//
// MODELS ADDED (local to this file):
//   DashboardRecommendation  — actionable gap detected in today's diary
//   AllergyAlertItem         — child with allergy who had a meal today
//   RecommendationType       — missing wellbeing, meal, nappy, sleep; allergy alert
//   RecommendationPriority   — high (3), medium (2), low (1)

import Foundation
import SwiftUI

// MARK: - Supporting Models

/// Represents an actionable gap in a child's daily records.
struct DashboardRecommendation: Identifiable {
    let id = UUID()
    let type: RecommendationType
    let child: ChildProfile
    let message: String
    let priority: RecommendationPriority
    let actionType: DiaryEntryType  // Tap "Log Now" → opens form pre-filled with this type

    enum RecommendationPriority: Int, Comparable {
        case low    = 1
        case medium = 2
        case high   = 3

        static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }

        var tintColor: Color {
            switch self {
            case .low:    return Color(hex: "74B9FF")   // Calm blue
            case .medium: return Color(hex: "FDCB6E")   // Amber
            case .high:   return Color(hex: "FB7185")   // Coral red
            }
        }

        var icon: String {
            switch self {
            case .low:    return "info.circle.fill"
            case .medium: return "exclamationmark.circle.fill"
            case .high:   return "exclamationmark.triangle.fill"
            }
        }

        var label: String {
            switch self {
            case .low:    return "Low"
            case .medium: return "Medium"
            case .high:   return "High"
            }
        }
    }

    enum RecommendationType {
        case missingWellbeing
        case missingMeal
        case nappyDue
        case missingSleep
        case allergyAlert
    }
}

/// A child with an active allergen who had a meal entry today.
struct AllergyAlertItem: Identifiable {
    let id = UUID()
    let child: ChildProfile
    let allergies: [Allergen]
    let mealTime: Date
}

// MARK: - DashboardViewModel

@Observable
class DashboardViewModel {

    // MARK: - Dependencies
    var dataManager: DataManager

    // MARK: - Search
    var searchText: String = ""

    // MARK: - Init
    init(dataManager: DataManager = .shared) {
        self.dataManager = dataManager
    }

    // MARK: - Profile

    var keyworker: KeyworkerProfile {
        dataManager.keyworker
    }

    // MARK: - Greeting

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12  { return "Good Morning" }
        if hour < 17  { return "Good Afternoon" }
        return "Good Evening"
    }

    var todayDateString: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, d MMMM yyyy"
        return f.string(from: Date())
    }

    // MARK: - Assigned Children (search-filtered)

    var assignedChildren: [ChildProfile] {
        dataManager.children.filter { child in
            guard !searchText.isEmpty else { return true }
            return child.fullName.localizedCaseInsensitiveContains(searchText) ||
                   child.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var childrenWithAllergies: [ChildProfile] {
        dataManager.childrenWithAllergies()
    }

    // MARK: - Quick Stats (all real-time from DataManager)

    /// Number of distinct children who have at least 1 diary entry logged today.
    var childrenCheckedInToday: Int {
        let cal = Calendar.current
        let todayChildIDs = Set(
            dataManager.diaryEntries
                .filter { cal.isDateInToday($0.timestamp) }
                .map { $0.childId }
        )
        return todayChildIDs.count
    }

    /// Total number of diary entries logged for any child today.
    var entriesToday: Int {
        let cal = Calendar.current
        return dataManager.diaryEntries.filter { cal.isDateInToday($0.timestamp) }.count
    }

    /// Incidents reported this week.
    var weekIncidentCount: Int {
        dataManager.weekIncidentCount()
    }

    /// Total incidents pending manager review.
    var pendingIncidentCount: Int {
        dataManager.pendingReviewIncidents().count
    }

    /// Total actionable alerts = allergyAlerts + high/medium recommendations
    var activeAlerts: Int {
        allergyAlertItems.count +
        todayRecommendations.filter { $0.priority >= .medium }.count
    }

    // MARK: - Allergy Alert Items
    // Children who have allergies AND had at least one meal entry logged today.
    // (Signal: we need to verify the meal was allergen-safe.)

    var allergyAlertItems: [AllergyAlertItem] {
        let cal = Calendar.current
        return assignedChildren
            .filter { !$0.allergies.isEmpty }
            .compactMap { child -> AllergyAlertItem? in
                // Has a meal entry been logged for this child today?
                let mealEntry = dataManager.diaryEntries.first {
                    $0.childId == child.id &&
                    $0.type == .meal &&
                    cal.isDateInToday($0.timestamp)
                }
                guard let meal = mealEntry else { return nil }
                return AllergyAlertItem(
                    child: child,
                    allergies: child.allergies,
                    mealTime: meal.timestamp
                )
            }
    }

    // MARK: - Today's Recommendations
    // Computed by iterating each assigned child and checking for gaps in their
    // diary records relative to the current time of day.
    // Calendar.isDateInToday uses the device's local calendar — timezone safe.

    var todayRecommendations: [DashboardRecommendation] {
        var items: [DashboardRecommendation] = []
        let cal = Calendar.current
        let now = Date()
        let hour = cal.component(.hour, from: now)

        for child in assignedChildren {
            let todayEntries = dataManager.diaryEntries.filter {
                $0.childId == child.id && cal.isDateInToday($0.timestamp)
            }

            // ── Arrival Wellbeing Check ─────────────────────────────────
            // Expected: at least one .wellbeing entry with period = arrival
            // Alert if: hour >= 8 and no arrival wellbeing recorded yet
            let hasArrivalWellbeing = todayEntries.contains {
                $0.type == .wellbeing &&
                ($0.wellbeingCheckTime == .arrival || $0.wellbeingCheckTime == WellbeingCheckTime.allCases.first)
            }
            if !hasArrivalWellbeing && hour >= 8 {
                items.append(DashboardRecommendation(
                    type: .missingWellbeing,
                    child: child,
                    message: "No arrival wellbeing check for \(child.firstName)",
                    priority: .high,
                    actionType: .wellbeing
                ))
            }

            // ── Midday Wellbeing Check ──────────────────────────────────
            // Expected: .wellbeing entry at midday period after 11am
            if hour >= 11 {
                let hasMiddayWellbeing = todayEntries.contains {
                    $0.type == .wellbeing && $0.wellbeingCheckTime == .midday
                }
                if !hasMiddayWellbeing {
                    items.append(DashboardRecommendation(
                        type: .missingWellbeing,
                        child: child,
                        message: "Midday wellbeing check pending for \(child.firstName)",
                        priority: hour >= 13 ? .high : .medium,
                        actionType: .wellbeing
                    ))
                }
            }

            // ── Lunch Not Logged ────────────────────────────────────────
            // Expected: .meal entry with mealType = .lunch after 12pm
            if hour >= 13 {
                let hasLunch = todayEntries.contains {
                    $0.type == .meal &&
                    cal.component(.hour, from: $0.timestamp) >= 11 &&
                    cal.component(.hour, from: $0.timestamp) <= 14
                }
                if !hasLunch {
                    items.append(DashboardRecommendation(
                        type: .missingMeal,
                        child: child,
                        message: "Lunch not yet recorded for \(child.firstName)",
                        priority: .medium,
                        actionType: .meal
                    ))
                }
            }

            // ── Nappy Check Overdue ─────────────────────────────────────
            // Expected: children < 3 years old, nappy change every ~3 hours
            let ageInYears = child.dateOfBirth.ageInYears
            if ageInYears < 3 {
                let lastNappy = todayEntries
                    .filter { $0.type == .nappy }
                    .sorted { $0.timestamp > $1.timestamp }
                    .first

                let hoursSinceNappy: Double
                if let nappy = lastNappy {
                    hoursSinceNappy = now.timeIntervalSince(nappy.timestamp) / 3600
                } else {
                    // Never changed today — treat as very overdue
                    hoursSinceNappy = Double(hour)
                }

                if hoursSinceNappy >= 3 {
                    let hrs = Int(hoursSinceNappy)
                    items.append(DashboardRecommendation(
                        type: .nappyDue,
                        child: child,
                        message: "Nappy check overdue for \(child.firstName) (\(hrs)h ago)",
                        priority: hoursSinceNappy >= 4 ? .high : .medium,
                        actionType: .nappy
                    ))
                }
            }

            // ── Rest Period Not Logged ──────────────────────────────────
            // Expected: children < 3 after 1pm should have a sleep entry
            if ageInYears < 3 && hour >= 14 {
                let hasSleep = todayEntries.contains { $0.type == .sleep }
                if !hasSleep {
                    items.append(DashboardRecommendation(
                        type: .missingSleep,
                        child: child,
                        message: "No rest period logged for \(child.firstName) today",
                        priority: .low,
                        actionType: .sleep
                    ))
                }
            }
        }

        // Sort: highest priority first, then alphabetically by child name within same priority
        return items.sorted {
            if $0.priority != $1.priority { return $0.priority > $1.priority }
            return $0.child.firstName < $1.child.firstName
        }
    }

    /// Convenience: returns true when all assigned children are fully up-to-date.
    var allRecordsUpToDate: Bool {
        todayRecommendations.isEmpty && allergyAlertItems.isEmpty
    }

    // MARK: - Per-Child Summary (for dashboard cards)

    func todayEntrySummary(for childId: UUID) -> (activities: Int, meals: Int, sleeps: Int, nappies: Int) {
        let entries = dataManager.todayEntriesForChild(childId)
        return (
            activities: entries.filter { $0.type == .activity }.count,
            meals:      entries.filter { $0.type == .meal }.count,
            sleeps:     entries.filter { $0.type == .sleep }.count,
            nappies:    entries.filter { $0.type == .nappy }.count
        )
    }

    func latestMood(for childId: UUID) -> MoodRating? {
        dataManager.todayEntriesForChild(childId)
            .filter { $0.type == .wellbeing && $0.moodRating != nil }
            .sorted { $0.timestamp > $1.timestamp }
            .first?.moodRating
    }

    func lastEntryTime(for childId: UUID) -> String {
        dataManager.todayEntriesForChild(childId).first?.timestamp.relativeTimeString ?? "No entries today"
    }

    // MARK: - Backward-Compat Properties
    // (used by KeyworkerDashboardView stats chips)

    var totalChildrenCount: Int { dataManager.children.count }

    var totalEntriesThisWeek: Int { dataManager.totalEntriesThisWeek() }

    // MARK: - Refresh
    /// Called on .onAppear and after entrySaved notification.
    /// Since @Observable tracks property access, most UI simply re-reads computed
    /// properties. However, we manually flush any needed DataManager state here.
    func refresh() {
        // DataManager automatically persists; just touch a property to trigger view refresh
        let _ = dataManager.diaryEntries.count
    }
}
