// Constants.swift
// NurseryConnect
// App-wide constants, color palette, and configuration

import SwiftUI

// MARK: - App Configuration
struct AppConfig {
    static let appName = "NurseryConnect"
    static let tagline = "Caring Together, Connected Always"
    static let sessionTimeoutMinutes = 5
    static let maxLoginAttempts = 5
    static let nurseryName = "Little Stars Nursery & Daycare"
}

// MARK: - Color Palette ("Aurora" — modern revamp 2026)
// A contemporary indigo→violet identity with warm rose accents.
// Clean, airy surfaces in light mode; deep, calm slate surfaces in dark mode.
extension Color {
    // Primary Colors
    static let ncPrimary = Color(hex: "6366F1")        // Indigo - trust, focus, modern
    static let ncSecondary = Color(hex: "FB7185")       // Soft Rose - warmth, energy
    static let ncAccent = Color(hex: "FBBF24")          // Amber - happiness, childhood
    
    // Background Colors
    static let ncBackgroundLight = Color(hex: "F5F6FB") // Cool airy off-white
    static let ncBackgroundDark = Color(hex: "0E1016")  // Modern near-black slate
    
    // Semantic Colors
    static let ncSuccess = Color(hex: "34D399")         // Emerald
    static let ncWarning = Color(hex: "F59E0B")         // Amber Orange
    static let ncError = Color(hex: "F43F5E")           // Rose Red
    
    // Text Colors
    static let ncTextPrimary = Color(hex: "1A1D27")     // Slate Ink
    static let ncTextSecondary = Color(hex: "6E7689")   // Cool Gray
    
    // Additional UI Colors
    static let ncCardBackground = Color(hex: "FFFFFF")
    static let ncDivider = Color(hex: "ECEEF4")
    static let ncShadow = Color.black.opacity(0.06)
    
    // Gradient Colors
    static let ncGradientStart = Color(hex: "6366F1")   // Indigo
    static let ncGradientEnd = Color(hex: "8B5CF6")     // Violet
    static let ncGradientWarm = Color(hex: "FB7185")    // Rose
    static let ncGradientSunset = Color(hex: "C084FC")  // Soft Purple
    
    // Activity Type Colors
    static let ncActivityPlay = Color(hex: "60A5FA")
    static let ncActivityReading = Color(hex: "A78BFA")
    static let ncActivityArts = Color(hex: "F472B6")
    static let ncActivityEducation = Color(hex: "34D399")
    static let ncActivityRest = Color(hex: "CBD5E1")
    static let ncActivityOutdoor = Color(hex: "2DD4BF")
    
    // Mood Colors
    static let ncMoodHappy = Color(hex: "34D399")
    static let ncMoodNeutral = Color(hex: "FCD34D")
    static let ncMoodUnsettled = Color(hex: "FBBF24")
    static let ncMoodPoorly = Color(hex: "FB7185")
}

// MARK: - Color Hex Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Font Helpers (SF Pro Rounded for headlines, SF Pro Text for body)
extension Font {
    static func ncHeadline(_ size: CGFloat = 24) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    
    static func ncTitle(_ size: CGFloat = 20) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    
    static func ncBody(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
    
    static func ncCaption(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .light, design: .default)
    }
    
    static func ncMono(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
    
    static func ncButtonFont(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
}

// MARK: - Activity Types (from FR-13)
enum ActivityType: String, CaseIterable, Identifiable, Codable {
    case indoorPlay = "Indoor Play"
    case outdoorPlay = "Outdoor Play"
    case reading = "Reading"
    case artsAndCrafts = "Arts & Crafts"
    case educational = "Educational Session"
    case freePlay = "Free Play"
    case restPeriod = "Rest Period"
    case music = "Music & Movement"
    case sensory = "Sensory Play"
    case socialPlay = "Social Play"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .indoorPlay: return "house.fill"
        case .outdoorPlay: return "sun.max.fill"
        case .reading: return "book.fill"
        case .artsAndCrafts: return "paintpalette.fill"
        case .educational: return "graduationcap.fill"
        case .freePlay: return "figure.play"
        case .restPeriod: return "moon.zzz.fill"
        case .music: return "music.note"
        case .sensory: return "hand.raised.fingers.spread.fill"
        case .socialPlay: return "person.2.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .indoorPlay: return .ncActivityPlay
        case .outdoorPlay: return .ncActivityOutdoor
        case .reading: return .ncActivityReading
        case .artsAndCrafts: return .ncActivityArts
        case .educational: return .ncActivityEducation
        case .freePlay: return .ncPrimary
        case .restPeriod: return .ncActivityRest
        case .music: return .ncGradientSunset
        case .sensory: return .ncAccent
        case .socialPlay: return .ncWarning
        }
    }
}

// MARK: - Meal Types (from FR-30)
enum MealType: String, CaseIterable, Identifiable, Codable {
    case breakfast = "Breakfast"
    case morningSnack = "Morning Snack"
    case lunch = "Lunch"
    case afternoonSnack = "Afternoon Snack"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .morningSnack: return "carrot.fill"
        case .lunch: return "fork.knife"
        case .afternoonSnack: return "cup.and.saucer.fill"
        }
    }
}

// MARK: - Portion Sizes (from FR-30)
enum PortionConsumed: String, CaseIterable, Identifiable, Codable {
    case all = "All"
    case most = "Most"
    case half = "Half"
    case little = "A Little"
    case none = "None"
    case refused = "Refused"
    
    var id: String { rawValue }
    
    var color: Color {
        switch self {
        case .all: return .ncSuccess
        case .most: return .ncPrimary
        case .half: return .ncAccent
        case .little: return .ncWarning
        case .none, .refused: return .ncError
        }
    }
    
    var emoji: String {
        switch self {
        case .all: return "😋"
        case .most: return "🙂"
        case .half: return "😐"
        case .little: return "😕"
        case .none: return "🚫"
        case .refused: return "🙅"
        }
    }
}

// MARK: - Drink Types (from FR-31)
enum DrinkType: String, CaseIterable, Identifiable, Codable {
    case water = "Water"
    case milk = "Milk"
    case dilutedJuice = "Diluted Juice"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .water: return "drop.fill"
        case .milk: return "cup.and.saucer.fill"
        case .dilutedJuice: return "wineglass.fill"
        }
    }
}

// MARK: - Nappy Types (from FR-15)
enum NappyType: String, CaseIterable, Identifiable, Codable {
    case wet = "Wet"
    case dirty = "Dirty"
    case both = "Both"
    case dry = "Dry (checked)"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .wet: return "drop.fill"
        case .dirty: return "leaf.fill"
        case .both: return "drop.triangle.fill"
        case .dry: return "checkmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .wet: return .ncActivityPlay
        case .dirty: return .ncWarning
        case .both: return .ncSecondary
        case .dry: return .ncSuccess
        }
    }
}

// MARK: - Sleep Position (from FR-14)
enum SleepPosition: String, CaseIterable, Identifiable, Codable {
    case back = "Back"
    case side = "Side"
    case front = "Front"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .back: return "figure.cooldown"
        case .side: return "figure.roll"
        case .front: return "figure.mind.and.body"
        }
    }
}

// MARK: - Mood/Wellbeing (from FR-16)
enum MoodRating: String, CaseIterable, Identifiable, Codable {
    case happy = "Happy"
    case content = "Content"
    case unsettled = "Unsettled"
    case poorly = "Poorly"
    case upset = "Upset"
    
    var id: String { rawValue }
    
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .content: return "🙂"
        case .unsettled: return "😟"
        case .poorly: return "🤒"
        case .upset: return "😢"
        }
    }
    
    var color: Color {
        switch self {
        case .happy: return .ncMoodHappy
        case .content: return .ncPrimary
        case .unsettled: return .ncMoodUnsettled
        case .poorly: return .ncMoodPoorly
        case .upset: return .ncSecondary
        }
    }
}

// MARK: - Wellbeing Check Time
enum WellbeingCheckTime: String, CaseIterable, Identifiable, Codable {
    case arrival = "Arrival"
    case midday = "Midday"
    case departure = "Departure"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .arrival: return "sunrise.fill"
        case .midday: return "sun.max.fill"
        case .departure: return "sunset.fill"
        }
    }
}

// MARK: - Incident Categories (from FR-25)
enum IncidentCategory: String, CaseIterable, Identifiable, Codable {
    case minorAccident = "Minor Accident"
    case firstAidRequired = "Accident (First Aid)"
    case safeguardingConcern = "Safeguarding Concern"
    case nearMiss = "Near Miss"
    case allergicReaction = "Allergic Reaction"
    case medicalIncident = "Medical Incident"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .minorAccident: return "bandage.fill"
        case .firstAidRequired: return "cross.case.fill"
        case .safeguardingConcern: return "shield.fill"
        case .nearMiss: return "exclamationmark.triangle.fill"
        case .allergicReaction: return "allergens.fill"
        case .medicalIncident: return "staroflife.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .minorAccident: return .ncWarning
        case .firstAidRequired: return .ncSecondary
        case .safeguardingConcern: return Color(hex: "E74C3C")
        case .nearMiss: return .ncAccent
        case .allergicReaction: return Color(hex: "E056A0")
        case .medicalIncident: return Color(hex: "3498DB")
        }
    }
    
    var severity: IncidentSeverity {
        switch self {
        case .minorAccident, .nearMiss: return .low
        case .firstAidRequired, .allergicReaction: return .medium
        case .safeguardingConcern, .medicalIncident: return .high
        }
    }
}

// MARK: - Incident Severity
enum IncidentSeverity: String, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var color: Color {
        switch self {
        case .low: return .ncWarning
        case .medium: return .ncSecondary
        case .high: return Color(hex: "E74C3C")
        }
    }
}

// MARK: - Incident Status (from workflow in Section 7.4)
enum IncidentStatus: String, CaseIterable, Identifiable, Codable {
    case draft = "Draft"
    case submitted = "Submitted"
    case underReview = "Under Review"
    case countersigned = "Countersigned"
    case parentNotified = "Parent Notified"
    case acknowledged = "Acknowledged"
    
    var id: String { rawValue }
    
    var color: Color {
        switch self {
        case .draft: return .ncTextSecondary
        case .submitted: return .ncPrimary
        case .underReview: return .ncWarning
        case .countersigned: return .ncActivityPlay
        case .parentNotified: return Color(hex: "A29BFE")
        case .acknowledged: return .ncSuccess
        }
    }
    
    var icon: String {
        switch self {
        case .draft: return "doc.fill"
        case .submitted: return "paperplane.fill"
        case .underReview: return "eye.fill"
        case .countersigned: return "signature"
        case .parentNotified: return "bell.fill"
        case .acknowledged: return "checkmark.seal.fill"
        }
    }
}

// MARK: - Diary Entry Type
enum DiaryEntryType: String, CaseIterable, Identifiable, Codable {
    case arrival = "Arrival"
    case departure = "Departure"
    case activity = "Activity"
    case meal = "Meal"
    case sleep = "Sleep"
    case nappy = "Nappy"
    case wellbeing = "Wellbeing"
    case milestone = "Milestone"
    case note = "Note"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .arrival: return "arrow.down.circle.fill"
        case .departure: return "arrow.up.circle.fill"
        case .activity: return "figure.play"
        case .meal: return "fork.knife"
        case .sleep: return "moon.zzz.fill"
        case .nappy: return "arrow.triangle.2.circlepath"
        case .wellbeing: return "heart.fill"
        case .milestone: return "flag.fill"
        case .note: return "note.text"
        }
    }
    
    var color: Color {
        switch self {
        case .arrival: return .ncSuccess
        case .departure: return .ncWarning
        case .activity: return .ncPrimary
        case .meal: return .ncSuccess
        case .sleep: return Color(hex: "A29BFE")
        case .nappy: return .ncWarning
        case .wellbeing: return .ncSecondary
        case .milestone: return .ncAccent
        case .note: return .ncTextSecondary
        }
    }
}

// MARK: - Body Map Side
enum BodyMapSide: String, CaseIterable, Identifiable, Codable {
    case front = "Front"
    case back = "Back"
    
    var id: String { rawValue }
}

// MARK: - Allergen Severity (from Section 10.3)
enum AllergenSeverity: String, CaseIterable, Identifiable, Codable {
    case intolerance = "Intolerance"
    case allergy = "Allergy"
    case anaphylactic = "Anaphylactic"
    
    var id: String { rawValue }
    
    var color: Color {
        switch self {
        case .intolerance: return .ncWarning
        case .allergy: return .ncSecondary
        case .anaphylactic: return Color(hex: "E74C3C")
        }
    }
}

extension ShapeStyle where Self == Color {
    static var ncPrimary: Color { Color.ncPrimary }
    static var ncSecondary: Color { Color.ncSecondary }
    static var ncSuccess: Color { Color.ncSuccess }
    static var ncWarning: Color { Color.ncWarning }
    static var ncBackground: Color { Color.ncBackground }
    static var ncCard: Color { Color.ncCard }
    static var ncText: Color { Color.ncText }
    static var ncTextSec: Color { Color.ncTextSec }
}
