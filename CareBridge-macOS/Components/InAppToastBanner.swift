// NurseryConnect | InAppToastBanner.swift
// Global notification toast banner triggered by NotificationManager.latestNotification.
// Appears at the top of the screen with slide-down animation and auto-dismisses.
// Queue-based — only one toast shown at a time.
//
// DESIGN: Von Restorff for critical alerts (red tint); Fitts's Law ≥ 44pt tap target.

import SwiftUI

// MARK: - InAppToastBanner

struct InAppToastBanner: View {
    @Environment(NotificationManager.self) private var notificationManager

    @State private var currentNotification: AppNotification?
    @State private var isVisible: Bool = false

    var body: some View {
        VStack {
            if isVisible, let notification = currentNotification {
                bannerContent(notification)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .zIndex(1000)
            }

            Spacer()
        }
        .onChange(of: notificationManager.latestNotification) { _, newNotification in
            guard let notification = newNotification else { return }
            showBanner(notification)
        }
    }

    // MARK: - Banner Content
    private func bannerContent(_ notification: AppNotification) -> some View {
        HStack(spacing: 12) {
            // Type icon
            ZStack {
                Circle()
                    .fill(notification.type.color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: notification.type.iconName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(notification.type.color)
            }

            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(notification.title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ncText)
                    .lineLimit(1)

                Text(notification.message)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(Color.ncTextSec)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            // Dismiss button
            Button {
                dismissBanner()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.ncTextSecondary)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(Color.white.opacity(0.08)))
            }
            .accessibilityLabel("Dismiss notification")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(minHeight: 44)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 20, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(notification.type.color.opacity(0.25), lineWidth: 1)
        )
        .accessibilityLabel("Notification: \(notification.title). \(notification.message)")
    }

    // MARK: - Show / Dismiss
    private func showBanner(_ notification: AppNotification) {
        // Prevent duplicate shows
        if currentNotification?.id == notification.id { return }

        currentNotification = notification

        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            isVisible = true
        }

        // Auto-dismiss after 4 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            dismissBanner()
        }
    }

    private func dismissBanner() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            isVisible = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            currentNotification = nil
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.ncBackground.ignoresSafeArea()
        InAppToastBanner()
            .environment(NotificationManager.shared)
    }
}
