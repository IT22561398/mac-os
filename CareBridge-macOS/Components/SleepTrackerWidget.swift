// NurseryConnect | SleepTrackerWidget.swift
// Dashboard-embeddable live sleep tracker card with a single shared Timer.publish.
// Displays currently sleeping children with live HH:MM:SS timer per child.
// Compliant with EYFS 2024 Section 3.60 — sleep and rest period monitoring.
//
// PERFORMANCE: One Timer.publish(every: 1) drives all counters.
// DESIGN: Gestalt grouping; Fitts's Law ≥ 44pt; Von Restorff for pulse animation.

import SwiftUI
import Combine

// MARK: - SleepTrackerWidget

struct SleepTrackerWidget: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(SleepTrackerManager.self) private var sleepTracker

    /// Single shared timer for all live counters — avoids per-child Timer overhead.
    @State private var now = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State private var isExpanded: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // MARK: Header
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
                HapticManager.selection()
            } label: {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "6C5CE7").opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: "moon.zzz.fill")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color(hex: "6C5CE7"))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Live Sleep Tracker")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.ncText)
                        Text(sleepTracker.hasActiveSleepers
                             ? "\(sleepTracker.activeSleeperCount) sleeping"
                             : "No active sleepers")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.ncTextSec)
                    }

                    Spacer()

                    if sleepTracker.hasActiveSleepers {
                        Circle()
                            .fill(Color(hex: "6C5CE7"))
                            .frame(width: 8, height: 8)
                            .pulse()
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.ncTextSec)
                }
                .frame(minHeight: 44)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Live sleep tracker. \(sleepTracker.activeSleeperCount) children sleeping.")

            // MARK: Content
            if isExpanded {
                if sleepTracker.hasActiveSleepers {
                    VStack(spacing: 10) {
                        ForEach(sleepTracker.sleepingChildIds, id: \.self) { childId in
                            if let child = dataManager.child(for: childId) {
                                sleepingChildRow(child: child)
                            }
                        }
                    }
                } else {
                    // Empty state — show Start Sleep buttons for checked-in children
                    emptyState
                }

                // Quick-start buttons for non-sleeping children
                if sleepTracker.hasActiveSleepers {
                    Divider()
                        .padding(.vertical, 2)
                    startSleepSection
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.ncCard)
                .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    sleepTracker.hasActiveSleepers
                        ? Color(hex: "6C5CE7").opacity(0.2)
                        : Color.white.opacity(0.06),
                    lineWidth: 1
                )
        )
        .onReceive(timer) { tick in
            now = tick
        }
    }

    // MARK: - Sleeping Child Row
    private func sleepingChildRow(child: ChildProfile) -> some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                ChildAvatar(child: child, size: 40, showAllergyBadge: false)
                Text("💤")
                    .font(.system(size: 10))
                    .offset(x: 4, y: 4)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(child.displayName)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.ncText)

                Text(sleepTracker.liveTimerString(for: child.id, now: now))
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(hex: "6C5CE7"))
            }

            Spacer()

            Button {
                let duration = sleepTracker.endSleep(for: child.id, dataManager: dataManager)
                HapticManager.success()
                NotificationCenter.default.post(name: .entrySaved, object: nil)
                // Duration is logged in the diary entry automatically
                _ = duration
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 14, weight: .bold))
                    Text("Wake")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .frame(height: 36)
                .background(Capsule().fill(Color(hex: "FB7185")))
            }
            .accessibilityLabel("End sleep for \(child.displayName)")
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "6C5CE7").opacity(0.06))
        )
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bed.double.fill")
                .font(.system(size: 28))
                .foregroundStyle(Color.ncTextSec.opacity(0.4))

            Text("No children sleeping")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color.ncTextSec)

            Text("Tap a child below to start tracking sleep")
                .font(.system(size: 11))
                .foregroundStyle(Color.ncTextSec.opacity(0.7))

            startSleepSection
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }

    // MARK: - Start Sleep Section
    private var startSleepSection: some View {
        let awakeChildren = dataManager.children.filter { !sleepTracker.isAsleep($0.id) }

        return VStack(alignment: .leading, spacing: 8) {
            Text("Start Sleep")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ncTextSec)
                .textCase(.uppercase)
                .tracking(0.5)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(awakeChildren) { child in
                        Button {
                            sleepTracker.startSleep(for: child.id, dataManager: dataManager)
                            HapticManager.mediumTap()
                        } label: {
                            HStack(spacing: 6) {
                                ChildAvatar(child: child, size: 26, showAllergyBadge: false)
                                Text(child.displayName)
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.ncText)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .frame(minHeight: 44)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.06))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color(hex: "6C5CE7").opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .accessibilityLabel("Start sleep for \(child.displayName)")
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SleepTrackerWidget()
        .environment(DataManager.shared)
        .environment(SleepTrackerManager.shared)
        .padding()
        .background(Color.ncBackground)
}
