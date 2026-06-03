// ManagerDataService.swift
// NurseryConnect — Setting Manager (macOS)
// @Observable data service that bridges Assignment 1's DataManager
// with Setting Manager-specific queries and computed views

import Foundation
import SwiftUI
import os.log

@Observable
class ManagerDataService {
    static let shared = ManagerDataService()
    
    // MARK: - Data Sources (shared from Assignment 1)
    private let dataManager = DataManager.shared
    
    // MARK: - Setting Manager Profile
    var managerProfile: SettingManagerProfile
    
    // MARK: - Cached Analysis Results
    var wellbeingScores: [UUID: Double] = [:]
    var wellbeingTrends: [UUID: WellbeingTrend] = [:]
    var sentimentResults: [UUID: [SentimentAnalysisResult]] = [:]
    var wellbeingAlerts: [ChildWellbeingAlert] = []
    var isAnalyzing: Bool = false
    var lastAnalysisTime: Date?
    
    // MARK: - UserDefaults Keys
    private let managerProfileKey = "nc_manager_profile"
    private let wellbeingAlertsKey = "nc_wellbeing_alerts"
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        
        // Load manager profile
        if let data = UserDefaults.standard.data(forKey: managerProfileKey) {
            do {
                self.managerProfile = try decoder.decode(SettingManagerProfile.self, from: data)
                AppLogger.data.info("Successfully loaded SettingManagerProfile from UserDefaults.")
            } catch {
                AppLogger.data.error("Failed to decode SettingManagerProfile: \(error.localizedDescription)")
                self.managerProfile = ManagerSampleData.settingManager
            }
        } else {
            AppLogger.data.debug("No SettingManagerProfile found in UserDefaults, using sample data.")
            self.managerProfile = ManagerSampleData.settingManager
        }
        
        // Load cached alerts
        if let data = UserDefaults.standard.data(forKey: wellbeingAlertsKey) {
            do {
                self.wellbeingAlerts = try decoder.decode([ChildWellbeingAlert].self, from: data)
                AppLogger.data.info("Successfully loaded \(self.wellbeingAlerts.count) wellbeing alerts.")
            } catch {
                AppLogger.data.error("Failed to decode Wellbeing Alerts: \(error.localizedDescription)")
                self.wellbeingAlerts = ManagerSampleData.generateWellbeingAlerts()
            }
        } else {
            AppLogger.data.debug("No Wellbeing Alerts found in UserDefaults, generating samples.")
            self.wellbeingAlerts = ManagerSampleData.generateWellbeingAlerts()
        }
    }
    
    // MARK: - Data Accessors (proxy to DataManager)
    
    var allChildren: [ChildProfile] {
        dataManager.children.filter { $0.isActive }
    }
    
    var allDiaryEntries: [DiaryEntry] {
        dataManager.diaryEntries
    }
    
    var allIncidents: [Incident] {
        dataManager.incidents
    }
    
    // MARK: - Computed Properties
    
    /// Children grouped by room assignment
    var childrenByRoom: [String: [ChildProfile]] {
        Dictionary(grouping: allChildren, by: { $0.roomAssignment })
    }
    
    /// Rooms managed
    var rooms: [String] {
        Array(Set(allChildren.map { $0.roomAssignment })).sorted()
    }
    
    /// Pending incidents needing countersignature
    var pendingIncidents: [Incident] {
        allIncidents
            .filter { $0.status == .submitted || $0.status == .underReview }
            .sorted { $0.dateTime > $1.dateTime }
    }
    
    /// Incidents pending countersign (narrower — only submitted/underReview)
    var incidentsNeedingCountersign: [Incident] {
        allIncidents
            .filter { $0.status == .submitted || $0.status == .underReview }
            .sorted { $0.dateTime > $1.dateTime }
    }
    
    /// Total children checked in today (has a diary entry today)
    var childrenCheckedInToday: Int {
        let today = Date().startOfDay
        let childIdsWithEntriesToday = Set(
            allDiaryEntries
                .filter { $0.timestamp >= today }
                .map { $0.childId }
        )
        return childIdsWithEntriesToday.count
    }
    
    /// Total expected children
    var totalExpectedChildren: Int {
        allChildren.count
    }
    
    /// Children with low wellbeing scores
    var flaggedChildren: [ChildProfile] {
        allChildren.filter { child in
            let score = wellbeingScores[child.id] ?? 50.0
            return score < ManagerConstants.wellbeingScoreLowThreshold
        }
    }
    
    /// Count of AI-flagged wellbeing concerns
    var flaggedWellbeingCount: Int {
        flaggedChildren.count
    }
    
    // MARK: - Child-Specific Queries
    
    func diaryEntries(for childId: UUID) -> [DiaryEntry] {
        allDiaryEntries
            .filter { $0.childId == childId }
            .sorted { $0.timestamp > $1.timestamp }
    }
    
    func recentDiaryEntries(for childId: UUID, days: Int = 14) -> [DiaryEntry] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return diaryEntries(for: childId)
            .filter { $0.timestamp >= cutoff }
    }
    
    func incidents(for childId: UUID) -> [Incident] {
        allIncidents
            .filter { $0.childId == childId }
            .sorted { $0.dateTime > $1.dateTime }
    }
    
    func childName(for childId: UUID) -> String {
        dataManager.child(for: childId)?.fullName ?? ManagerText.unknownLabel
    }
    
    func keyworkerName(for keyworkerId: UUID) -> String {
        if keyworkerId == dataManager.keyworker.id {
            return dataManager.keyworker.fullName
        }
        return ManagerText.staffMemberLabel
    }
    
    // MARK: - EYFS Coverage
    
    func eyfsAreaCoverage(for childId: UUID, days: Int = 7) -> [EYFSArea: Int] {
        let entries = recentDiaryEntries(for: childId, days: days)
        var coverage: [EYFSArea: Int] = [:]
        
        for area in EYFSArea.allCases {
            coverage[area] = 0
        }
        
        for entry in entries {
            if let eyfsTag = entry.eyfsArea, let area = EYFSArea.from(tag: eyfsTag) {
                coverage[area, default: 0] += 1
            }
        }
        
        return coverage
    }
    
    /// 2D heatmap data: [childIndex][eyfsAreaIndex] = count
    func eyfsHeatmapData() -> (children: [ChildProfile], areas: [EYFSArea], data: [[Int]]) {
        let children = allChildren
        let areas = EYFSArea.allCases
        var data: [[Int]] = []
        
        for child in children {
            let coverage = eyfsAreaCoverage(for: child.id, days: 7)
            let row = areas.map { coverage[$0] ?? 0 }
            data.append(row)
        }
        
        return (children, Array(areas), data)
    }
    
    // MARK: - Mood Distribution
    
    func moodDistribution(for childId: UUID, days: Int = 7) -> [MoodRating: Int] {
        let entries = recentDiaryEntries(for: childId, days: days)
        var distribution: [MoodRating: Int] = [:]
        
        for mood in MoodRating.allCases {
            distribution[mood] = 0
        }
        
        for entry in entries {
            if let mood = entry.moodRating {
                distribution[mood, default: 0] += 1
            }
        }
        
        return distribution
    }
    
    // MARK: - Incident Helpers
    
    func hoursUntilDeadline(for incident: Incident) -> Double {
        guard let submittedAt = incident.submittedAt else { return 0 }
        let deadlineDate = submittedAt.addingTimeInterval(
            ManagerConstants.parentNotificationDeadlineHours * 3600
        )
        return deadlineDate.timeIntervalSince(Date()) / 3600
    }
    
    func isOverdue(incident: Incident) -> Bool {
        if incident.parentNotifiedAt != nil { return false }
        guard let submittedAt = incident.submittedAt else { return false }
        let hoursSinceSubmission = Date().timeIntervalSince(submittedAt) / 3600
        return hoursSinceSubmission > ManagerConstants.parentNotificationDeadlineHours
    }
    
    // MARK: - Countersign
    
    func countersign(_ incident: Incident) {
        var updated = incident
        updated.status = .countersigned
        updated.countersignedAt = Date()
        updated.reviewerName = managerProfile.fullName
        dataManager.updateIncident(updated)
    }
    
    // MARK: - Persistence
    
    func save() throws {
        do {
            let profileData = try encoder.encode(managerProfile)
            UserDefaults.standard.set(profileData, forKey: managerProfileKey)
            
            let alertData = try encoder.encode(wellbeingAlerts)
            UserDefaults.standard.set(alertData, forKey: wellbeingAlertsKey)
            
            AppLogger.data.info("Successfully saved ManagerDataService state to UserDefaults.")
        } catch {
            AppLogger.data.error("Failed to save ManagerDataService state: \(error.localizedDescription)")
            throw AppError.dataCorruption(reason: "Failed to encode settings or alerts: \(error.localizedDescription)")
        }
    }
    
    func resetToSampleData() {
        managerProfile = ManagerSampleData.settingManager
        wellbeingAlerts = ManagerSampleData.generateWellbeingAlerts()
        dataManager.resetToSampleData()
        try? save()
    }
}
