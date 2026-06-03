// NurseryConnect | AttendanceView.swift
// Full attendance management screen with summary bar, per-child state cards,
// and check-in/check-out/mark-absent actions.
// Compliant with EYFS 2024 Section 3.64 — attendance and registration requirements.
//
// STATE MACHINE: Expected → Checked In → Checked Out | Expected → Absent
// Check-in is idempotent — updates existing record for same child + date.
//
// DESIGN: Gestalt grouping; Fitts's Law ≥ 44pt; Nielsen visibility of system status.

import SwiftUI

// MARK: - AttendanceView

struct AttendanceView: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(AttendanceManager.self) private var attendanceManager
    @Environment(\.dismiss) private var dismiss

    // MARK: - Form State
    @State private var expandedChildId: UUID?
    @State private var actionMode: AttendanceAction = .checkIn

    // Check-In fields
    @State private var droppedOffBy: String = ""
    @State private var arrivalMood: String = "😊"
    @State private var parentNotes: String = ""

    // Check-Out fields
    @State private var collectedBy: String = ""
    @State private var collectorAuthorised: Bool = true
    @State private var departureMood: String = "🙂"
    @State private var handoverNotes: String = ""

    // Absent fields
    @State private var absenceReason: String = ""

    @State private var toast: ToastData?

    enum AttendanceAction: String, CaseIterable {
        case checkIn = "Check In"
        case checkOut = "Check Out"
        case markAbsent = "Mark Absent"
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // MARK: Header
                    headerSection

                    // MARK: Summary Bar
                    summaryBar

                    // MARK: Child Attendance Cards
                    ForEach(dataManager.children) { child in
                        attendanceCard(child: child)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
            .background(Color.ncBackground)
            .navigationTitle("")
            
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.ncPrimary)
                }
            }
            .toast($toast)
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Attendance")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ncText)
            
            Text("Manage daily register and safety check-ins.")
                .font(.system(size: 13))
                .foregroundStyle(Color.ncTextSec)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 4)
    }

    // MARK: - Summary Bar
    private var summaryBar: some View {
        HStack(spacing: 0) {
            summaryChip(
                value: "\(attendanceManager.presentCount)",
                label: "Present",
                color: Color(hex: "55EFC4"),
                icon: "checkmark.circle.fill"
            )
            summaryChip(
                value: "\(attendanceManager.expectedCount)",
                label: "Expected",
                color: Color(hex: "F4A261"),
                icon: "clock.fill"
            )
            summaryChip(
                value: "\(attendanceManager.absentCount)",
                label: "Absent",
                color: Color(hex: "FB7185"),
                icon: "xmark.circle.fill"
            )
            summaryChip(
                value: "\(attendanceManager.checkedOutCount)",
                label: "Left",
                color: Color.gray,
                icon: "arrow.right.circle.fill"
            )
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.ncCard)
                .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        )
        .accessibilityLabel("Attendance summary: \(attendanceManager.presentCount) present, \(attendanceManager.expectedCount) expected, \(attendanceManager.absentCount) absent, \(attendanceManager.checkedOutCount) checked out")
    }

    private func summaryChip(value: String, label: String, color: Color, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ncText)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(Color.ncTextSec)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
    }

    // MARK: - Attendance Card
    private func attendanceCard(child: ChildProfile) -> some View {
        let state = attendanceManager.state(for: child.id)
        let isExpanded = expandedChildId == child.id

        return VStack(spacing: 0) {
            // Header row — always visible
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    expandedChildId = isExpanded ? nil : child.id
                    resetFormFields()
                }
                HapticManager.selection()
            } label: {
                HStack(spacing: 14) {
                    ChildAvatar(child: child, size: 44)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(child.displayName)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.ncText)

                        HStack(spacing: 6) {
                            // State badge
                            HStack(spacing: 4) {
                                Image(systemName: state.icon)
                                    .font(.system(size: 10, weight: .bold))
                                Text(state.rawValue)
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundStyle(state.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule().fill(state.color.opacity(0.12))
                            )

                            // Check-in time
                            if let record = attendanceManager.todayRecord(for: child.id),
                               let checkIn = record.checkInTime {
                                Text(checkIn.time12String)
                                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                                    .foregroundStyle(Color.ncTextSec)
                            }
                        }
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.ncTextSec)
                }
                .frame(minHeight: 44)
                .padding(14)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("\(child.displayName), \(state.rawValue). Tap to expand.")

            // Expanded action form
            if isExpanded {
                Divider().padding(.horizontal, 14)

                actionForm(child: child, state: state)
                    .padding(14)
                    .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.ncCard)
                .shadow(color: .black.opacity(0.06), radius: 10, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(state.color.opacity(isExpanded ? 0.3 : 0.08), lineWidth: 1)
        )
    }

    // MARK: - Action Form
    @ViewBuilder
    private func actionForm(child: ChildProfile, state: AttendanceState) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            switch state {
            case .expected:
                // Can check in or mark absent
                actionSegmentPicker(options: [.checkIn, .markAbsent])

                if actionMode == .checkIn {
                    checkInForm
                    confirmButton("Check In \(child.displayName)") {
                        guard !droppedOffBy.isEmpty else {
                            toast = ToastData(type: .warning, message: "Please enter who dropped off \(child.displayName)")
                            return
                        }
                        attendanceManager.checkIn(child: child, droppedOffBy: droppedOffBy, mood: arrivalMood, parentNotes: parentNotes)
                        toast = ToastData(type: .success, message: "\(child.displayName) checked in ✓")
                        HapticManager.success()
                        expandedChildId = nil
                    }
                } else {
                    absentForm
                    confirmButton("Mark \(child.displayName) Absent", color: Color(hex: "FB7185")) {
                        guard !absenceReason.isEmpty else {
                            toast = ToastData(type: .warning, message: "Please enter a reason for absence")
                            return
                        }
                        attendanceManager.markAbsent(child: child, reason: absenceReason)
                        toast = ToastData(type: .info, message: "\(child.displayName) marked absent")
                        HapticManager.notification(.warning)
                        expandedChildId = nil
                    }
                }

            case .checkedIn:
                // Can check out
                checkOutForm
                confirmButton("Check Out \(child.displayName)", color: Color.gray) {
                    guard !collectedBy.isEmpty else {
                        toast = ToastData(type: .warning, message: "Please enter who collected \(child.displayName)")
                        return
                    }
                    attendanceManager.checkOut(child: child, collectedBy: collectedBy, authorised: collectorAuthorised, mood: departureMood, handoverNotes: handoverNotes)
                    toast = ToastData(type: .success, message: "\(child.displayName) checked out ✓")
                    HapticManager.success()
                    expandedChildId = nil
                }

            case .checkedOut:
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(Color.ncSuccess)
                    Text("\(child.displayName) has been collected today")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.ncTextSec)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)

            case .absent:
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(Color(hex: "FB7185"))
                    if let record = attendanceManager.todayRecord(for: child.id) {
                        Text("Absent — \(record.absenceReason)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.ncTextSec)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
            }
        }
    }

    // MARK: - Action Segment Picker
    private func actionSegmentPicker(options: [AttendanceAction]) -> some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.rawValue) { action in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        actionMode = action
                    }
                    HapticManager.selection()
                } label: {
                    Text(action.rawValue)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(actionMode == action ? .white : Color.ncTextSec)
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background(
                            actionMode == action
                                ? (action == .markAbsent ? Color(hex: "FB7185") : Color.ncPrimary)
                                : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .accessibilityLabel(action.rawValue)
                .accessibilityAddTraits(actionMode == action ? .isSelected : [])
            }
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.06))
        )
    }

    // MARK: - Check In Form
    private var checkInForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            formField(title: "Dropped off by", placeholder: "e.g. Mrs Thompson (Mum)", text: $droppedOffBy)

            VStack(alignment: .leading, spacing: 6) {
                Text("Arrival Mood")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ncTextSec)
                    .textCase(.uppercase)
                    .tracking(0.5)

                HStack(spacing: 12) {
                    ForEach(["😊", "🙂", "😟", "😢", "🤩"], id: \.self) { emoji in
                        Button {
                            arrivalMood = emoji
                            HapticManager.selection()
                        } label: {
                            Text(emoji)
                                .font(.system(size: 24))
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(arrivalMood == emoji ? Color.ncPrimary.opacity(0.15) : Color.clear)
                                        .overlay(
                                            Circle()
                                                .stroke(arrivalMood == emoji ? Color.ncPrimary : Color.clear, lineWidth: 2)
                                        )
                                )
                        }
                        .accessibilityLabel("Mood: \(emoji)")
                    }
                }
            }

            formField(title: "Parent notes (optional)", placeholder: "Any notes from parent...", text: $parentNotes)
        }
    }

    // MARK: - Check Out Form
    private var checkOutForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            formField(title: "Collected by", placeholder: "e.g. Mrs Thompson (Mum)", text: $collectedBy)

            Toggle(isOn: $collectorAuthorised) {
                HStack(spacing: 8) {
                    Image(systemName: collectorAuthorised ? "checkmark.shield.fill" : "shield.slash.fill")
                        .foregroundStyle(collectorAuthorised ? Color.ncSuccess : Color(hex: "FB7185"))
                    Text("Authorised person")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.ncText)
                }
            }
            .tint(Color.ncPrimary)

            if !collectorAuthorised {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(Color(hex: "FB7185"))
                    Text("Unauthorised collector — verify identity with management before releasing child")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(hex: "FB7185"))
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "FB7185").opacity(0.1))
                )
            }

            formField(title: "Handover notes (optional)", placeholder: "Day summary for parent...", text: $handoverNotes)
        }
    }

    // MARK: - Absent Form
    private var absentForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            formField(title: "Reason for absence", placeholder: "e.g. Unwell (cold)", text: $absenceReason)
        }
    }

    // MARK: - Form Helpers
    private func formField(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ncTextSec)
                .textCase(.uppercase)
                .tracking(0.5)

            TextField(placeholder, text: text)
                .font(.system(size: 14))
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
        }
    }

    private func confirmButton(_ title: String, color: Color = .ncPrimary, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(color)
                )
        }
        .accessibilityLabel(title)
    }

    private func resetFormFields() {
        droppedOffBy = ""
        arrivalMood = "😊"
        parentNotes = ""
        collectedBy = ""
        collectorAuthorised = true
        departureMood = "🙂"
        handoverNotes = ""
        absenceReason = ""
        actionMode = .checkIn
    }
}

// MARK: - Preview
#Preview {
    AttendanceView()
        .environment(DataManager.shared)
        .environment(AttendanceManager.shared)
}
