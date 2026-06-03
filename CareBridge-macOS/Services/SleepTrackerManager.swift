// NurseryConnect | SleepTrackerManager.swift
// @Observable service tracking live sleep sessions for children.
// Uses ONE shared timer for performance — avoids per-child Timer.publish overhead.
// Creates/updates DiaryEntry with nil sleepEndTime for in-progress sleeps.
// Compliant with EYFS 2024 Section 3.60 — sleep and rest period monitoring.

import Foundation
import SwiftUI

// MARK: - SleepTrackerManager

@Observable
class SleepTrackerManager {
    static let shared = SleepTrackerManager()

    /// Maps childId → sleep start time for currently active sleep sessions.
    var activeSleepSessions: [UUID: Date] = [:]

    /// Maps childId → DiaryEntry.id for the sleep entry to update on wake.
    var sleepEntryIds: [UUID: UUID] = [:]

    // MARK: - Query

    func isAsleep(_ childId: UUID) -> Bool {
        activeSleepSessions[childId] != nil
    }

    var sleepingChildIds: [UUID] {
        Array(activeSleepSessions.keys)
    }

    var hasActiveSleepers: Bool {
        !activeSleepSessions.isEmpty
    }

    var activeSleeperCount: Int {
        activeSleepSessions.count
    }

    /// Returns formatted duration string: "42 min" or "1h 3min"
    func sleepDuration(for childId: UUID, now: Date = Date()) -> String {
        guard let start = activeSleepSessions[childId] else { return "—" }
        let elapsed = now.timeIntervalSince(start)
        let totalMinutes = Int(elapsed) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 {
            return "\(hours)h \(minutes)min"
        } else {
            return "\(minutes) min"
        }
    }

    /// Returns formatted live timer string: "00:42:17"
    func liveTimerString(for childId: UUID, now: Date = Date()) -> String {
        guard let start = activeSleepSessions[childId] else { return "00:00:00" }
        let elapsed = Int(now.timeIntervalSince(start))
        let hours = elapsed / 3600
        let minutes = (elapsed % 3600) / 60
        let seconds = elapsed % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    // MARK: - Start Sleep

    /// Records sleep start. Creates a DiaryEntry with endTime = nil (in progress).
    func startSleep(for childId: UUID, dataManager: DataManager) {
        let startTime = Date()
        activeSleepSessions[childId] = startTime

        let entry = DiaryEntry(
            childId: childId,
            keyworkerId: dataManager.keyworker.id,
            type: .sleep,
            timestamp: startTime,
            notes: "Sleep in progress...",
            sleepStartTime: startTime,
            sleepEndTime: nil,
            sleepPosition: .back,
            sleepDurationMinutes: nil
        )

        sleepEntryIds[childId] = entry.id
        dataManager.addDiaryEntry(entry)
    }

    // MARK: - End Sleep

    /// Ends sleep. Updates the DiaryEntry with endTime and computed duration.
    /// Returns the duration string for display in toast.
    @discardableResult
    func endSleep(for childId: UUID, dataManager: DataManager) -> String {
        guard let startTime = activeSleepSessions[childId] else { return "" }

        let endTime = Date()
        let durationMinutes = Int(endTime.timeIntervalSince(startTime) / 60)
        let durationStr = sleepDuration(for: childId, now: endTime)

        // Update the diary entry
        if let entryId = sleepEntryIds[childId],
           let entryIndex = dataManager.diaryEntries.firstIndex(where: { $0.id == entryId }) {
            dataManager.diaryEntries[entryIndex].sleepEndTime = endTime
            dataManager.diaryEntries[entryIndex].sleepDurationMinutes = durationMinutes
            dataManager.diaryEntries[entryIndex].notes = "Slept for \(durationStr)"
            dataManager.save()
        }

        // Clean up tracking
        activeSleepSessions.removeValue(forKey: childId)
        sleepEntryIds.removeValue(forKey: childId)

        return durationStr
    }
}
