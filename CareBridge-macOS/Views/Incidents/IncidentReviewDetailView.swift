// IncidentReviewDetailView.swift
// NurseryConnect — Setting Manager (macOS)
// Detailed incident review with NL location extraction, countersign button,
// body map display, and notification compliance timer

import SwiftUI

struct IncidentReviewDetailView: View {
    let incident: Incident
    @State private var incidentVM = IncidentReviewViewModel()
    @State private var showCountersignAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                incidentHeader
                
                // Status & Timeline
                statusTimeline
                
                // NL Analysis — Extracted Locations
                nlAnalysisSection
                
                // Description
                descriptionSection
                
                // Body Map (read-only)
                if !incident.bodyMapMarkers.isEmpty {
                    bodyMapSection
                }
                
                // Action Buttons
                actionButtons
            }
            .padding(24)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle(ManagerText.IncidentReview.title)
        .onAppear {
            incidentVM.selectIncident(incident)
        }
        .alert(ManagerText.IncidentReview.countersignDialogTitle, isPresented: $showCountersignAlert) {
            Button(ManagerText.IncidentReview.countersignConfirm, role: .destructive) {
                incidentVM.countersign(incident)
            }
            Button(ManagerText.IncidentReview.cancel, role: .cancel) { }
        } message: {
            Text(ManagerText.IncidentReview.countersignDialogMessage)
        }
    }
    
    // MARK: - Header
    private var incidentHeader: some View {
        HStack(spacing: 16) {
            // Category icon
            Image(systemName: incident.category.icon)
                .font(.title)
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(incident.category.color)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(incident.category.rawValue)
                    .font(.title2.weight(.bold))
                
                HStack(spacing: 8) {
                    if let child = incidentVM.child(for: incident) {
                        Label(child.fullName, systemImage: "person.fill")
                    }
                    Label(incident.dateTime.fullDateTimeString, systemImage: "clock")
                }
                .font(.callout)
                .foregroundStyle(.secondary)
                
                HStack(spacing: 8) {
                    Label(incident.location, systemImage: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("\(ManagerText.IncidentReview.severityPrefix) \(incident.category.severity.rawValue)")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(incident.category.severity.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(incident.category.severity.color.opacity(0.12))
                        )
                }
            }
            
            Spacer()
            
            // Status
            VStack(spacing: 4) {
                Image(systemName: incident.status.icon)
                    .font(.title2)
                    .foregroundStyle(incident.status.color)
                
                Text(incident.status.rawValue)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(incident.status.color)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(incident.status.color.opacity(0.1))
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: ManagerConstants.cardCornerRadius)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        )
    }
    
    // MARK: - Status Timeline
    private var statusTimeline: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(ManagerText.IncidentReview.workflowTitle)
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                timelineItem(ManagerText.IncidentReview.submitted, time: incident.submittedAt, icon: "paperplane.fill")
                timelineItem(ManagerText.IncidentReview.reviewed, time: incident.reviewedAt, icon: "eye.fill")
                timelineItem(ManagerText.IncidentReview.countersigned, time: incident.countersignedAt, icon: "signature")
                timelineItem(ManagerText.IncidentReview.parentNotified, time: incident.parentNotifiedAt, icon: "bell.fill")
                timelineItem(ManagerText.IncidentReview.acknowledged, time: incident.acknowledgedAt, icon: "checkmark.seal.fill")
            }
            
            // Compliance timer
            let deadline = incidentVM.deadlineStatus(for: incident)
            HStack(spacing: 8) {
                Image(systemName: "clock.badge.exclamationmark")
                    .foregroundStyle(deadline.color)
                Text("\(ManagerText.IncidentReview.parentNotificationPrefix) \(deadline.text)")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(deadline.color)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(deadline.color.opacity(0.08))
                    .stroke(deadline.color.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: ManagerConstants.cardCornerRadius)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        )
    }
    
    private func timelineItem(_ label: String, time: Date?, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(time != nil ? .ncSuccess : .ncTextSecondary)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption2.weight(.medium))
                Text(time?.relativeTimeString ?? ManagerText.IncidentReview.pending)
                    .font(.caption2)
                    .foregroundStyle(time != nil ? .secondary : .tertiary)
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(time != nil ? .ncSuccess.opacity(0.06) : .clear)
        )
    }
    
    // MARK: - NL Analysis Section
    private var nlAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundStyle(.ncPrimary)
                Text(ManagerText.IncidentReview.naturalLanguageTitle)
                    .font(.headline)
            }
            
            // Extracted locations
            if !incidentVM.extractedLocations.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(.ncPrimary)
                    Text(ManagerText.IncidentReview.extractedLocationsLabel)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    
                    ForEach(incidentVM.extractedLocations, id: \.self) { location in
                        Text(location)
                            .font(.callout.weight(.medium))
                            .foregroundStyle(.ncPrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(.ncPrimary.opacity(0.1))
                            )
                    }
                }
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.slash")
                        .foregroundStyle(.secondary)
                    Text(ManagerText.IncidentReview.noLocations)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: ManagerConstants.cardCornerRadius)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        )
    }
    
    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(ManagerText.IncidentReview.descriptionTitle)
                .font(.headline)
            
            Text(incident.description)
                .font(.body)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(nsColor: .textBackgroundColor))
                )
            
            Text(ManagerText.IncidentReview.immediateActionTitle)
                .font(.headline)
            
            Text(incident.immediateActionTaken)
                .font(.body)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(nsColor: .textBackgroundColor))
                )
            
            if !incident.witnesses.isEmpty {
                Text(ManagerText.IncidentReview.witnessesTitle)
                    .font(.headline)
                
                ForEach(incident.witnesses, id: \.self) { witness in
                    Label(witness, systemImage: "person.fill")
                        .font(.callout)
                }
            }
            
            if let reviewer = incident.reviewerName {
                Divider()
                Label("\(ManagerText.IncidentReview.reviewedByPrefix) \(reviewer)", systemImage: "signature")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            
            if let notes = incident.reviewNotes, !notes.isEmpty {
                Text("\(ManagerText.IncidentReview.reviewNotesPrefix) \(notes)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .italic()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: ManagerConstants.cardCornerRadius)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        )
    }
    
    // MARK: - Body Map Section
    private var bodyMapSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(ManagerText.IncidentReview.bodyMapTitle)
                .font(.headline)
            
            ForEach(incident.bodyMapMarkers) { marker in
                HStack(spacing: 8) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(.ncSecondary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(marker.label)
                            .font(.callout.weight(.medium))
                        Text("\(marker.side.rawValue) — \(ManagerText.IncidentReview.positionPrefix) (\(String(format: "%.0f%%", marker.xPercent * 100)), \(String(format: "%.0f%%", marker.yPercent * 100)))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.ncSecondary.opacity(0.06))
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: ManagerConstants.cardCornerRadius)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        )
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 12) {
            // Countersign button
            if incident.status == .submitted || incident.status == .underReview {
                Button {
                    showCountersignAlert = true
                } label: {
                    Label(ManagerText.IncidentReview.countersignButton, systemImage: "signature")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.ncPrimary)
                .controlSize(.large)
            }
            
            // Escalate button
            if incidentVM.shouldShowEscalateButton(for: incident) {
                Button {
                    // Escalation action
                } label: {
                    Label(ManagerText.IncidentReview.escalateButton, systemImage: "exclamationmark.shield.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.ncSecondary)
                .controlSize(.large)
            }
        }
    }
}
