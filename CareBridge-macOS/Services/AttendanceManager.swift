// NurseryConnect | AttendanceManager.swift
// @Observable service managing daily attendance records for all assigned children.
// Supports check-in, check-out, mark-absent workflows with JSON+UserDefaults persistence.
// Compliant with EYFS 2024 Section 3.64 — attendance and registration requirements.
//
// STATE MACHINE:
//   EXPECTED → CHECKED_IN → CHECKED_OUT
//   EXPECTED → ABSENT
//   checkIn() is idempotent — updates existing record for same child+date.

import Foundation
import SwiftUI

// MARK: - Attendance Record Model

struct AttendanceRecord: Codable, Identifiable {
    let id: UUID
    var childId: UUID
    var date: Date
    var checkInTime: Date?
    var checkInBy: String
    var droppedOffBy: String
    var checkOutTime: Date?
    var collectedBy: String
    var collectorAuthorised: Bool
    var isAbsent: Bool
    var absenceReason: String
    var arrivalMood: String
    var departureMood: String
    var parentNotes: String
    var handoverNotes: String

    init(
        id: UUID = UUID(),
        childId: UUID,
        date: Date = Date(),
        checkInTime: Date? = nil,
        checkInBy: String = "",
        droppedOffBy: String = "",
        checkOutTime: Date? = nil,
        collectedBy: String = "",
        collectorAuthorised: Bool = false,
        isAbsent: Bool = false,
        absenceReason: String = "",
        arrivalMood: String = "",
        departureMood: String = "",
        parentNotes: String = "",
        handoverNotes: String = ""
    ) {
        self.id = id
        self.childId = childId
        self.date = date
        self.checkInTime = checkInTime
        self.checkInBy = checkInBy
        self.droppedOffBy = droppedOffBy
        self.checkOutTime = checkOutTime
        self.collectedBy = collectedBy
        self.collectorAuthorised = collectorAuthorised
        self.isAbsent = isAbsent
        self.absenceReason = absenceReason
        self.arrivalMood = arrivalMood
        self.departureMood = departureMood
        self.parentNotes = parentNotes
        self.handoverNotes = handoverNotes
    }
}

// MARK: - Attendance State

enum AttendanceState: String {
    case expected = "Expected"
    case checkedIn = "Checked In"
    case checkedOut = "Checked Out"
    case absent = "Absent"

    var color: Color {
        switch self {
        case .expected:   return Color(hex: "F4A261") // Amber
        case .checkedIn:  return Color(hex: "55EFC4") // Green
        case .checkedOut: return Color.gray
        case .absent:     return Color(hex: "FB7185") // Red
        }
    }

    var icon: String {
        switch self {
        case .expected:   return "clock.fill"
        case .checkedIn:  return "checkmark.circle.fill"
        case .checkedOut: return "arrow.right.circle.fill"
        case .absent:     return "xmark.circle.fill"
        }
    }
}

// MARK: - AttendanceManager

@Observable
class AttendanceManager {
    static let shared = AttendanceManager()

    var records: [AttendanceRecord] = []

    private let storageKey = "nc_attendance_records"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        loadRecords()
    }

    // MARK: - Computed Properties

    var todayRecords: [AttendanceRecord] {
        let cal = Calendar.current
        return records.filter { cal.isDateInToday($0.date) }
    }

    var presentCount: Int {
        todayRecords.filter { $0.checkInTime != nil && $0.checkOutTime == nil && !$0.isAbsent }.count
    }

    var expectedCount: Int {
        todayRecords.filter { $0.checkInTime == nil && !$0.isAbsent }.count
    }

    var absentCount: Int {
        todayRecords.filter { $0.isAbsent }.count
    }

    var checkedOutCount: Int {
        todayRecords.filter { $0.checkOutTime != nil }.count
    }

    // MARK: - State Query

    func state(for childId: UUID) -> AttendanceState {
        guard let record = todayRecord(for: childId) else { return .expected }
        if record.isAbsent { return .absent }
        if record.checkOutTime != nil { return .checkedOut }
        if record.checkInTime != nil { return .checkedIn }
        return .expected
    }

    func isCheckedIn(_ childId: UUID) -> Bool {
        state(for: childId) == .checkedIn
    }

    func isCheckedOut(_ childId: UUID) -> Bool {
        state(for: childId) == .checkedOut
    }

    func todayRecord(for childId: UUID) -> AttendanceRecord? {
        let cal = Calendar.current
        return records.first { $0.childId == childId && cal.isDateInToday($0.date) }
    }

    // MARK: - Check In (Idempotent)

    func checkIn(
        child: ChildProfile,
        droppedOffBy: String,
        mood: String = "",
        parentNotes: String = ""
    ) {
        let cal = Calendar.current
        if let index = records.firstIndex(where: {
            $0.childId == child.id && cal.isDateInToday($0.date)
        }) {
            // Update existing record
            records[index].checkInTime = Date()
            records[index].droppedOffBy = droppedOffBy
            records[index].checkInBy = "Sarah Mitchell"
            records[index].arrivalMood = mood
            records[index].parentNotes = parentNotes
            records[index].isAbsent = false
            records[index].absenceReason = ""
        } else {
            // Create new record
            let record = AttendanceRecord(
                childId: child.id,
                date: Date(),
                checkInTime: Date(),
                checkInBy: "Sarah Mitchell",
                droppedOffBy: droppedOffBy,
                arrivalMood: mood,
                parentNotes: parentNotes
            )
            records.append(record)
        }
        save()
    }

    // MARK: - Check Out

    func checkOut(
        child: ChildProfile,
        collectedBy: String,
        authorised: Bool,
        mood: String = "",
        handoverNotes: String = ""
    ) {
        let cal = Calendar.current
        if let index = records.firstIndex(where: {
            $0.childId == child.id && cal.isDateInToday($0.date)
        }) {
            records[index].checkOutTime = Date()
            records[index].collectedBy = collectedBy
            records[index].collectorAuthorised = authorised
            records[index].departureMood = mood
            records[index].handoverNotes = handoverNotes
        }
        save()
    }

    // MARK: - Mark Absent

    func markAbsent(child: ChildProfile, reason: String) {
        let cal = Calendar.current
        if let index = records.firstIndex(where: {
            $0.childId == child.id && cal.isDateInToday($0.date)
        }) {
            records[index].isAbsent = true
            records[index].absenceReason = reason
            records[index].checkInTime = nil
            records[index].checkOutTime = nil
        } else {
            let record = AttendanceRecord(
                childId: child.id,
                date: Date(),
                isAbsent: true,
                absenceReason: reason
            )
            records.append(record)
        }
        save()
    }

    // MARK: - All Children Checked Out

    func allCheckedOut(childIds: [UUID]) -> Bool {
        childIds.allSatisfy { id in
            let s = state(for: id)
            return s == .checkedOut || s == .absent
        }
    }

    // MARK: - Persistence

    private func save() {
        if let data = try? encoder.encode(records) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadRecords() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let loaded = try? decoder.decode([AttendanceRecord].self, from: data) {
            self.records = loaded
        }

        // If no records for today, create sample data
        let cal = Calendar.current
        let hasTodayRecords = records.contains { cal.isDateInToday($0.date) }
        if !hasTodayRecords {
            loadSampleData()
        }
    }

    // MARK: - Sample Data

    func loadSampleData() {
        let children = SampleData.children
        let today = Date()

        // Ollie: checked in 8:45am
        let ollieCheckIn = AttendanceRecord(
            childId: children[0].id,
            date: today,
            checkInTime: today.settingTime(hour: 8, minute: 45),
            checkInBy: "Sarah Mitchell",
            droppedOffBy: "Mrs Thompson (Mum)",
            arrivalMood: "😊"
        )

        // Amara: checked in 9:02am
        let amaraCheckIn = AttendanceRecord(
            childId: children[1].id,
            date: today,
            checkInTime: today.settingTime(hour: 9, minute: 2),
            checkInBy: "Sarah Mitchell",
            droppedOffBy: "Mr Okafor (Dad)",
            arrivalMood: "😊"
        )

        // Sophie: NOT yet checked in (expected)
        let sophieExpected = AttendanceRecord(
            childId: children[2].id,
            date: today
        )

        // Muhammad: checked in 9:15am
        let muhammadCheckIn = AttendanceRecord(
            childId: children[3].id,
            date: today,
            checkInTime: today.settingTime(hour: 9, minute: 15),
            checkInBy: "Sarah Mitchell",
            droppedOffBy: "Mrs Hassan (Mum)",
            arrivalMood: "🙂"
        )

        // Lily: marked ABSENT
        let lilyAbsent = AttendanceRecord(
            childId: children[4].id,
            date: today,
            isAbsent: true,
            absenceReason: "Unwell (cold)"
        )

        // Freddie: checked in 9:30am
        let freddieCheckIn = AttendanceRecord(
            childId: children[5].id,
            date: today,
            checkInTime: today.settingTime(hour: 9, minute: 30),
            checkInBy: "Sarah Mitchell",
            droppedOffBy: "Mr Baker (Dad)",
            arrivalMood: "🤩"
        )

        // Remove any existing today records before adding samples
        let cal = Calendar.current
        records.removeAll { cal.isDateInToday($0.date) }
        records.append(contentsOf: [
            ollieCheckIn, amaraCheckIn, sophieExpected,
            muhammadCheckIn, lilyAbsent, freddieCheckIn
        ])
        save()
    }
}
