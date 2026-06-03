// NurseryConnect | NotificationManager.swift
// @Observable singleton managing in-app notifications with toast triggering.
// Generates alerts from app state: RIDDOR overdue, allergen warnings, wellbeing reminders.
// Compliant with EYFS 2024, RIDDOR 2013.

import Foundation
import SwiftUI

// MARK: - Notification Type

enum NotificationType: String, Codable, CaseIterable {
    case incidentAlert
    case allergenWarning
    case wellbeingReminder
    case nappyReminder
    case mealReminder
    case eyfsAlert
    case parentMessage
    case systemInfo
    case riddorEscalation
    case ofstedAlert

    var iconName: String {
        switch self {
        case .incidentAlert, .riddorEscalation: return "exclamationmark.triangle.fill"
        case .allergenWarning:                  return "allergens.fill"
        case .wellbeingReminder:                return "heart.fill"
        case .nappyReminder:                    return "arrow.triangle.2.circlepath"
        case .mealReminder:                     return "fork.knife"
        case .eyfsAlert:                        return "graduationcap.fill"
        case .parentMessage:                    return "message.fill"
        case .systemInfo:                       return "info.circle.fill"
        case .ofstedAlert:                      return "building.columns.fill"
        }
    }

    var color: Color {
        switch self {
        case .incidentAlert, .allergenWarning, .riddorEscalation:
            return Color(hex: "FB7185")
        case .wellbeingReminder:
            return Color(hex: "FF8FA3")
        case .nappyReminder:
            return Color(hex: "F4A261")
        case .mealReminder:
            return Color(hex: "E76F51")
        case .eyfsAlert:
            return Color(hex: "6366F1")
        case .parentMessage:
            return Color(hex: "74B3CE")
        case .systemInfo:
            return Color.gray
        case .ofstedAlert:
            return Color(hex: "9B5DE5")
        }
    }

    var filterLabel: String {
        switch self {
        case .incidentAlert, .riddorEscalation, .allergenWarning, .ofstedAlert:
            return "Alerts"
        case .wellbeingReminder, .nappyReminder, .mealReminder, .eyfsAlert:
            return "Reminders"
        case .parentMessage:
            return "Messages"
        case .systemInfo:
            return "Info"
        }
    }
}

// MARK: - App Notification Model

struct AppNotification: Identifiable, Codable, Equatable {
    let id: UUID
    let type: NotificationType
    let title: String
    let message: String
    let timestamp: Date
    var isRead: Bool
    let childId: UUID?
    let childName: String?
    let actionType: DiaryEntryType?

    init(
        id: UUID = UUID(),
        type: NotificationType,
        title: String,
        message: String,
        timestamp: Date = Date(),
        isRead: Bool = false,
        childId: UUID? = nil,
        childName: String? = nil,
        actionType: DiaryEntryType? = nil
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.message = message
        self.timestamp = timestamp
        self.isRead = isRead
        self.childId = childId
        self.childName = childName
        self.actionType = actionType
    }

    static func == (lhs: AppNotification, rhs: AppNotification) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Notification Filter

enum NotificationFilter: String, CaseIterable {
    case all      = "All"
    case unread   = "Unread"
    case alerts   = "Alerts"
    case reminders = "Reminders"
    case messages = "Messages"
}

// MARK: - NotificationManager

@Observable
class NotificationManager {
    static let shared = NotificationManager()

    var notifications: [AppNotification] = []

    /// Set on every addNotification() call — observed by ContentView for toast display.
    var latestNotification: AppNotification?

    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    init() {
        loadSampleNotifications()
    }

    // MARK: - Actions

    func addNotification(_ notification: AppNotification) {
        notifications.insert(notification, at: 0)
        latestNotification = notification
    }

    func markRead(_ id: UUID) {
        if let index = notifications.firstIndex(where: { $0.id == id }) {
            notifications[index].isRead = true
        }
    }

    func markAllRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
    }

    func removeNotification(_ id: UUID) {
        notifications.removeAll { $0.id == id }
    }

    func clearAll() {
        notifications = []
    }

    // MARK: - Filtered

    func filtered(by filter: NotificationFilter) -> [AppNotification] {
        switch filter {
        case .all:       return notifications
        case .unread:    return notifications.filter { !$0.isRead }
        case .alerts:    return notifications.filter {
            $0.type == .incidentAlert || $0.type == .riddorEscalation ||
            $0.type == .allergenWarning || $0.type == .ofstedAlert
        }
        case .reminders: return notifications.filter {
            $0.type == .wellbeingReminder || $0.type == .nappyReminder ||
            $0.type == .mealReminder || $0.type == .eyfsAlert
        }
        case .messages:  return notifications.filter { $0.type == .parentMessage || $0.type == .systemInfo }
        }
    }

    // MARK: - Date Groups

    func todayNotifications(from list: [AppNotification]) -> [AppNotification] {
        list.filter { Calendar.current.isDateInToday($0.timestamp) }
    }

    func yesterdayNotifications(from list: [AppNotification]) -> [AppNotification] {
        list.filter { Calendar.current.isDateInYesterday($0.timestamp) }
    }

    func earlierNotifications(from list: [AppNotification]) -> [AppNotification] {
        list.filter {
            !Calendar.current.isDateInToday($0.timestamp) &&
            !Calendar.current.isDateInYesterday($0.timestamp)
        }
    }

    // MARK: - Sample Notifications

    func loadSampleNotifications() {
        let children = SampleData.children

        notifications = [
            AppNotification(
                type: .allergenWarning,
                title: "Allergen Alert — \(children[0].fullName)",
                message: "\(children[0].displayName) has allergies (Peanuts — anaphylactic). Verify all meals are nut-free before serving.",
                timestamp: Date().addingTimeInterval(-1800),
                isRead: false,
                childId: children[0].id,
                childName: children[0].fullName,
                actionType: .meal
            ),
            AppNotification(
                type: .wellbeingReminder,
                title: "Missing: Departure Wellbeing Check",
                message: "Departure wellbeing check not yet recorded for \(children[0].displayName), \(children[2].displayName), and 3 others. Please complete before end of session.",
                timestamp: Date().addingTimeInterval(-600),
                isRead: false,
                actionType: .wellbeing
            ),
            AppNotification(
                type: .parentMessage,
                title: "Message from Parent — \(children[0].fullName)",
                message: "Hi Sarah, Ollie didn't sleep well last night and may be tired today. Please let me know how he gets on. Thank you.",
                timestamp: Date().addingTimeInterval(-3600),
                isRead: false,
                childId: children[0].id,
                childName: children[0].fullName
            ),
            AppNotification(
                type: .eyfsAlert,
                title: "EYFS Coverage Reminder",
                message: "Today's activities have only covered 2 of 7 EYFS areas: Communication & Language and Physical Development. Consider adding a Literacy or Mathematics activity.",
                timestamp: Date().addingTimeInterval(-2700),
                isRead: true,
                actionType: .activity
            ),
            AppNotification(
                type: .nappyReminder,
                title: "Nappy Check Overdue — \(children[1].displayName)",
                message: "\(children[1].displayName) hasn't had a nappy check recorded in over 3 hours. Please check and log.",
                timestamp: Date().addingTimeInterval(-1200),
                isRead: true,
                childId: children[1].id,
                childName: children[1].fullName,
                actionType: .nappy
            ),
            AppNotification(
                type: .systemInfo,
                title: "End-of-Day Summary Ready",
                message: "Daily summaries have been generated for all 6 children in Sunshine Room. Tap to review before end of session.",
                timestamp: Date().addingTimeInterval(-300),
                isRead: true
            )
        ]
    }
}
