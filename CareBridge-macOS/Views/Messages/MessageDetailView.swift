// NurseryConnect | MessageDetailView.swift
// Full message detail presented as a sheet.
// Auto-marks the message as read on appear.
// Shows sender, role, child context, full body, and MVP limitation note.

import SwiftUI

// MARK: - MessageDetailView

struct MessageDetailView: View {
    let message: Message
    @Environment(MessageManager.self) private var messageManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // MARK: Sender Card
                    senderCard

                    // MARK: Subject
                    Text(message.subject)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.ncText)
                        .fixedSize(horizontal: false, vertical: true)

                    // MARK: Timestamp
                    HStack(spacing: 8) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.ncTextSec)
                        Text(message.timestamp.fullDateTimeString)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color.ncTextSec)
                    }

                    // MARK: Child Context
                    if let childName = message.childName {
                        HStack(spacing: 8) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.ncPrimary)
                            Text("Regarding: \(childName)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.ncPrimary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.ncPrimary.opacity(0.08))
                        )
                    }

                    Divider()

                    // MARK: Body
                    Text(message.body)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(Color.ncText)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 24)

                    // MARK: MVP Limitation Note
                    mvpNote
                }
                .padding(20)
            }
            .background(Color.ncBackground)
            .navigationTitle("Message")
            
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.ncPrimary)
                }
            }
            .onAppear {
                messageManager.markRead(message.id)
            }
        }
    }

    // MARK: - Sender Card
    private var senderCard: some View {
        HStack(spacing: 14) {
            let initials = message.senderName
                .split(separator: " ")
                .compactMap { $0.first.map { String($0) } }
                .prefix(2)
                .joined()

            let color: Color = message.isFromParent
                ? Color(hex: "74B9FF")
                : Color(hex: "A29BFE")

            AvatarView(
                initials: initials,
                color: color,
                size: 52,
                showStatus: false
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(message.senderName)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ncText)

                HStack(spacing: 6) {
                    Image(systemName: message.isFromParent ? "person.2.fill" : "building.2.fill")
                        .font(.system(size: 10))
                    Text(message.senderRole)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundStyle(color)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Capsule().fill(color.opacity(0.12)))
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.ncCard)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    // MARK: - MVP Note
    private var mvpNote: some View {
        HStack(spacing: 10) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color.ncPrimary)

            VStack(alignment: .leading, spacing: 2) {
                Text("Reply not available (MVP)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.ncText)
                Text("In the full version, keyworkers will be able to reply directly. Currently, replies should be sent through the management portal.")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.ncTextSec)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.ncPrimary.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.ncPrimary.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Preview
#Preview {
    MessageDetailView(
        message: Message(
            senderName: "Mrs Thompson",
            senderRole: "Parent (Oliver's Mum)",
            childName: "Oliver Thompson",
            subject: "Ollie's sleep last night",
            body: "Hi Sarah, just a heads up that Ollie had a really unsettled night — he was up from 2am and wouldn't settle until 5. He may be very tired today. Could you let me know how he gets on? Thank you so much.",
            isFromParent: true
        )
    )
    .environment(MessageManager.shared)
}
