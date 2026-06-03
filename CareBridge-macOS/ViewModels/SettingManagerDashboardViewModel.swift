// SettingManagerDashboardViewModel.swift
// NurseryConnect — Setting Manager (macOS)
// Main dashboard ViewModel — orchestrates NL analysis and aggregates metrics

import Foundation
import SwiftUI

@Observable
class SettingManagerDashboardViewModel {
    // MARK: - Dependencies
    private let dataService = ManagerDataService.shared
    private let nlService = NLAnalysisService.shared
    
    // MARK: - State
    var isAnalyzing: Bool = false
    var selectedSidebarItem: SidebarItem = .overview
    var selectedChildId: UUID?
    var selectedChild: ChildProfile? {
        guard let id = selectedChildId else { return nil }
        return allChildren.first { $0.id == id }
    }
    var selectedIncident: Incident?
    var searchText: String = ""
    var selectedRoom: String = ManagerText.roomFilterAll
    
    // MARK: - Dashboard Metrics
    var totalChildrenToday: Int { dataService.childrenCheckedInToday }
    var totalExpected: Int { dataService.totalExpectedChildren }
    var pendingIncidentCount: Int { dataService.pendingIncidents.count }
    var flaggedWellbeingCount: Int { dataService.flaggedWellbeingCount }
    
    // MARK: - Data Accessors
    var allChildren: [ChildProfile] { dataService.allChildren }
    var pendingIncidents: [Incident] { dataService.pendingIncidents }
    var wellbeingAlerts: [ChildWellbeingAlert] { dataService.wellbeingAlerts }
    var managerProfile: SettingManagerProfile { dataService.managerProfile }
    
    // MARK: - Wellbeing Scores
    var wellbeingScores: [UUID: Double] {
        get { dataService.wellbeingScores }
        set { dataService.wellbeingScores = newValue }
    }
    
    var wellbeingTrends: [UUID: WellbeingTrend] {
        get { dataService.wellbeingTrends }
        set { dataService.wellbeingTrends = newValue }
    }
    
    // MARK: - Filtered Children
    var filteredChildren: [ChildProfile] {
        var result = allChildren
        
        if selectedRoom != ManagerText.roomFilterAll {
            result = result.filter { $0.roomAssignment == selectedRoom }
        }
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.fullName.localizedCaseInsensitiveContains(searchText) ||
                $0.preferredName.localizedCaseInsensitiveContains(searchText) ||
                $0.roomAssignment.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result.sorted { $0.lastName < $1.lastName }
    }
    
    /// Children grouped by room
    var childrenByRoom: [String: [ChildProfile]] {
        Dictionary(grouping: filteredChildren, by: { $0.roomAssignment })
    }
    
    /// Available rooms for filtering
    var availableRooms: [String] {
        [ManagerText.roomFilterAll] + dataService.rooms
    }
    
    // MARK: - NL Analysis
    
    /// Run NaturalLanguage analysis for all children
    func runNLAnalysis() async {
        await MainActor.run { isAnalyzing = true }
        let children = allChildren
        
        let analysis = await Task.detached(priority: .userInitiated) { [dataService, nlService] in
            var scores: [UUID: Double] = [:]
            var trends: [UUID: WellbeingTrend] = [:]
            var sentiments: [UUID: [SentimentAnalysisResult]] = [:]
            var alerts: [ChildWellbeingAlert] = []
            
            for child in children {
                let entries = dataService.recentDiaryEntries(
                    for: child.id,
                    days: ManagerConstants.analysisWindowDays
                )
                
                let score = nlService.computeWellbeingScore(entries: entries)
                let trend = nlService.computeWellbeingTrend(entries: entries)
                scores[child.id] = score
                trends[child.id] = trend
                
                let results = entries.compactMap { entry -> SentimentAnalysisResult? in
                    let trimmed = entry.notes.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return nil }
                    return nlService.analyzeSentiment(entry: entry)
                }
                sentiments[child.id] = results
                
                if score < ManagerConstants.wellbeingScoreLowThreshold {
                    alerts.append(ChildWellbeingAlert(
                        childId: child.id,
                        childName: child.fullName,
                        alertType: .lowWellbeingScore,
                        wellbeingScore: score,
                        recommendedAction: ManagerText.Alerts.lowWellbeingAction
                    ))
                }
                
                let recentEntries = dataService.recentDiaryEntries(
                    for: child.id,
                    days: ManagerConstants.concernFlaggedDays
                )
                let concernCount = recentEntries.filter { entry in
                    nlService.analyzeSentiment(entry: entry).sentiment == .concern
                }.count
                
                if concernCount >= ManagerConstants.concernFlaggedMinCount {
                    alerts.append(ChildWellbeingAlert(
                        childId: child.id,
                        childName: child.fullName,
                        alertType: .concernFlagged,
                        wellbeingScore: score,
                        recommendedAction: ManagerText.Alerts.concernFlaggedAction
                    ))
                }
                
                let coverage = dataService.eyfsAreaCoverage(for: child.id, days: ManagerConstants.recentWindowDays)
                let gaps = coverage.filter { $0.value == 0 }
                if !gaps.isEmpty {
                    let gapAreas = gaps.keys.map { $0.shortName }.joined(separator: ", ")
                    alerts.append(ChildWellbeingAlert(
                        childId: child.id,
                        childName: child.fullName,
                        alertType: .eyfsGap,
                        wellbeingScore: score,
                        recommendedAction: ManagerText.Alerts.eyfsGapAction(gapAreas)
                    ))
                }
                
                let childIncidents = dataService.incidents(for: child.id)
                for incident in childIncidents where dataService.isOverdue(incident: incident) {
                    alerts.append(ChildWellbeingAlert(
                        childId: child.id,
                        childName: child.fullName,
                        alertType: .incidentOverdue,
                        wellbeingScore: score,
                        recommendedAction: ManagerText.Alerts.incidentOverdueAction(incident.dateTime.shortDateString)
                    ))
                }
            }
            
            return (scores, trends, sentiments, alerts)
        }.value
        
        await MainActor.run {
            dataService.wellbeingScores = analysis.0
            dataService.wellbeingTrends = analysis.1
            dataService.sentimentResults = analysis.2
            dataService.wellbeingAlerts = analysis.3
            isAnalyzing = false
            dataService.lastAnalysisTime = Date()
        }
    }
    
    /// Get children needing attention (for overview dashboard)
    func childrenNeedingAttention() -> [(child: ChildProfile, reason: String, score: Double)] {
        var results: [(child: ChildProfile, reason: String, score: Double)] = []
        
        for child in allChildren {
            let score = dataService.wellbeingScores[child.id] ?? 50.0
            
            if score < ManagerConstants.wellbeingScoreLowThreshold {
                results.append((child, ManagerText.Alerts.lowWellbeingReason, score))
                continue
            }

            let recentEntries = dataService.recentDiaryEntries(
                for: child.id,
                days: ManagerConstants.concernFlaggedDays
            )
            let concernCount = recentEntries.filter { entry in
                let cached = dataService.sentimentResults[child.id]?.first { $0.diaryEntryId == entry.id }
                return (cached ?? nlService.analyzeSentiment(entry: entry)).sentiment == .concern
            }.count

            if concernCount >= ManagerConstants.concernFlaggedMinCount {
                results.append((child, ManagerText.Alerts.concernFlaggedReason, score))
                continue
            }
            
            // Check for overdue incidents
            let childIncidents = dataService.incidents(for: child.id)
            if childIncidents.contains(where: { dataService.isOverdue(incident: $0) }) {
                results.append((child, ManagerText.Alerts.overdueIncidentReason, score))
                continue
            }
        }
        
        return results.sorted { $0.score < $1.score }
    }
    
    /// EYFS heatmap data
    func eyfsHeatmapData() -> (children: [ChildProfile], areas: [EYFSArea], data: [[Int]]) {
        dataService.eyfsHeatmapData()
    }
    
    // MARK: - Wellbeing Score for a specific child
    func wellbeingScore(for childId: UUID) -> Double {
        dataService.wellbeingScores[childId] ?? 50.0
    }
    
    func wellbeingTrend(for childId: UUID) -> WellbeingTrend {
        dataService.wellbeingTrends[childId] ?? .stable
    }
    
    // MARK: - Staff-to-Child Ratio
    var staffToChildRatioCompliant: Bool {
        // Simplified compliance check
        let ratio = Double(allChildren.count) / 4.0 // assuming 4 staff
        return ratio <= 8.0
    }
    
    var staffRatioDisplay: String {
        "\(ManagerText.Metrics.staffRatioPrefix)\(Int(ceil(Double(allChildren.count) / 4.0)))"
    }
}
