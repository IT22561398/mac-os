// NurseryConnect | IncidentDetailView.swift
// Full redesign: visual body map, same-day notification timer, workflow timeline,
// RIDDOR compliance footer, and parent acknowledgement workflow.
// Compliant with EYFS 2024, RIDDOR 2013, Children Act 1989.

import SwiftUI
import Combine

// MARK: - IncidentDetailView
struct IncidentDetailView: View {
    let incident: Incident

    @Environment(DataManager.self) private var dataManager
    @Environment(\.dismiss) private var dismiss

    @State private var now = Date()
    @State private var selectedMarker: BodyMapMarker?
    @State private var localIncident: Incident

    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    init(incident: Incident) {
        self.incident = incident
        _localIncident = State(initialValue: incident)
    }

    private var child: ChildProfile? {
        dataManager.child(for: localIncident.childId)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: Severity Badge
                severityBadgeSection

                // MARK: Ofsted Banner
                ofstedBannerSection

                // MARK: Same-Day Notification Timer
                sameDayTimerSection

                // MARK: Child Card
                childCardSection

                // MARK: Date & Time
                dateTimeSection

                // MARK: Category & Location
                categoryLocationSection

                // MARK: Description
                descriptionSection

                // MARK: Immediate Action
                actionTakenSection

                // MARK: Body Map Visual
                bodyMapSection

                // MARK: Witnesses
                witnessesSection

                // MARK: Workflow Timeline
                workflowTimelineSection

                // MARK: Parent Acknowledgement
                parentAcknowledgementSection

                // MARK: RIDDOR Footer
                riddorFooterSection

                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .background(Color.ncBackground)
        .navigationTitle("Incident Report")
        
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    HapticManager.success()
                    // Implementation for exporting PDF would go here
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export")
                    }
                    .font(.system(size: 14, weight: .semibold))
                }
                .accessibilityLabel("Export Incident Report")
            }
        }
        .onReceive(timer) { _ in
            now = Date()
        }
        .sheet(item: $selectedMarker) { marker in
            let idx = localIncident.bodyMapMarkers.firstIndex(where: { $0.id == marker.id }) ?? 0
            BodyMapMarkerDetailSheet(
                marker: marker,
                markerIndex: idx,
                incidentId: localIncident.id,
                incidentDate: localIncident.dateTime
            )
        }
    }

    // MARK: - Severity Badge Section
    @ViewBuilder
    private var severityBadgeSection: some View {
        let cat = localIncident.category
        HStack {
            Spacer()
            HStack(spacing: 8) {
                Image(systemName: cat.icon)
                    .font(.system(size: 14, weight: .bold))
                Text(cat.rawValue)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(
                Capsule().fill(cat.color)
            )
            .shadow(color: cat.color.opacity(0.4), radius: 8, y: 2)
            Spacer()
        }
        .accessibilityLabel("Incident category: \(cat.rawValue), severity: \(cat.severity.rawValue)")
    }

    // MARK: - Ofsted Banner
    @ViewBuilder
    private var ofstedBannerSection: some View {
        if localIncident.category == .safeguardingConcern || localIncident.category == .medicalIncident {
            HStack(spacing: 10) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color(hex: "E74C3C"))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Ofsted Notification Required")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: "E74C3C"))
                    Text("This incident may require Ofsted notification within 14 days. Contact your Designated Safeguarding Lead (DSL) immediately.")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color.ncText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: "E74C3C").opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(hex: "E74C3C").opacity(0.3), lineWidth: 1)
            )
            .accessibilityLabel("Warning: This incident may require Ofsted notification within 14 days")
        }
    }

    // MARK: - Same-Day Notification Timer
    @ViewBuilder
    private var sameDayTimerSection: some View {
        if localIncident.parentNotifiedAt == nil {
            let deadline = localIncident.dateTime.addingTimeInterval(4 * 3600)
            let remaining = deadline.timeIntervalSince(now)
            let twoHourThreshold = localIncident.dateTime.addingTimeInterval(2 * 3600)
            let isUrgent = now >= twoHourThreshold
            let isOverdue = remaining <= 0

            HStack(spacing: 10) {
                Image(systemName: isOverdue ? "exclamationmark.triangle.fill" : "clock.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(isOverdue || isUrgent ? .white : Color(hex: "F89F1B"))

                VStack(alignment: .leading, spacing: 4) {
                    if isOverdue {
                        Text("⚠️ EYFS BREACH: Parent notification overdue")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Escalate to Setting Manager immediately.")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))
                    } else {
                        Text("⏱ Parent must be notified today")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(isUrgent ? .white : Color(hex: "F89F1B"))
                        let hrs = Int(remaining) / 3600
                        let mins = (Int(remaining) % 3600) / 60
                        Text("Time remaining: \(hrs)h \(mins)m")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(isUrgent ? .white.opacity(0.9) : Color.ncText)
                    }
                }

                Spacer()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isOverdue || isUrgent
                          ? Color(hex: "E74C3C")
                          : Color(hex: "F89F1B").opacity(0.12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke((isOverdue || isUrgent
                             ? Color.white.opacity(0.2)
                             : Color(hex: "F89F1B").opacity(0.3)),
                            lineWidth: 1)
            )
            .accessibilityLabel(isOverdue
                                ? "EYFS breach: parent notification is overdue"
                                : "Parent notification deadline in \(Int(remaining / 3600)) hours")
        }
    }

    // MARK: - Child Card
    @ViewBuilder
    private var childCardSection: some View {
        if let child = child {
            HStack(spacing: 14) {
                ChildAvatar(child: child, size: 52)

                VStack(alignment: .leading, spacing: 4) {
                    Text(child.fullName)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.ncText)

                    HStack(spacing: 6) {
                        Text(child.age)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.ncTextSec)
                        Text("·")
                            .foregroundStyle(Color.ncTextSec)
                        Text(child.roomAssignment)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.ncPrimary)
                    }
                }

                Spacer()

                // Allergen badge
                if child.hasAllergies {
                    VStack(spacing: 2) {
                        Image(systemName: "allergens.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.ncSecondary)
                        Text("Allergies")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(Color.ncSecondary)
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.ncSecondary.opacity(0.1))
                    )
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.ncCard)
                    .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
        }
    }

    // MARK: - Date & Time
    private var dateTimeSection: some View {
        detailCard(icon: "clock.fill", iconColor: Color.ncPrimary, title: "Date & Time") {
            VStack(alignment: .leading, spacing: 4) {
                Text(localIncident.dateTime.fullDateTimeString)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.ncText)
                Text("Non-editable — auto-stamped per EYFS requirement")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.ncTextSec)
                    .italic()
            }
        }
    }

    // MARK: - Category & Location
    private var categoryLocationSection: some View {
        detailCard(icon: "mappin.circle.fill", iconColor: Color.ncWarning, title: "Location") {
            Text(localIncident.location)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.ncText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Description
    private var descriptionSection: some View {
        detailCard(icon: "doc.text.fill", iconColor: Color(hex: "A29BFE"), title: "Description") {
            Text(localIncident.description)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.ncText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Action Taken
    private var actionTakenSection: some View {
        detailCard(icon: "cross.case.fill", iconColor: Color.ncSecondary, title: "Immediate Action Taken") {
            Text(localIncident.immediateActionTaken)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.ncText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Body Map Section
    @ViewBuilder
    private var bodyMapSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "figure.stand")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(hex: "FB7185"))
                Text("Body Map Locations")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ncText)

                Spacer()

                if !localIncident.bodyMapMarkers.isEmpty {
                    Text("\(localIncident.bodyMapMarkers.count) mark\(localIncident.bodyMapMarkers.count == 1 ? "" : "s")")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.ncTextSec)
                }
            }

            if localIncident.bodyMapMarkers.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.ncSuccess)
                        Text("No body map marks recorded")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.ncTextSec)
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
            } else {
                // Side-by-side diagrams
                HStack(spacing: 16) {
                    BodyDiagramPanel(
                        side: .front,
                        markers: localIncident.bodyMapMarkers,
                        panelHeight: 180
                    )

                    BodyDiagramPanel(
                        side: .back,
                        markers: localIncident.bodyMapMarkers,
                        panelHeight: 180
                    )
                }

                // Chip list for each marker
                VStack(spacing: 8) {
                    ForEach(Array(localIncident.bodyMapMarkers.enumerated()), id: \.element.id) { index, marker in
                        Button {
                            selectedMarker = marker
                            HapticManager.selection()
                        } label: {
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "FB7185"))
                                        .frame(width: 26, height: 26)
                                    Text("\(index + 1)")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(regionNameFor(marker))
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Color.ncText)
                                    HStack(spacing: 4) {
                                        Text(marker.side.rawValue + " view")
                                            .font(.system(size: 11, weight: .regular))
                                            .foregroundStyle(Color.ncTextSec)
                                        if !marker.label.isEmpty {
                                            Text("· \(marker.label)")
                                                .font(.system(size: 11, weight: .regular))
                                                .foregroundStyle(Color.ncTextSec)
                                                .italic()
                                                .lineLimit(1)
                                        }
                                    }
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(Color.ncTextSecondary.opacity(0.4))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .frame(minHeight: 44)
                            .background(Color.white.opacity(0.04))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .accessibilityLabel("View marker \(index + 1): \(regionNameFor(marker)) on \(marker.side.rawValue) view")
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.ncCard)
                .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    // MARK: - Witnesses
    @ViewBuilder
    private var witnessesSection: some View {
        if !localIncident.witnesses.isEmpty {
            detailCard(icon: "person.2.fill", iconColor: Color(hex: "74B9FF"), title: "Witnesses") {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(localIncident.witnesses, id: \.self) { witness in
                        HStack(spacing: 8) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.ncTextSec)
                            Text(witness)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(Color.ncText)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Workflow Timeline
    private var workflowTimelineSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "flowchart.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.ncPrimary)
                Text("Incident Workflow")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ncText)
            }

            VStack(alignment: .leading, spacing: 0) {
                workflowStep(
                    title: "Submitted",
                    subtitle: localIncident.submittedAt?.fullDateTimeString,
                    isCompleted: localIncident.submittedAt != nil,
                    isFirst: true
                )
                workflowStep(
                    title: "Manager Reviewed",
                    subtitle: localIncident.reviewedAt?.fullDateTimeString ?? "Pending review",
                    isCompleted: localIncident.reviewedAt != nil,
                    isFirst: false
                )
                workflowStep(
                    title: "Countersigned",
                    subtitle: localIncident.countersignedAt != nil
                        ? "\(localIncident.reviewerName ?? "Manager") · \(localIncident.countersignedAt?.fullDateTimeString ?? "")"
                        : "Awaiting countersignature",
                    isCompleted: localIncident.countersignedAt != nil,
                    isFirst: false
                )
                workflowStep(
                    title: "Parent Notified",
                    subtitle: localIncident.parentNotifiedAt?.fullDateTimeString ?? "Not yet notified",
                    isCompleted: localIncident.parentNotifiedAt != nil,
                    isFirst: false
                )
                workflowStep(
                    title: "Parent Acknowledged",
                    subtitle: localIncident.acknowledgedAt?.fullDateTimeString ?? "Awaiting acknowledgement",
                    isCompleted: localIncident.acknowledgedAt != nil,
                    isFirst: false,
                    isLast: true
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.ncCard)
                .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    // MARK: - Workflow Step
    private func workflowStep(title: String, subtitle: String?, isCompleted: Bool, isFirst: Bool, isLast: Bool = false) -> some View {
        HStack(alignment: .top, spacing: 14) {
            // Timeline dot + line
            VStack(spacing: 0) {
                if !isFirst {
                    Rectangle()
                        .fill(isCompleted ? Color.ncPrimary.opacity(0.4) : Color.white.opacity(0.1))
                        .frame(width: 2, height: 12)
                }

                ZStack {
                    if isCompleted {
                        Circle()
                            .fill(Color.ncPrimary)
                            .frame(width: 20, height: 20)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                    } else {
                        Circle()
                            .stroke(Color.white.opacity(0.2), style: StrokeStyle(lineWidth: 1.5, dash: [3]))
                            .frame(width: 20, height: 20)
                    }
                }

                if !isLast {
                    Rectangle()
                        .fill(isCompleted ? Color.ncPrimary.opacity(0.4) : Color.white.opacity(0.1))
                        .frame(width: 2, height: 12)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: isCompleted ? .semibold : .regular, design: .rounded))
                    .foregroundStyle(isCompleted ? Color.ncText : Color.ncTextSec)

                if let sub = subtitle {
                    Text(sub)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(Color.ncTextSec)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.vertical, 2)

            Spacer()
        }
    }

    // MARK: - Parent Acknowledgement
    @ViewBuilder
    private var parentAcknowledgementSection: some View {
        if localIncident.acknowledgedAt != nil {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.ncSuccess)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Acknowledged by parent")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.ncSuccess)
                    if let ackDate = localIncident.acknowledgedAt {
                        Text(ackDate.fullDateTimeString)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(Color.ncTextSec)
                    }
                }
                Spacer()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.ncSuccess.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.ncSuccess.opacity(0.3), lineWidth: 1)
            )
        } else if localIncident.parentNotifiedAt != nil {
            // Parent notified but not yet acknowledged — show simulation button
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(hex: "A29BFE"))
                    Text("Parent notified — awaiting acknowledgement")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.ncText)
                    Spacer()
                }

                Button {
                    simulateParentAcknowledgement()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Simulate: Mark as Parent Acknowledged")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.ncPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .accessibilityLabel("Simulate parent acknowledgement")
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: "A29BFE").opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(hex: "A29BFE").opacity(0.2), lineWidth: 1)
            )
        } else {
            // Show simulate notify + acknowledge buttons
            VStack(spacing: 12) {
                if localIncident.status == .countersigned {
                    Button {
                        simulateParentNotification()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Simulate: Notify Parent")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color(hex: "A29BFE"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .accessibilityLabel("Simulate parent notification")
                }

                if localIncident.status == .submitted || localIncident.status == .underReview {
                    Button {
                        simulateCountersign()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "signature")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Simulate: Manager Countersign")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.ncWarning)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .accessibilityLabel("Simulate manager countersign")
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
    }

    // MARK: - RIDDOR Footer
    private var riddorFooterSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.ncPrimary)
                Text("RIDDOR 2013 Compliance")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ncPrimary)
            }

            Text("Stored in accordance with RIDDOR 2013. This record will be retained until \(child?.fullName ?? "the child") reaches age 21 (Limitation Act 1980).")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(Color.ncTextSec)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.ncPrimary.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.ncPrimary.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Detail Card Helper
    private func detailCard<Content: View>(
        icon: String,
        iconColor: Color,
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(iconColor)
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ncText)
            }
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.ncCard)
                .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    // MARK: - Helpers
    private func regionNameFor(_ marker: BodyMapMarker) -> String {
        let zones = marker.side == .front
            ? BodyRegionZone.frontZones
            : BodyRegionZone.backZones
        if let zone = zones.first(where: { z in
            z.rect.contains(CGPoint(x: marker.xPercent, y: marker.yPercent))
        }) {
            return zone.region.displayName
        }
        return "Body Region"
    }

    private func simulateCountersign() {
        localIncident.status = .countersigned
        localIncident.countersignedAt = Date()
        localIncident.reviewedAt = Date()
        localIncident.reviewerName = "Claire Johnson (Setting Manager)"
        dataManager.updateIncident(localIncident)
        HapticManager.success()
    }

    private func simulateParentNotification() {
        localIncident.status = .parentNotified
        localIncident.parentNotifiedAt = Date()
        dataManager.updateIncident(localIncident)
        HapticManager.notification(.success)
    }

    private func simulateParentAcknowledgement() {
        localIncident.acknowledgedAt = Date()
        localIncident.status = .acknowledged
        dataManager.updateIncident(localIncident)
        HapticManager.success()
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        IncidentDetailView(incident: SampleData.generateIncidents()[0])
    }
    .environment(DataManager.shared)
}
