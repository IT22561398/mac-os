// NurseryConnect | MessagesView.swift
// Read-only message inbox with segmented filter, unread badges, and relative timestamps.
// MVP limitation: keyworker cannot compose — replies go through manager portal.
// Compliant with UK GDPR and EYFS parent communication requirements.
//
// DESIGN: Nielsen visibility of system status; Gestalt proximity; Fitts's Law ≥ 44pt.

import SwiftUI

// MARK: - MessagesView

struct MessagesView: View {
    @Environment(MessageManager.self) private var messageManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedFilter: MessageFilter = .all
    @State private var selectedMessage: Message?

    enum MessageFilter: String, CaseIterable {
        case all = "All"
        case parents = "Parents"
        case management = "Management"
    }

    private var filteredMessages: [Message] {
        switch selectedFilter {
        case .all: return messageManager.messages
        case .parents: return messageManager.parentMessages
        case .management: return messageManager.managementMessages
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ncBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // MARK: Filter Tabs
                    filterTabsRow

                    if filteredMessages.isEmpty {
                        emptyState
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 8) {
                                ForEach(filteredMessages) { message in
                                    messageRow(message)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                        }
                    }
                }
            }
            .navigationTitle("Messages")
            
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.ncPrimary)
                }

                ToolbarItem(placement: .automatic) {
                    if messageManager.unreadCount > 0 {
                        Button {
                            messageManager.markAllRead()
                            HapticManager.selection()
                        } label: {
                            Text("Read All")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.ncPrimary)
                        }
                        .accessibilityLabel("Mark all messages as read")
                    }
                }
            }
            .sheet(item: $selectedMessage) { message in
                MessageDetailView(message: message)
            }
        }
    }

    // MARK: - Filter Tabs
    private var filterTabsRow: some View {
        HStack(spacing: 0) {
            ForEach(MessageFilter.allCases, id: \.rawValue) { filter in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedFilter = filter
                    }
                    HapticManager.selection()
                } label: {
                    VStack(spacing: 6) {
                        HStack(spacing: 4) {
                            Text(filter.rawValue)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))

                            if filter == .all && messageManager.unreadCount > 0 {
                                Text("\(messageManager.unreadCount)")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 18, height: 18)
                                    .background(Circle().fill(Color(hex: "FB7185")))
                            }
                        }
                        .foregroundStyle(selectedFilter == filter ? Color.ncPrimary : Color.ncTextSec)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(selectedFilter == filter ? Color.ncPrimary : Color.clear)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44)
                }
                .accessibilityLabel("\(filter.rawValue) messages")
                .accessibilityAddTraits(selectedFilter == filter ? .isSelected : [])
            }
        }
        .padding(.horizontal, 20)
        .background(Color.ncCard)
    }

    // MARK: - Message Row
    private func messageRow(_ message: Message) -> some View {
        Button {
            messageManager.markRead(message.id)
            selectedMessage = message
            HapticManager.lightTap()
        } label: {
            HStack(alignment: .top, spacing: 14) {
                // Sender avatar
                senderAvatar(message: message)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(message.senderName)
                            .font(.system(size: 14, weight: message.isRead ? .medium : .bold, design: .rounded))
                            .foregroundStyle(Color.ncText)
                            .lineLimit(1)

                        Spacer()

                        Text(message.timestamp.relativeTimeString)
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color.ncTextSec)
                    }

                    Text(message.subject)
                        .font(.system(size: 13, weight: message.isRead ? .regular : .semibold))
                        .foregroundStyle(Color.ncText)
                        .lineLimit(1)

                    Text(message.body)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color.ncTextSec)
                        .lineLimit(2)

                    if let childName = message.childName {
                        HStack(spacing: 4) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 8))
                            Text(childName)
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundStyle(Color.ncPrimary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.ncPrimary.opacity(0.1)))
                    }
                }

                // Unread dot
                if !message.isRead {
                    Circle()
                        .fill(Color.ncPrimary)
                        .frame(width: 8, height: 8)
                        .padding(.top, 6)
                }
            }
            .padding(14)
            .frame(minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.ncCard)
                    .shadow(color: .black.opacity(message.isRead ? 0.04 : 0.08), radius: 8, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        message.isRead
                            ? Color.white.opacity(0.04)
                            : Color.ncPrimary.opacity(0.15),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(message.isRead ? "" : "Unread. ")From \(message.senderName): \(message.subject)")
    }

    // MARK: - Sender Avatar
    private func senderAvatar(message: Message) -> some View {
        let initials = message.senderName
            .split(separator: " ")
            .compactMap { $0.first.map { String($0) } }
            .prefix(2)
            .joined()

        let color: Color = message.isFromParent
            ? Color(hex: "74B9FF")
            : Color(hex: "A29BFE")

        return AvatarView(
            initials: initials,
            color: color,
            size: 44,
            showStatus: false
        )
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.ncPrimary.opacity(0.06))
                    .frame(width: 100, height: 100)
                Image(systemName: "message.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.ncPrimary.opacity(0.5))
            }

            Text("No messages")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.ncText)

            Text("Messages from parents and management will appear here.")
                .font(.system(size: 13))
                .foregroundStyle(Color.ncTextSec)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Preview
#Preview {
    MessagesView()
        .environment(MessageManager.shared)
}
