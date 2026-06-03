// Models.swift
// NurseryConnect
// All data models for the application - Codable for JSON persistence

import Foundation
import SwiftUI

// MARK: - Keyworker Profile (FR-12, Section 4.2.3)
struct KeyworkerProfile: Codable, Identifiable {
    let id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var roomAssignment: String
    var assignedChildrenIds: [UUID]
    var profileImageName: String
    var qualification: String
    var startDate: Date
    
    var fullName: String { "\(firstName) \(lastName)" }
    var initials: String {
        let f = firstName.prefix(1)
        let l = lastName.prefix(1)
        return "\(f)\(l)"
    }
}

// MARK: - Child Profile (Section 7.2)
struct ChildProfile: Codable, Identifiable, Hashable {
    let id: UUID
    var firstName: String
    var lastName: String
    var preferredName: String
    var dateOfBirth: Date
    var roomAssignment: String
    var profileColor: String // hex color for avatar
    
    // Family Details
    var parentName: String
    var parentEmail: String
    var parentPhone: String
    var emergencyContact: String
    var emergencyPhone: String
    
    // Health & Medical (Section 7.2)
    var medicalConditions: [String]
    var allergies: [Allergen]
    var dietaryRequirements: [String]
    
    // Consent Records (Section 8.2)
    var photographyConsent: Bool
    var socialMediaConsent: Bool
    var dataProcessingConsent: Bool
    
    // Session
    var sessionTimes: String // e.g. "8:00 AM - 5:30 PM"
    var isActive: Bool
    
    var fullName: String { "\(firstName) \(lastName)" }
    var displayName: String { preferredName.isEmpty ? firstName : preferredName }
    var age: String { dateOfBirth.ageString }
    var initials: String {
        let f = firstName.prefix(1)
        let l = lastName.prefix(1)
        return "\(f)\(l)"
    }
    
    var avatarColor: Color {
        Color(hex: profileColor)
    }
    
    var hasAllergies: Bool { !allergies.isEmpty }
    var hasMedicalConditions: Bool { !medicalConditions.isEmpty }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ChildProfile, rhs: ChildProfile) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Allergen (Section 10.3 - 14 EU/UK major allergens)
struct Allergen: Codable, Identifiable {
    let id: UUID
    var name: String
    var severity: AllergenSeverity
    var notes: String
    
    init(id: UUID = UUID(), name: String, severity: AllergenSeverity, notes: String = "") {
        self.id = id
        self.name = name
        self.severity = severity
        self.notes = notes
    }
}

// MARK: - Diary Entry (Section 7.3)
struct DiaryEntry: Codable, Identifiable {
    let id: UUID
    var childId: UUID
    var keyworkerId: UUID
    var type: DiaryEntryType
    var timestamp: Date
    var notes: String
    
    // Activity fields (FR-13)
    var activityType: ActivityType?
    var activityDuration: Int? // minutes
    var eyfsArea: String?
    
    // Sleep fields (FR-14)
    var sleepStartTime: Date?
    var sleepEndTime: Date?
    var sleepPosition: SleepPosition?
    var sleepDurationMinutes: Int?
    var sleepDisturbances: String?
    
    // Nappy fields (FR-15)
    var nappyType: NappyType?
    var nappyConcerns: String?
    var creamApplied: Bool?
    
    // Meal fields (FR-30, FR-31)
    var mealType: MealType?
    var foodOffered: String?
    var portionConsumed: PortionConsumed?
    var drinkType: DrinkType?
    var drinkAmountMl: Int?
    
    // Wellbeing fields (FR-16)
    var moodRating: MoodRating?
    var wellbeingCheckTime: WellbeingCheckTime?
    var physicalAppearance: String?
    var socialEngagement: String?

    // Arrival fields
    var arrivalTime: Date?
    var droppedOffBy: String?
    var arrivalMood: MoodRating?
    var parentalNotes: String?

    // Departure fields
    var departureTime: Date?
    var collectedBy: String?
    var authorisedCollector: Bool?
    var departureMood: MoodRating?
    var handoverNotes: String?

    // Milestone fields
    var milestoneEyfsArea: String?
    var milestoneDescription: String?
    var milestoneNextSteps: String?
    var milestoneDate: Date?
    
    init(
        id: UUID = UUID(),
        childId: UUID,
        keyworkerId: UUID,
        type: DiaryEntryType,
        timestamp: Date = Date(),
        notes: String = "",
        activityType: ActivityType? = nil,
        activityDuration: Int? = nil,
        eyfsArea: String? = nil,
        sleepStartTime: Date? = nil,
        sleepEndTime: Date? = nil,
        sleepPosition: SleepPosition? = nil,
        sleepDurationMinutes: Int? = nil,
        sleepDisturbances: String? = nil,
        nappyType: NappyType? = nil,
        nappyConcerns: String? = nil,
        creamApplied: Bool? = nil,
        mealType: MealType? = nil,
        foodOffered: String? = nil,
        portionConsumed: PortionConsumed? = nil,
        drinkType: DrinkType? = nil,
        drinkAmountMl: Int? = nil,
        moodRating: MoodRating? = nil,
        wellbeingCheckTime: WellbeingCheckTime? = nil,
        physicalAppearance: String? = nil,
        socialEngagement: String? = nil,
        arrivalTime: Date? = nil,
        droppedOffBy: String? = nil,
        arrivalMood: MoodRating? = nil,
        parentalNotes: String? = nil,
        departureTime: Date? = nil,
        collectedBy: String? = nil,
        authorisedCollector: Bool? = nil,
        departureMood: MoodRating? = nil,
        handoverNotes: String? = nil,
        milestoneEyfsArea: String? = nil,
        milestoneDescription: String? = nil,
        milestoneNextSteps: String? = nil,
        milestoneDate: Date? = nil
    ) {
        self.id = id
        self.childId = childId
        self.keyworkerId = keyworkerId
        self.type = type
        self.timestamp = timestamp
        self.notes = notes
        self.activityType = activityType
        self.activityDuration = activityDuration
        self.eyfsArea = eyfsArea
        self.sleepStartTime = sleepStartTime
        self.sleepEndTime = sleepEndTime
        self.sleepPosition = sleepPosition
        self.sleepDurationMinutes = sleepDurationMinutes
        self.sleepDisturbances = sleepDisturbances
        self.nappyType = nappyType
        self.nappyConcerns = nappyConcerns
        self.creamApplied = creamApplied
        self.mealType = mealType
        self.foodOffered = foodOffered
        self.portionConsumed = portionConsumed
        self.drinkType = drinkType
        self.drinkAmountMl = drinkAmountMl
        self.moodRating = moodRating
        self.wellbeingCheckTime = wellbeingCheckTime
        self.physicalAppearance = physicalAppearance
        self.socialEngagement = socialEngagement
        self.arrivalTime = arrivalTime
        self.droppedOffBy = droppedOffBy
        self.arrivalMood = arrivalMood
        self.parentalNotes = parentalNotes
        self.departureTime = departureTime
        self.collectedBy = collectedBy
        self.authorisedCollector = authorisedCollector
        self.departureMood = departureMood
        self.handoverNotes = handoverNotes
        self.milestoneEyfsArea = milestoneEyfsArea
        self.milestoneDescription = milestoneDescription
        self.milestoneNextSteps = milestoneNextSteps
        self.milestoneDate = milestoneDate
    }
    
    // Display helpers
    var displayTitle: String {
        switch type {
        case .arrival:
            var parts: [String] = []
            if let by = droppedOffBy, !by.isEmpty { parts.append("Dropped off by \(by)") }
            if let mood = arrivalMood { parts.append("\(mood.emoji) \(mood.rawValue)") }
            if let notes = parentalNotes, !notes.isEmpty { parts.append(notes) }
            return parts.joined(separator: " · ")
        case .departure:
            var parts: [String] = []
            if let by = collectedBy, !by.isEmpty { parts.append("Collected by \(by)") }
            if let mood = departureMood { parts.append("\(mood.emoji) \(mood.rawValue)") }
            if let notes = handoverNotes, !notes.isEmpty { parts.append(notes) }
            return parts.joined(separator: " · ")
        case .milestone:
            if let area = milestoneEyfsArea, !area.isEmpty {
                return "Milestone \u{2022} \(area)"
            }
            return "Milestone"
        case .nappy:
            return nappyType?.rawValue ?? "Nappy Change"
        case .wellbeing:
            return "\(wellbeingCheckTime?.rawValue ?? "") Wellbeing"
        case .activity:
            return activityType?.rawValue ?? "Activity"
        case .sleep:
            return "Sleep"
        case .meal:
            return mealType?.rawValue ?? "Meal"
        case .note:
            return "Note"
        }
    }
    
    var displayIcon: String {
        switch type {
        case .activity: return activityType?.icon ?? type.icon
        case .meal: return mealType?.icon ?? type.icon
        case .nappy: return nappyType?.icon ?? type.icon
        default: return type.icon
        }
    }
    
    var displayColor: Color {
        switch type {
        case .activity: return activityType?.color ?? type.color
        case .nappy: return nappyType?.color ?? type.color
        case .wellbeing: return moodRating?.color ?? type.color
        default: return type.color
        }
    }
    
    var displaySubtitle: String {
        switch type {
        case .activity:
            if let dur = activityDuration {
                return "\(dur) min — \(notes)"
            }
            return notes
        case .sleep:
            if let start = sleepStartTime, let end = sleepEndTime {
                return "\(start.time12String) – \(end.time12String)"
            }
            return notes
        case .nappy:
            var parts: [String] = []
            if let nt = nappyType { parts.append(nt.rawValue) }
            if let cream = creamApplied, cream { parts.append("Cream applied") }
            if !notes.isEmpty { parts.append(notes) }
            return parts.joined(separator: " · ")
        case .meal:
            var parts: [String] = []
            if let food = foodOffered { parts.append(food) }
            if let portion = portionConsumed { parts.append("Ate: \(portion.rawValue)") }
            return parts.joined(separator: " · ")
        case .wellbeing:
            if let mood = moodRating {
                return "\(mood.emoji) \(mood.rawValue)"
            }
            return notes
        case .note:
            return notes
        case .arrival:
            var parts: [String] = []
            if let time = arrivalTime { parts.append(time.time12String) }
            if !notes.isEmpty { parts.append(notes) }
            return parts.joined(separator: " · ")
        case .departure:
            var parts: [String] = []
            if let time = departureTime { parts.append(time.time12String) }
            if !notes.isEmpty { parts.append(notes) }
            return parts.joined(separator: " · ")
        case .milestone:
            var parts: [String] = []
            if let area = milestoneEyfsArea { parts.append(area) }
            if !notes.isEmpty { parts.append(notes) }
            return parts.joined(separator: " · ")
        }
    }
}

// MARK: - Incident (Section 7.4, FR-24 to FR-29)
struct Incident: Codable, Identifiable, Hashable {
    let id: UUID
    var childId: UUID
    var keyworkerId: UUID
    var category: IncidentCategory
    var status: IncidentStatus
    var dateTime: Date
    var location: String
    var description: String
    var immediateActionTaken: String
    var witnesses: [String]
    
    // Body map data
    var bodyMapMarkers: [BodyMapMarker]
    
    // Workflow timestamps
    var submittedAt: Date?
    var reviewedAt: Date?
    var countersignedAt: Date?
    var parentNotifiedAt: Date?
    var acknowledgedAt: Date?
    
    // Manager
    var reviewerName: String?
    var reviewNotes: String?
    
    init(
        id: UUID = UUID(),
        childId: UUID,
        keyworkerId: UUID,
        category: IncidentCategory,
        status: IncidentStatus = .draft,
        dateTime: Date = Date(),
        location: String = "",
        description: String = "",
        immediateActionTaken: String = "",
        witnesses: [String] = [],
        bodyMapMarkers: [BodyMapMarker] = [],
        submittedAt: Date? = nil,
        reviewedAt: Date? = nil,
        countersignedAt: Date? = nil,
        parentNotifiedAt: Date? = nil,
        acknowledgedAt: Date? = nil,
        reviewerName: String? = nil,
        reviewNotes: String? = nil
    ) {
        self.id = id
        self.childId = childId
        self.keyworkerId = keyworkerId
        self.category = category
        self.status = status
        self.dateTime = dateTime
        self.location = location
        self.description = description
        self.immediateActionTaken = immediateActionTaken
        self.witnesses = witnesses
        self.bodyMapMarkers = bodyMapMarkers
        self.submittedAt = submittedAt
        self.reviewedAt = reviewedAt
        self.countersignedAt = countersignedAt
        self.parentNotifiedAt = parentNotifiedAt
        self.acknowledgedAt = acknowledgedAt
        self.reviewerName = reviewerName
        self.reviewNotes = reviewNotes
    }
    
    var isSerious: Bool {
        category.severity == .high
    }
    
    var childName: String? { nil } // Resolved from DataManager

    // Hashable & Equatable conformance (by stable id)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Incident, rhs: Incident) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Body Map Marker (from FR-24 body map diagram)
struct BodyMapMarker: Codable, Identifiable {
    let id: UUID
    var side: BodyMapSide
    var xPercent: CGFloat // 0-1 relative position
    var yPercent: CGFloat // 0-1 relative position
    var label: String
    
    init(id: UUID = UUID(), side: BodyMapSide, xPercent: CGFloat, yPercent: CGFloat, label: String = "") {
        self.id = id
        self.side = side
        self.xPercent = xPercent
        self.yPercent = yPercent
        self.label = label
    }
}
