// IncidentReviewViewModel.swift
// NurseryConnect — Setting Manager (macOS)
// ViewModel for Incident Review & Countersignature workflow

import Foundation
import SwiftUI
import UserNotifications

@Observable
class IncidentReviewViewModel {
    // MARK: - Dependencies
    private let dataService = ManagerDataService.shared
    private let nlService = NLAnalysisService.shared
    
    // MARK: - State
    var pendingIncidents: [Incident] = []
    var selectedIncident: Incident?
    var isCountersigning: Bool = false
    var showCountersignConfirmation: Bool = false
    var reviewNotes: String = ""
    
    // NL Analysis Results
    var extractedLocations: [String] = []
    
    // MARK: - Load Data
    
    func loadPendingIncidents() {
        pendingIncidents = dataService.incidentsNeedingCountersign
    }
    
    func selectIncident(_ incident: Incident) {
        selectedIncident = incident
        reviewNotes = incident.reviewNotes ?? ""
        Task { await analyzeIncident(incident) }
    }
    
    // MARK: - NL Analysis
    
    private func analyzeIncident(_ incident: Incident) async {
        let locations = await Task.detached(priority: .userInitiated) { [nlService] in
            let descriptionLocations = nlService.extractLocations(from: incident.description)
            let actionLocations = nlService.extractLocations(from: incident.immediateActionTaken)
            return Array(Set(descriptionLocations + actionLocations))
        }.value

        await MainActor.run {
            extractedLocations = locations
        }
    }
    
    func extractLocationEntities(from text: String) -> [String] {
        nlService.extractLocations(from: text)
    }
    
    // MARK: - Countersign Workflow
    
    func countersign(_ incident: Incident) {
        isCountersigning = true
        
        var updated = incident
        updated.status = .countersigned
        updated.countersignedAt = Date()
        updated.reviewerName = dataService.managerProfile.fullName
        updated.reviewNotes = reviewNotes.isEmpty ? nil : reviewNotes
        
        DataManager.shared.updateIncident(updated)
        
        // Schedule macOS notification
        scheduleCountersignNotification(for: updated)
        
        // Refresh data
        loadPendingIncidents()
        selectedIncident = nil
        reviewNotes = ""
        isCountersigning = false
    }
    
    // MARK: - Deadline Calculations
    
    func hoursUntilDeadline(for incident: Incident) -> Double {
        dataService.hoursUntilDeadline(for: incident)
    }
    
    func isOverdue(_ incident: Incident) -> Bool {
        dataService.isOverdue(incident: incident)
    }
    
    func deadlineStatus(for incident: Incident) -> (text: String, color: Color) {
        let hours = hoursUntilDeadline(for: incident)
        
        if incident.parentNotifiedAt != nil {
            return (ManagerText.IncidentReview.deadlineParentNotified, .ncSuccess)
        }
        
        if hours <= 0 {
            return (ManagerText.IncidentReview.deadlineOverdue, .ncSecondary)
        } else if hours < 1 {
            let minutes = Int(hours * 60)
            return (ManagerText.IncidentReview.deadlineMinutesRemaining(minutes), .ncSecondary)
        } else if hours < 2 {
            return (ManagerText.IncidentReview.deadlineHoursRemaining(hours), .ncWarning)
        } else {
            return (ManagerText.IncidentReview.deadlineHoursRemaining(hours), .ncPrimary)
        }
    }
    
    // MARK: - Incident Grouping
    
    var incidentsGroupedByDate: [(date: String, incidents: [Incident])] {
        let grouped = Dictionary(grouping: pendingIncidents) { incident in
            incident.dateTime.shortDateString
        }
        return grouped.map { (date: $0.key, incidents: $0.value) }
            .sorted { $0.incidents.first?.dateTime ?? Date() > $1.incidents.first?.dateTime ?? Date() }
    }
    
    // MARK: - Child Info
    
    func childName(for incident: Incident) -> String {
        dataService.childName(for: incident.childId)
    }
    
    func child(for incident: Incident) -> ChildProfile? {
        DataManager.shared.child(for: incident.childId)
    }
    
    // MARK: - Notifications
    
    private func scheduleCountersignNotification(for incident: Incident) {
        let content = UNMutableNotificationContent()
        content.title = ManagerText.IncidentReview.notificationTitle
        content.body = ManagerText.IncidentReview.notificationBody(
            childName: childName(for: incident),
            reviewer: dataService.managerProfile.fullName
        )
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "countersign-\(incident.id.uuidString)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Escalation
    
    func shouldShowEscalateButton(for incident: Incident) -> Bool {
        incident.category == .safeguardingConcern ||
        (incident.category.severity == .high && incident.category != .medicalIncident)
    }
}
