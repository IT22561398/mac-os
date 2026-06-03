// ManagerText.swift
// NurseryConnect — Setting Manager (macOS)
// Centralized UI strings and labels

import Foundation

enum ManagerText {
    // App
    static let mainWindowTitle = "NurseryConnect — Setting Manager"
    static let childProfileWindowTitle = "Child Profile"
    static let settingManagerRole = "Setting Manager"
    static let analyzingLabel = "Analyzing..."
    static let unknownLabel = "Unknown"
    static let staffMemberLabel = "Staff Member"
    static let roomFilterAll = "All"

    // Menu
    enum Menu {
        static let reports = "Reports"
        static let view = "View"
        static let newIncidentWindow = "New Incident Review Window"
        static let exportWeeklySummary = "Export Weekly Summary"
        static let generateEyfsReport = "Generate EYFS Coverage Report"
        static let refreshAiAnalysis = "Refresh AI Analysis"
        static let overview = "Overview"
        static let allChildren = "All Children"
        static let incidentQueue = "Incident Queue"
        static let aiInsights = "AI Insights"
        static let reportsItem = "Reports"
    }

    // Toolbar
    enum Toolbar {
        static let toggleSidebarHelp = "Toggle Sidebar"
        static let refreshAiLabel = "Refresh AI Analysis"
        static let refreshAiHelp = "Refresh AI Wellbeing Analysis for all children"
    }

    // Sidebar
    enum Sidebar {
        static let dashboardSection = "Dashboard"
        static let managementSection = "Management"
        static let toolsSection = "Tools"
    }

    // Content placeholders
    enum EmptyState {
        static let selectChildTitle = "Select a Child"
        static let selectChildSubtitle = "Choose a child from the list to view their development analytics"
        static let noIncidentTitle = "No Incident Selected"
        static let noIncidentSubtitle = "Select an incident from the queue to review and countersign"
        static let reportPreviewTitle = "Report Preview"
        static let reportPreviewSubtitle = "Generate a report from the options panel to see the preview here"
        static let settingsTitle = "Settings"
        static let settingsSubtitle = "Application settings and preferences"
    }

    enum OverviewList {
        static let quickActions = "Quick Actions"
        static let actionViewChildren = "View All Children"
        static let actionReviewIncidents = "Review Incidents"
        static let actionGenerateReport = "Generate Report"
        static func recentAlerts(_ count: Int) -> String {
            "Recent Alerts (\(count))"
        }
    }

    // Children list
    enum Children {
        static let title = "All Children"
        static let searchPrompt = "Search children..."
        static let roomFilterLabel = "Room"
        static let roomFilterHelp = "Filter by room"
        static let openNewWindow = "Open in New Window"
        static let viewDiaryEntries = "View Diary Entries"
        static let viewIncidents = "View Incidents"
    }

    // Incident queue
    enum IncidentQueue {
        static let title = "Incident Queue"
        static let allClearTitle = "All Clear"
        static let allClearSubtitle = "No incidents pending countersignature"
        static let countersignAction = "Countersign"
        static let allIncidentsSection = "All Incidents"
    }

    // Incident review
    enum IncidentReview {
        static let title = "Incident Review"
        static let countersignDialogTitle = "Countersign Incident"
        static let countersignDialogMessage = "Are you sure you want to countersign this incident? This will advance the status and the parent will need to be notified."
        static let countersignConfirm = "Countersign"
        static let cancel = "Cancel"
        static let workflowTitle = "Workflow Timeline"
        static let submitted = "Submitted"
        static let reviewed = "Reviewed"
        static let countersigned = "Countersigned"
        static let parentNotified = "Parent Notified"
        static let acknowledged = "Acknowledged"
        static let pending = "Pending"
        static let parentNotificationPrefix = "Parent Notification:"
        static let naturalLanguageTitle = "NaturalLanguage Analysis"
        static let extractedLocationsLabel = "Extracted locations:"
        static let noLocations = "No specific locations extracted from description"
        static let descriptionTitle = "Incident Description"
        static let immediateActionTitle = "Immediate Action Taken"
        static let witnessesTitle = "Witnesses"
        static let reviewedByPrefix = "Reviewed by:"
        static let reviewNotesPrefix = "Review Notes:"
        static let bodyMapTitle = "Body Map Markers"
        static let countersignButton = "Countersign Incident"
        static let escalateButton = "Escalate to Ofsted"
        static let severityPrefix = "Severity:"
        static let positionPrefix = "Position:"
        static let notificationTitle = "Incident Countersigned"
        static func notificationBody(childName: String, reviewer: String) -> String {
            "Incident for \(childName) has been countersigned by \(reviewer). Parent notification pending."
        }
        static let deadlineParentNotified = "Parent notified"
        static let deadlineOverdue = "OVERDUE — Notify parent immediately"
        static func deadlineMinutesRemaining(_ minutes: Int) -> String {
            "\(minutes) minutes remaining"
        }
        static func deadlineHoursRemaining(_ hours: Double) -> String {
            String(format: "%.1f hours remaining", hours)
        }
    }

    // Dashboard
    enum Dashboard {
        static let title = "Dashboard Overview"
        static let aiAnalysisRunning = "AI Analysis Running..."
        static let attentionTitle = "Children Needing Attention"
        static let attentionAllClearTitle = "All children are within normal parameters"
        static let eyfsHeatmapTitle = "EYFS Coverage Heatmap — Last 7 Days"
        static func greeting(name: String, timeOfDay: String) -> String {
            "Good \(timeOfDay), \(name)!"
        }
        static func nurseryDate(_ nurseryName: String, date: String) -> String {
            "\(nurseryName) — \(date)"
        }
    }

    enum TimeOfDay {
        static let morning = "morning"
        static let afternoon = "afternoon"
        static let evening = "evening"
    }

    enum Metrics {
        static let childrenTodayTitle = "Children Today"
        static let childrenTodaySubtitle = "Checked in"
        static let pendingIncidentsTitle = "Pending Incidents"
        static let pendingIncidentsNeedsAttention = "Needs attention"
        static let pendingIncidentsAllClear = "All clear"
        static let wellbeingFlagsTitle = "AI Wellbeing Flags"
        static let wellbeingFlagsSubtitle = "Children flagged"
        static let wellbeingFlagsAllWell = "All well"
        static let staffRatioTitle = "Staff Ratio"
        static let staffRatioPrefix = "1:"
        static let staffRatioCompliant = "Compliant"
        static let staffRatioReview = "Review needed"
    }

    // AI insights
    enum AIInsights {
        static func concernsSection(_ count: Int) -> String {
            "Wellbeing Concerns (\(count))"
        }
        static let noConcerns = "No wellbeing concerns detected"
        static let allChildrenSection = "All Children — AI Scores"
        static let openNewWindow = "Open in New Window"
        static let viewDetails = "View Details"
        static let reviewButton = "Review"
        static let reviewHelp = "Open this child's profile in a separate window for review"
    }

    enum Alerts {
        static let lowWellbeingReason = "Low wellbeing score"
        static let concernFlaggedReason = "Concern flagged in recent diary entries"
        static let overdueIncidentReason = "Overdue incident notification"
        static let lowWellbeingAction = "Review recent diary entries and schedule a check-in with keyworker"
        static let concernFlaggedAction = "Multiple concern entries detected — review with keyworker immediately"
        static func eyfsGapAction(_ areas: String) -> String {
            "No activities logged for: \(areas). Plan activities to cover these areas."
        }
        static func incidentOverdueAction(_ date: String) -> String {
            "Parent notification overdue — notify parent immediately for incident on \(date)"
        }
    }

    // Child analytics
    enum ChildAnalytics {
        static let loading = "Analyzing development data..."
        static let childNotFound = "Child not found"
        static let keyworkerPrefix = "Keyworker:"
        static func navigationTitle(_ childName: String) -> String {
            "\(childName) — Development Analytics"
        }
        static func basedOnObservations(_ count: Int) -> String {
            "Based on \(count) diary observations"
        }
        static func updated(_ relative: String) -> String {
            "Updated \(relative)"
        }
        static let wellbeingTrendTitle = "Wellbeing Trend (14 Days)"
        static let moodDistributionTitle = "Mood Distribution (7 Days)"
        static let eyfsCoverageTitle = "EYFS Area Coverage (14 Days)"
        static let observationFeedTitle = "AI Observation Analysis Feed"
        static func observationCount(_ count: Int) -> String {
            "\(count) entries"
        }
    }

    // Sentiment feed
    enum SentimentFeed {
        static let rawPrefix = "Raw:"
        static let normalizedPrefix = "Normalized:"
        static let keyworkerPrefix = "Keyworker:"
    }

    // Reports
    enum Reports {
        static let title = "Reports"
        static let emptyPrompt = "Select report options and click Generate"
        static let startDate = "Start Date"
        static let endDate = "End Date"
        static let reportType = "Report Type"
        static let generateButton = "Generate Report"
        static let exportButton = "Export"
        static let exportSubject = "NurseryConnect Report"
        static let exportMessage = "Report generated by NurseryConnect Setting Manager"
        static let complianceTitle = "Language Compliance Notice"
        static func complianceMessage(_ count: Int) -> String {
            "\(count) diary entries may contain non-English text. All nursery records must be in English for Ofsted and GDPR compliance."
        }
    }

    enum Settings {
        static let managerProfile = "Manager Profile"
        static let dataManagement = "Data Management"
        static let about = "About"
        static let resetSampleData = "Reset to Sample Data"
        static let name = "Name"
        static let role = "Role"
        static let nursery = "Nursery"
        static let app = "App"
        static let version = "Version"
        static let platform = "Platform"
        static let framework = "Framework"
        static let appValue = "NurseryConnect Manager"
        static let versionValue = "2.0.0"
        static let platformValue = "macOS"
        static let frameworkValue = "SwiftUI + NaturalLanguage"
    }

    // Misc
    enum Wellbeing {
        static let scoreLabel = "AI Score"
        static let reviewRecommended = "Review recommended"
        static let goodThreshold = "Good"
        static let alertThreshold = "Alert"
    }

    enum Heatmap {
        static let zeroGap = "0 (Gap)"
        static let oneTwo = "1-2"
        static let threeFour = "3-4"
        static let fivePlus = "5+"
    }

    enum Charts {
        static let noMoodData = "No mood data available"
        static let dateAxisLabel = "Date"
        static let scoreAxisLabel = "Score"
        static let eyfsAreaAxisLabel = "EYFS Area"
        static let entriesAxisLabel = "Entries"
        static let moodCountAxisLabel = "Count"
        static let childAxisLabel = "Child"
    }
}
