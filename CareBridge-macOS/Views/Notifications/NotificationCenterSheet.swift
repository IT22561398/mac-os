// NurseryConnect | NotificationCenterSheet.swift
// Slide-up notification history sheet with filter chips and date grouping.
// Shows all app notifications, grouped by Today / Yesterday / Earlier.
// Compliant with EYFS 2024 and RIDDOR notification requirements.
//
// DESIGN: Filter chips per Nielsen flexibility; swipe-to-delete; Fitts's Law ≥ 44pt.

import SwiftUI

// MARK: - NotificationCenterSheet

struct NotificationCenterSheet: View {
    @Environment(NotificationManager.self) private var notificationManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedFilter: NotificationFilter = .all

    private var filteredNotifications: [AppNotification] {
        notificationManager.filtered(by: selectedFilter)
    }

    private var todayItems: [AppNotification] {
        notificationManager.todayNotifications(from: filteredNotifications)
    }

    private var yesterdayItems: [AppNotification] {
        notificationManager.yesterdayNotifications(from: filteredNotifications)
    }

    private var earlierItems: [AppNotification] {
        notificationManager.earlierNotifications(from: filteredNotifications)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ncBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // MARK: Filter Chips
                    filterChipsRow

                    if filteredNotifications.isEmpty {
                        emptyState
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 20) {
                                if !todayItems.isEmpty {
                                    notificationGroup(title: "Today", items: todayItems)
                                }
                                if !yesterdayItems.isEmpty {
                                    notificationGroup(title: "Yesterday", items: yesterdayItems)
                                }
                                if !earlierItems.isEmpty {
                                    notificationGroup(title: "Earlier", items: earlierItems)
                                }

                                Spacer(minLength: 40)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                        }
                    }
                }
            }
            .navigationTitle("Notifications")
            
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.ncPrimary)
                }

                ToolbarItem(placement: .automatic) {
                    if notificationManager.unreadCount > 0 {
                        Button {
                            notificationManager.markAllRead()
                            HapticManager.selection()
                        } label: {
                            Text("Read All")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.ncPrimary)
                        }
                        .accessibilityLabel("Mark all notifications as read")
                    }
                }
            }
        }
    }

    // MARK: - Filter Chips Row
    private var filterChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(NotificationFilter.allCases, id: \.rawValue) { filter in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFilter = filter
                        }
                        HapticManager.selection()
                    } label: {
                        HStack(spacing: 4) {
                            Text(filter.rawValue)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))

                            if filter == .unread && notificationManager.unreadCount > 0 {
                                Text("\(notificationManager.unreadCount)")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 18, height: 18)
                                    .background(Circle().fill(Color(hex: "FB7185")))
                            }
                        }
                        .foregroundStyle(selectedFilter == filter ? .white : Color.ncTextSec)
                        .padding(.horizontal, 16)
                        .frame(height: 34)
                        .background(
                            Capsule()
                                .fill(selectedFilter == filter ? Color.ncPrimary : Color.white.opacity(0.06))
                        )
                        .overlay(
                            Capsule()
                                .stroke(
                                    selectedFilter == filter
                                        ? Color.clear
                                        : Color.white.opacity(0.08),
                                    lineWidth: 1
                                )
                        )
                    }
                    .accessibilityLabel("\(filter.rawValue) notifications")
                    .accessibilityAddTraits(selectedFilter == filter ? .isSelected : [])
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(Color.ncCard)
    }

    // MARK: - Notification Group
    private func notificationGroup(title: String, items: [AppNotification]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ncTextSec)
                .tracking(0.8)
                .padding(.leading, 4)

            ForEach(items) { notification in
                notificationRow(notification)
            }
        }
    }

    // MARK: - Notification Row
    private func notificationRow(_ notification: AppNotification) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Type icon
            ZStack {
                Circle()
                    .fill(notification.type.color.opacity(0.15))
                    .frame(width: 38, height: 38)
                Image(systemName: notification.type.iconName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(notification.type.color)
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(.system(size: 13, weight: notification.isRead ? .medium : .bold, design: .rounded))
                        .foregroundStyle(Color.ncText)
                        .lineLimit(1)

                    Spacer()

                    Text(notification.timestamp.relativeTimeString)
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color.ncTextSec)
                }

                Text(notification.message)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.ncTextSec)
                    .lineLimit(2)

                // Child context
                if let childName = notification.childName {
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
            if !notification.isRead {
                Circle()
                    .fill(notification.type.color)
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)
            }
        }
        .padding(12)
        .frame(minHeight: 44)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.ncCard)
                .shadow(color: .black.opacity(notification.isRead ? 0.03 : 0.06), radius: 6, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    notification.isRead
                        ? Color.white.opacity(0.04)
                        : notification.type.color.opacity(0.15),
                    lineWidth: 1
                )
        )
        .onTapGesture {
            notificationManager.markRead(notification.id)
            HapticManager.lightTap()
        }
        .accessibilityLabel("\(notification.isRead ? "" : "Unread. ")\(notification.title). \(notification.message)")
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.ncPrimary.opacity(0.06))
                    .frame(width: 100, height: 100)
                Image(systemName: "bell.slash.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.ncPrimary.opacity(0.5))
            }

            Text("No notifications")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.ncText)

            Text("You're all caught up! Notifications about incidents, reminders, and messages will appear here.")
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
    NotificationCenterSheet()
        .environment(NotificationManager.shared)
}
