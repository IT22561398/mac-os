// ChildAnalyticsViewModel.swift
// NurseryConnect — Setting Manager (macOS)
// ViewModel for Child Development Detail View — AI analytics per child

import Foundation
import SwiftUI

@Observable
class ChildAnalyticsViewModel {
    // MARK: - Dependencies
    private let dataService = ManagerDataService.shared
    private let nlService = NLAnalysisService.shared
    
    // MARK: - State
    var selectedChild: ChildProfile?
    var diaryEntries: [DiaryEntry] = []
    var sentimentResults: [SentimentAnalysisResult] = []
    var wellbeingScore: Double = 50.0
    var wellbeingTrend: WellbeingTrend = .stable
    var isLoading: Bool = false
    
    // Chart Data
    var trendData: [(date: Date, score: Double)] = []
    var eyfsAreaCoverage: [EYFSArea: Int] = [:]
    var moodDistribution: [MoodRating: Int] = [:]
    var extractedKeywords: [String: Int] = [:]
    
    // MARK: - Load Analysis
    
    func loadAnalysis(for childId: UUID) async {
        await MainActor.run { isLoading = true }
        
        typealias AnalysisResult = (ChildProfile, [DiaryEntry], [SentimentAnalysisResult], Double, WellbeingTrend, [(date: Date, score: Double)], [EYFSArea: Int], [MoodRating: Int], [String: Int])
        let analysis: AnalysisResult? = await Task.detached(priority: .userInitiated) { [dataService, nlService] in
            guard let child = dataService.allChildren.first(where: { $0.id == childId }) else {
                return nil
            }
            
            let entries = dataService.recentDiaryEntries(
                for: childId,
                days: ManagerConstants.analysisWindowDays
            )
            
            let score = nlService.computeWellbeingScore(entries: entries)
            let trend = nlService.computeWellbeingTrend(entries: entries)
            
            let results = entries.compactMap { entry -> SentimentAnalysisResult? in
                let trimmed = entry.notes.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return nil }
                return nlService.analyzeSentiment(entry: entry)
            }
            
            let trendScores = nlService.dailySentimentScores(entries: entries, days: ManagerConstants.analysisWindowDays)
            let coverage = dataService.eyfsAreaCoverage(for: childId, days: ManagerConstants.analysisWindowDays)
            let moods = dataService.moodDistribution(for: childId, days: ManagerConstants.recentWindowDays)
            
            var keywordFrequency: [String: Int] = [:]
            for entry in entries {
                let text = entry.notes
                guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }
                let keywords = nlService.extractKeywords(from: text)
                for keyword in keywords {
                    keywordFrequency[keyword, default: 0] += 1
                }
            }
            
            return (child, entries, results, score, trend, trendScores, coverage, moods, keywordFrequency)
        }.value
        
        await MainActor.run {
            guard let analysis else {
                isLoading = false
                return
            }
            
            selectedChild = analysis.0
            diaryEntries = analysis.1
            sentimentResults = analysis.2
            wellbeingScore = analysis.3
            wellbeingTrend = analysis.4
            trendData = analysis.5
            eyfsAreaCoverage = analysis.6
            moodDistribution = analysis.7
            extractedKeywords = analysis.8
            isLoading = false
            
            dataService.wellbeingScores[childId] = analysis.3
            dataService.wellbeingTrends[childId] = analysis.4
        }
    }
    
    // MARK: - Keyword Frequency Analysis
    
    private func extractKeywordFrequency(from entries: [DiaryEntry]) -> [String: Int] {
        var frequency: [String: Int] = [:]
        
        for entry in entries {
            let text = entry.notes
            guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }
            
            let keywords = nlService.extractKeywords(from: text)
            for keyword in keywords {
                frequency[keyword, default: 0] += 1
            }
        }
        
        return frequency
    }
    
    // MARK: - Diary Entries With Analysis
    
    /// Entries with their sentiment results, sorted by date (newest first)
    var analyzedEntries: [(entry: DiaryEntry, result: SentimentAnalysisResult?)] {
        diaryEntries
            .filter { !$0.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .map { entry in
                let result = sentimentResults.first { $0.diaryEntryId == entry.id }
                    ?? nlService.analyzeSentiment(entry: entry)
                return (entry, result)
            }
            .sorted { $0.entry.timestamp > $1.entry.timestamp }
    }
    
    /// Count of entries analyzed
    var analyzedEntryCount: Int {
        diaryEntries.filter { !$0.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
    }
    
    /// Entries flagged as concern
    var concernEntries: [(entry: DiaryEntry, result: SentimentAnalysisResult)] {
        analyzedEntries
            .compactMap { item in
                guard let result = item.result, result.sentiment == .concern else { return nil }
                return (item.entry, result)
            }
    }
    
    // MARK: - Wellbeing Trend Data (for Charts)
    
    func wellbeingTrendChartData() -> [(date: Date, score: Double)] {
        trendData
    }
    
    // MARK: - EYFS Bar Chart Data
    
    func eyfsBarChartData() -> [(area: EYFSArea, count: Int)] {
        EYFSArea.allCases.map { area in
            (area, eyfsAreaCoverage[area] ?? 0)
        }
    }
    
    // MARK: - Mood Pie Chart Data
    
    func moodPieChartData() -> [(mood: MoodRating, count: Int)] {
        MoodRating.allCases.map { mood in
            (mood, moodDistribution[mood] ?? 0)
        }.filter { $0.count > 0 }
    }
    
    // MARK: - Child Info Helpers
    
    var childAge: String {
        selectedChild?.age ?? ManagerText.unknownLabel
    }
    
    var childRoom: String {
        selectedChild?.roomAssignment ?? ManagerText.unknownLabel
    }
    
    var keyworkerName: String {
        guard let child = selectedChild else { return ManagerText.unknownLabel }
        return dataService.keyworkerName(for: DataManager.shared.keyworker.id)
    }
    
    var scoreColor: Color {
        if wellbeingScore >= ManagerConstants.wellbeingScoreHighThreshold {
            return .ncSuccess
        } else if wellbeingScore >= ManagerConstants.wellbeingScoreLowThreshold {
            return .ncWarning
        } else {
            return .ncSecondary
        }
    }
}
