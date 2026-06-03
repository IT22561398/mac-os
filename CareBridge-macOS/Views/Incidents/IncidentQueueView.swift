// IncidentQueueView.swift
// NurseryConnect — Setting Manager (macOS)
// List of incidents pending countersignature, grouped by date

import SwiftUI

struct IncidentQueueView: View {
    @Binding var selectedIncident: Incident?
    @State private var incidentVM = IncidentReviewViewModel()
    
    var body: some View {
        List(selection: $selectedIncident) {
            if incidentVM.pendingIncidents.isEmpty {
                Section {
                    HStack {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundStyle(.ncSuccess)
                            .font(.title2)
                        VStack(alignment: .leading) {
                            Text(ManagerText.IncidentQueue.allClearTitle)
                                .font(.callout.weight(.medium))
                            Text(ManagerText.IncidentQueue.allClearSubtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
            } else {
                ForEach(incidentVM.incidentsGroupedByDate, id: \.date) { group in
                    Section(group.date) {
                        ForEach(group.incidents) { incident in
                            incidentRow(incident)
                                .tag(incident)
                                .contextMenu {
                                    Button(ManagerText.IncidentQueue.countersignAction) {
                                        incidentVM.countersign(incident)
                                    }
                                }
                        }
                    }
                }
            }
            
            // Also show all incidents for context
            Section(ManagerText.IncidentQueue.allIncidentsSection) {
                ForEach(ManagerDataService.shared.allIncidents) { incident in
                    incidentRow(incident)
                        .tag(incident)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle(ManagerText.IncidentQueue.title)
        .onAppear {
            incidentVM.loadPendingIncidents()
        }
    }
    
    // MARK: - Incident Row
    private func incidentRow(_ incident: Incident) -> some View {
        HStack(spacing: 10) {
            // Category icon
            Image(systemName: incident.category.icon)
                .font(.callout)
                .foregroundStyle(incident.category.color)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(incident.category.color.opacity(0.12))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(incidentVM.childName(for: incident))
                    .font(.callout.weight(.medium))
                    .lineLimit(1)
                
                Text(incident.category.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(incident.dateTime.relativeTimeString)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            
            Spacer()
            
            // Status badge
            Text(incident.status.rawValue)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(incident.status.color)
                )
            
            // Overdue indicator
            if incidentVM.isOverdue(incident) {
                Image(systemName: "clock.badge.exclamationmark")
                    .foregroundStyle(.ncSecondary)
                    .font(.caption)
            }
        }
        .padding(.vertical, 2)
    }
}
