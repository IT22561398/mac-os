// IncidentViewModel.swift
// NurseryConnect
// ViewModel for Incident Reporting feature - manages incident CRUD, form state, workflow

import Foundation
import SwiftUI

@Observable
class IncidentViewModel {
    var dataManager: DataManager
    var searchText = ""
    var filterCategory: IncidentCategory?
    var filterStatus: IncidentStatus?
    var showIncidentForm = false
    var editingIncident: Incident?
    var toast: ToastData?
    
    // Form fields (FR-24)
    var selectedChildId: UUID?
    var category: IncidentCategory?
    var location = ""
    var description = ""
    var immediateActionTaken = ""
    var witnesses: [String] = [""]
    var bodyMapMarkers: [BodyMapMarker] = []
    var bodyMapSide: BodyMapSide = .front
    
    init(dataManager: DataManager = .shared) {
        self.dataManager = dataManager
    }
    
    // MARK: - Filtered Incidents
    var allIncidents: [Incident] {
        var results = dataManager.incidents
        
        if !searchText.isEmpty {
            results = results.filter { incident in
                incident.description.localizedCaseInsensitiveContains(searchText) ||
                incident.location.localizedCaseInsensitiveContains(searchText) ||
                incident.category.rawValue.localizedCaseInsensitiveContains(searchText) ||
                (childName(for: incident.childId)?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        if let cat = filterCategory {
            results = results.filter { $0.category == cat }
        }
        
        if let status = filterStatus {
            results = results.filter { $0.status == status }
        }
        
        return results.sorted { $0.dateTime > $1.dateTime }
    }
    
    var todayIncidents: [Incident] {
        allIncidents.filter { $0.dateTime.isToday }
    }
    
    var thisWeekIncidents: [Incident] {
        let startOfWeek = Date().startOfWeek
        return allIncidents.filter { $0.dateTime >= startOfWeek }
    }
    
    var pendingReview: [Incident] {
        dataManager.pendingReviewIncidents()
    }
    
    // MARK: - Statistics
    var totalIncidents: Int { dataManager.incidents.count }
    
    var incidentsByCategory: [(category: IncidentCategory, count: Int)] {
        let grouped = Dictionary(grouping: dataManager.incidents, by: { $0.category })
        return IncidentCategory.allCases.map { cat in
            (category: cat, count: grouped[cat]?.count ?? 0)
        }.filter { $0.count > 0 }
    }
    
    var incidentsByStatus: [(status: IncidentStatus, count: Int)] {
        let grouped = Dictionary(grouping: dataManager.incidents, by: { $0.status })
        return IncidentStatus.allCases.map { status in
            (status: status, count: grouped[status]?.count ?? 0)
        }.filter { $0.count > 0 }
    }
    
    // MARK: - Helpers
    func childName(for id: UUID) -> String? {
        dataManager.child(for: id)?.fullName
    }
    
    func child(for id: UUID) -> ChildProfile? {
        dataManager.child(for: id)
    }
    
    // MARK: - Form Management
    func prepareNewIncident(childId: UUID? = nil) {
        resetForm()
        selectedChildId = childId
        editingIncident = nil
        showIncidentForm = true
    }
    
    func prepareEditIncident(_ incident: Incident) {
        editingIncident = incident
        selectedChildId = incident.childId
        category = incident.category
        location = incident.location
        description = incident.description
        immediateActionTaken = incident.immediateActionTaken
        witnesses = incident.witnesses.isEmpty ? [""] : incident.witnesses
        bodyMapMarkers = incident.bodyMapMarkers
        showIncidentForm = true
    }
    
    // MARK: - Validation (using FormValidator)
    var formErrors: [String] {
        var errors: [String] = []
        if selectedChildId == nil {
            errors.append("Please select a child")
        }
        errors.append(contentsOf: FormValidator.validateIncidentForm(
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            location: location.trimmingCharacters(in: .whitespacesAndNewlines),
            actionTaken: immediateActionTaken,
            category: category
        ))
        return errors
    }
    
    var isFormValid: Bool {
        formErrors.isEmpty
    }
    
    // MARK: - Save Incident
    func saveIncident() {
        guard isFormValid else {
            if let firstError = formErrors.first {
                toast = ToastData(type: .warning, message: firstError)
            }
            HapticManager.warning()
            return
        }
        
        guard let childId = selectedChildId, let cat = category else { return }
        
        let cleanedLocation = location.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedAction = immediateActionTaken.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanWitnesses = witnesses.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        let existing = editingIncident
        let incident = Incident(
            id: existing?.id ?? UUID(),
            childId: childId,
            keyworkerId: dataManager.keyworker.id,
            category: cat,
            status: existing?.status ?? .submitted,
            dateTime: existing?.dateTime ?? Date(),
            location: cleanedLocation,
            description: cleanedDescription,
            immediateActionTaken: cleanedAction,
            witnesses: cleanWitnesses,
            bodyMapMarkers: bodyMapMarkers,
            submittedAt: existing?.submittedAt ?? Date(),
            reviewedAt: existing?.reviewedAt,
            countersignedAt: existing?.countersignedAt,
            parentNotifiedAt: existing?.parentNotifiedAt,
            acknowledgedAt: existing?.acknowledgedAt,
            reviewerName: existing?.reviewerName,
            reviewNotes: existing?.reviewNotes
        )
        
        if editingIncident != nil {
            dataManager.updateIncident(incident)
            toast = ToastData(type: .success, message: "Incident updated successfully")
        } else {
            dataManager.addIncident(incident)
            toast = ToastData(type: .success, message: "Incident submitted for review")
        }
        
        HapticManager.success()
        showIncidentForm = false
        resetForm()
    }
    
    func deleteIncident(_ incident: Incident) {
        dataManager.deleteIncident(incident)
        HapticManager.notification(.warning)
        toast = ToastData(type: .info, message: "Incident deleted")
    }
    
    // Simulate manager countersigning (local workflow simulation)
    func simulateCountersign(_ incident: Incident) {
        var updated = incident
        updated.status = .countersigned
        updated.countersignedAt = Date()
        updated.reviewedAt = Date()
        updated.reviewerName = "Claire Johnson (Setting Manager)"
        dataManager.updateIncident(updated)
        toast = ToastData(type: .success, message: "Incident countersigned by manager")
        HapticManager.success()
    }
    
    // Simulate parent notification
    func simulateParentNotification(_ incident: Incident) {
        var updated = incident
        updated.status = .parentNotified
        updated.parentNotifiedAt = Date()
        dataManager.updateIncident(updated)
        toast = ToastData(type: .info, message: "Parent has been notified")
        HapticManager.notification(.success)
    }
    
    // Add body map marker
    func addBodyMapMarker(side: BodyMapSide, x: CGFloat, y: CGFloat, label: String) {
        let marker = BodyMapMarker(side: side, xPercent: x, yPercent: y, label: label)
        bodyMapMarkers.append(marker)
        HapticManager.lightTap()
    }
    
    func removeBodyMapMarker(_ marker: BodyMapMarker) {
        bodyMapMarkers.removeAll { $0.id == marker.id }
    }
    
    // Add witness field
    func addWitnessField() {
        witnesses.append("")
    }
    
    func removeWitness(at index: Int) {
        guard witnesses.count > 1 else { return }
        witnesses.remove(at: index)
    }
    
    func resetForm() {
        selectedChildId = nil
        category = nil
        location = ""
        description = ""
        immediateActionTaken = ""
        witnesses = [""]
        bodyMapMarkers = []
        bodyMapSide = .front
        editingIncident = nil
    }
}

