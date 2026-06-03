// NurseryConnect | MessageManager.swift
// @Observable service managing a simulated read-only message inbox.
// MVP limitation: keyworker cannot compose messages — replies go through manager portal.
// Compliant with UK GDPR and EYFS parent communication requirements.

import Foundation
import SwiftUI

// MARK: - Message Model

struct Message: Codable, Identifiable {
    let id: UUID
    var senderName: String
    var senderRole: String
    var childId: UUID?
    var childName: String?
    var subject: String
    var body: String
    var timestamp: Date
    var isRead: Bool
    var isFromParent: Bool

    init(
        id: UUID = UUID(),
        senderName: String,
        senderRole: String,
        childId: UUID? = nil,
        childName: String? = nil,
        subject: String,
        body: String,
        timestamp: Date = Date(),
        isRead: Bool = false,
        isFromParent: Bool = true
    ) {
        self.id = id
        self.senderName = senderName
        self.senderRole = senderRole
        self.childId = childId
        self.childName = childName
        self.subject = subject
        self.body = body
        self.timestamp = timestamp
        self.isRead = isRead
        self.isFromParent = isFromParent
    }
}

// MARK: - MessageManager

@Observable
class MessageManager {
    static let shared = MessageManager()

    var messages: [Message] = []

    var unreadCount: Int {
        messages.filter { !$0.isRead }.count
    }

    var parentMessages: [Message] {
        messages.filter { $0.isFromParent }
    }

    var managementMessages: [Message] {
        messages.filter { !$0.isFromParent }
    }

    init() {
        loadSampleMessages()
    }

    // MARK: - Actions

    func markRead(_ id: UUID) {
        if let index = messages.firstIndex(where: { $0.id == id }) {
            messages[index].isRead = true
        }
    }

    func markAllRead() {
        for index in messages.indices {
            messages[index].isRead = true
        }
    }

    // MARK: - Sample Messages

    func loadSampleMessages() {
        let children = SampleData.children

        messages = [
            Message(
                senderName: "Mrs Thompson",
                senderRole: "Parent (Oliver's Mum)",
                childId: children[0].id,
                childName: "Oliver Thompson",
                subject: "Ollie's sleep last night",
                body: "Hi Sarah, just a heads up that Ollie had a really unsettled night — he was up from 2am and wouldn't settle until 5. He may be very tired today. Could you let me know how he gets on? Thank you so much.",
                timestamp: Date().settingTime(hour: 8, minute: 32),
                isRead: false,
                isFromParent: true
            ),
            Message(
                senderName: "Mrs Okafor",
                senderRole: "Parent (Amara's Mum)",
                childId: children[1].id,
                childName: "Amara Okafor",
                subject: "Dairy-free alternatives reminder",
                body: "Hi, just to confirm — Amara's dairy-free oat milk is in her blue bag as usual. She had a mild eczema flare-up over the weekend so please ensure no dairy products are given. We've applied extra moisturiser this morning. Please let me know if there are any concerns at lunch. Many thanks.",
                timestamp: Date().settingTime(hour: 8, minute: 55),
                isRead: false,
                isFromParent: true
            ),
            Message(
                senderName: "Mrs Hassan",
                senderRole: "Parent (Muhammad's Mum)",
                childId: children[3].id,
                childName: "Muhammad Hassan",
                subject: "Halal meal confirmation",
                body: "Hello, just checking that Muhammad's halal dietary requirements are being met with today's menu. He also seems to be getting more confident with his walking — could you note any physical development milestones you observe? Thank you.",
                timestamp: Date.daysAgo(1).settingTime(hour: 18, minute: 30),
                isRead: true,
                isFromParent: true
            ),
            Message(
                senderName: "Claire Johnson",
                senderRole: "Setting Manager",
                childId: nil,
                childName: nil,
                subject: "Ofsted prep reminder",
                body: "Hi team, just a reminder that Ofsted could call for an inspection any time in the next term. Please ensure all diary entries are being completed fully and that incident forms are countersigned within 24 hours. Daily summaries should be generated before end of each session. Thanks.",
                timestamp: Date.daysAgo(2).settingTime(hour: 16, minute: 0),
                isRead: true,
                isFromParent: false
            ),
            Message(
                senderName: "Mrs Chen",
                senderRole: "Parent (Lily's Mum)",
                childId: children[4].id,
                childName: "Lily Chen",
                subject: "Lily's absence today",
                body: "Hi Sarah, Lily won't be in today — she has a cold and a temperature of 38.2. I'll keep her home until she's been symptom-free for 24 hours as per the nursery's illness policy. I'll let you know when she's better. Hope all is well!",
                timestamp: Date().settingTime(hour: 7, minute: 45),
                isRead: true,
                isFromParent: true
            )
        ]
    }
}
