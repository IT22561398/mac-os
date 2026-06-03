// ManagerModels.swift
// NurseryConnect — Setting Manager (macOS)
// New data models for Assignment 2 — extends Assignment 1 Models.swift
// Includes: ChildWellbeingAlert, SentimentAnalysisResult, SettingManagerProfile

import Foundation
import SwiftUI

// MARK: - Setting Manager Profile
struct SettingManagerProfile: Codable, Identifiable {
    let id: UUID
    var fullName: String
    var role: String
    var nurseryName: String
    var roomsManaged: [String]
    var lastLoginAt: Date
    
    var initials: String {
        let parts = fullName.split(separator: " ")
        let f = parts.first?.prefix(1) ?? ""
        let l = parts.count > 1 ? parts.last!.prefix(1) : ""
        return "\(f)\(l)"
    }
}

// MARK: - Child Wellbeing Alert
struct ChildWellbeingAlert: Identifiable, Codable {
    let id: UUID
    let childId: UUID
    let childName: String
    let alertType: WellbeingAlertType
    let wellbeingScore: Double
    let triggeredAt: Date
    let recommendedAction: String
    
    init(
        id: UUID = UUID(),
        childId: UUID,
        childName: String,
        alertType: WellbeingAlertType,
        wellbeingScore: Double,
        triggeredAt: Date = Date(),
        recommendedAction: String
    ) {
        self.id = id
        self.childId = childId
        self.childName = childName
        self.alertType = alertType
        self.wellbeingScore = wellbeingScore
        self.triggeredAt = triggeredAt
        self.recommendedAction = recommendedAction
    }
}

// MARK: - Wellbeing Alert Type
enum WellbeingAlertType: String, Codable, CaseIterable {
    case lowWellbeingScore
    case concernFlagged
    case overdueMealEntry
    case incidentOverdue
    case eyfsGap
    
    var displayName: String {
        switch self {
        case .lowWellbeingScore: return "Low Wellbeing Score"
        case .concernFlagged: return "Concern Flagged"
        case .overdueMealEntry: return "Overdue Meal Entry"
        case .incidentOverdue: return "Incident Notification Overdue"
        case .eyfsGap: return "EYFS Coverage Gap"
        }
    }
    
    var iconName: String {
        switch self {
        case .lowWellbeingScore: return "heart.slash.fill"
        case .concernFlagged: return "exclamationmark.bubble.fill"
        case .overdueMealEntry: return "fork.knife.circle"
        case .incidentOverdue: return "clock.badge.exclamationmark"
        case .eyfsGap: return "chart.bar.xaxis"
        }
    }
    
    var severityColor: Color {
        switch self {
        case .lowWellbeingScore: return .ncSecondary
        case .concernFlagged: return .ncSecondary
        case .overdueMealEntry: return .ncWarning
        case .incidentOverdue: return .ncSecondary
        case .eyfsGap: return .ncWarning
        }
    }
}

// MARK: - Sentiment Analysis Result
struct SentimentAnalysisResult: Identifiable, Codable {
    let id: UUID
    let diaryEntryId: UUID
    let rawSentimentScore: Double
    let normalizedScore: Double
    let sentiment: SentimentCategory
    let extractedKeywords: [String]
    let analyzedAt: Date
    
    enum SentimentCategory: String, Codable, CaseIterable {
        case positive
        case neutral
        case concern
        
        var displayName: String {
            switch self {
            case .positive: return "Positive development"
            case .neutral: return "Neutral observation"
            case .concern: return "Concern flagged"
            }
        }
        
        var color: Color {
            switch self {
            case .positive: return .ncSuccess
            case .neutral: return .ncWarning
            case .concern: return .ncSecondary
            }
        }
        
        var icon: String {
            switch self {
            case .positive: return "checkmark.circle.fill"
            case .neutral: return "minus.circle.fill"
            case .concern: return "exclamationmark.triangle.fill"
            }
        }
    }
    
    init(
        id: UUID = UUID(),
        diaryEntryId: UUID,
        rawSentimentScore: Double,
        normalizedScore: Double,
        sentiment: SentimentCategory,
        extractedKeywords: [String],
        analyzedAt: Date = Date()
    ) {
        self.id = id
        self.diaryEntryId = diaryEntryId
        self.rawSentimentScore = rawSentimentScore
        self.normalizedScore = normalizedScore
        self.sentiment = sentiment
        self.extractedKeywords = extractedKeywords
        self.analyzedAt = analyzedAt
    }
    
    /// Convenience initializer from raw NL analysis output
    init(
        diaryEntryId: UUID,
        rawScore: Double,
        normalized: Double,
        category: SentimentCategory,
        keywords: [String]
    ) {
        self.id = UUID()
        self.diaryEntryId = diaryEntryId
        self.rawSentimentScore = rawScore
        self.normalizedScore = normalized
        self.sentiment = category
        self.extractedKeywords = keywords
        self.analyzedAt = Date()
    }
}

// MARK: - Sidebar Navigation Item
enum SidebarItem: String, CaseIterable, Identifiable {
    case overview = "Overview"
    case allChildren = "All Children"
    case incidentQueue = "Incident Queue"
    case aiInsights = "AI Insights"
    case reports = "Reports"
    case settings = "Settings"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .overview: return "house.fill"
        case .allChildren: return "person.3.fill"
        case .incidentQueue: return "exclamationmark.triangle.fill"
        case .aiInsights: return "brain.head.profile"
        case .reports: return "doc.text.fill"
        case .settings: return "gearshape.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .overview: return .ncPrimary
        case .allChildren: return .ncActivityReading
        case .incidentQueue: return .ncSecondary
        case .aiInsights: return .ncPrimary
        case .reports: return .ncWarning
        case .settings: return .ncTextSecondary
        }
    }
}

// MARK: - Report Type
enum ReportType: String, CaseIterable, Identifiable {
    case weeklySummary = "Weekly Summary"
    case incidentReport = "Incident Report"
    case eyfsCoverage = "EYFS Coverage Report"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .weeklySummary: return "calendar"
        case .incidentReport: return "exclamationmark.shield"
        case .eyfsCoverage: return "chart.bar.doc.horizontal"
        }
    }
}

// MARK: - EYFS Areas (Early Years Foundation Stage)
enum EYFSArea: String, CaseIterable, Identifiable {
    case communicationAndLanguage = "Communication & Language"
    case physicalDevelopment = "Physical Development"
    case personalSocialEmotional = "Personal, Social & Emotional"
    case literacy = "Literacy"
    case mathematics = "Mathematics"
    case understandingTheWorld = "Understanding the World"
    case expressiveArtsAndDesign = "Expressive Arts & Design"
    
    var id: String { rawValue }
    
    var shortName: String {
        switch self {
        case .communicationAndLanguage: return "Comms"
        case .physicalDevelopment: return "Physical"
        case .personalSocialEmotional: return "PSED"
        case .literacy: return "Literacy"
        case .mathematics: return "Maths"
        case .understandingTheWorld: return "World"
        case .expressiveArtsAndDesign: return "Arts"
        }
    }
    
    var color: Color {
        switch self {
        case .communicationAndLanguage: return .ncPrimary
        case .physicalDevelopment: return .ncSuccess
        case .personalSocialEmotional: return .ncActivityReading
        case .literacy: return .ncWarning
        case .mathematics: return .ncActivityPlay
        case .understandingTheWorld: return .ncActivityOutdoor
        case .expressiveArtsAndDesign: return .ncActivityArts
        }
    }
    
    /// Map activity-level EYFS tags to this enum
    static func from(tag: String) -> EYFSArea? {
        let lowered = tag.lowercased()
        if lowered.contains("communication") || lowered.contains("language") {
            return .communicationAndLanguage
        } else if lowered.contains("physical") {
            return .physicalDevelopment
        } else if lowered.contains("personal") || lowered.contains("social") || lowered.contains("emotional") || lowered.contains("psed") {
            return .personalSocialEmotional
        } else if lowered.contains("literacy") || lowered.contains("reading") || lowered.contains("writing") {
            return .literacy
        } else if lowered.contains("math") || lowered.contains("number") {
            return .mathematics
        } else if lowered.contains("world") || lowered.contains("understanding") || lowered.contains("science") {
            return .understandingTheWorld
        } else if lowered.contains("expressive") || lowered.contains("art") || lowered.contains("design") || lowered.contains("music") || lowered.contains("creative") {
            return .expressiveArtsAndDesign
        }
        return nil
    }
}

// MARK: - Wellbeing Trend Direction
enum WellbeingTrend: String {
    case improving = "Improving"
    case declining = "Declining"
    case stable = "Stable"
    
    var icon: String {
        switch self {
        case .improving: return "arrow.up.right"
        case .declining: return "arrow.down.right"
        case .stable: return "arrow.right"
        }
    }
    
    var color: Color {
        switch self {
        case .improving: return .ncSuccess
        case .declining: return .ncSecondary
        case .stable: return .ncPrimary
        }
    }
}

// MARK: - Manager Constants
struct ManagerConstants {
    // Labels
    static let appTitle = "NurseryConnect"
    static let appSubtitle = "Setting Manager Dashboard"
    static let nurseryName = "Little Stars Nursery & Daycare"
    
    // Time thresholds
    static let parentNotificationDeadlineHours: Double = 4.0
    static let wellbeingScoreLowThreshold: Double = 50.0
    static let wellbeingScoreHighThreshold: Double = 75.0
    static let concernFlaggedDays: Int = 3
    static let concernFlaggedMinCount: Int = 2
    static let analysisWindowDays: Int = 14
    static let recentWindowDays: Int = 7
    
    // Sentiment thresholds (raw -1.0 to 1.0)
    static let sentimentPositiveRawThreshold: Double = 0.6
    static let sentimentNeutralRawThreshold: Double = 0.2
    
    // Layout
    static let sidebarWidth: CGFloat = 220
    static let cardCornerRadius: CGFloat = 12
    static let metricCardMinWidth: CGFloat = 200
    
    // Staff ratios (Ofsted requirements)
    static let staffRatioUnder2 = "1:3"
    static let staffRatio2to3 = "1:4"
    static let staffRatio3Plus = "1:8"
}
