// DataManager.swift
// NurseryConnect
// Central data manager using UserDefaults + JSON codable persistence
// Chosen over Core Data for simplicity in MVP scope while still providing
// structured data storage with relationships

import Foundation
import SwiftUI

@Observable
class DataManager {
    static let shared = DataManager()
    
    // MARK: - Stored Data
    var keyworker: KeyworkerProfile
    var children: [ChildProfile]
    var diaryEntries: [DiaryEntry]
    var incidents: [Incident]
    
    // MARK: - UserDefaults Keys
    private let keyworkerKey = "nc_keyworker"
    private let childrenKey = "nc_children"
    private let diaryEntriesKey = "nc_diary_entries"
    private let incidentsKey = "nc_incidents"
    private let hasLaunchedKey = "nc_has_launched_before"
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    var hasLaunchedBefore: Bool {
        get { UserDefaults.standard.bool(forKey: hasLaunchedKey) }
        set { UserDefaults.standard.set(newValue, forKey: hasLaunchedKey) }
    }
    
    init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        
        // Load data from UserDefaults
        if let data = UserDefaults.standard.data(forKey: keyworkerKey),
           let kw = try? decoder.decode(KeyworkerProfile.self, from: data) {
            self.keyworker = kw
        } else {
            self.keyworker = SampleData.keyworker
        }
        
        if let data = UserDefaults.standard.data(forKey: childrenKey),
           let ch = try? decoder.decode([ChildProfile].self, from: data) {
            self.children = ch
        } else {
            self.children = SampleData.children
        }
        
        if let data = UserDefaults.standard.data(forKey: diaryEntriesKey),
           let de = try? decoder.decode([DiaryEntry].self, from: data) {
            self.diaryEntries = de
        } else {
            self.diaryEntries = SampleData.generateDiaryEntries()
        }
        
        if let data = UserDefaults.standard.data(forKey: incidentsKey),
           let inc = try? decoder.decode([Incident].self, from: data) {
            self.incidents = inc
        } else {
            self.incidents = SampleData.generateIncidents()
        }
    }
    
    // MARK: - Persistence
    func save() {
        if let data = try? encoder.encode(keyworker) {
            UserDefaults.standard.set(data, forKey: keyworkerKey)
        }
        if let data = try? encoder.encode(children) {
            UserDefaults.standard.set(data, forKey: childrenKey)
        }
        if let data = try? encoder.encode(diaryEntries) {
            UserDefaults.standard.set(data, forKey: diaryEntriesKey)
        }
        if let data = try? encoder.encode(incidents) {
            UserDefaults.standard.set(data, forKey: incidentsKey)
        }
    }
    
    // MARK: - Diary Entry CRUD
    func addDiaryEntry(_ entry: DiaryEntry) {
        diaryEntries.insert(entry, at: 0)
        save()
    }
    
    func updateDiaryEntry(_ entry: DiaryEntry) {
        if let index = diaryEntries.firstIndex(where: { $0.id == entry.id }) {
            diaryEntries[index] = entry
            save()
        }
    }
    
    func deleteDiaryEntry(_ entry: DiaryEntry) {
        diaryEntries.removeAll { $0.id == entry.id }
        save()
    }
    
    func diaryEntriesForChild(_ childId: UUID, on date: Date = Date()) -> [DiaryEntry] {
        let startOfDay = date.startOfDay
        let endOfDay = date.endOfDay
        return diaryEntries
            .filter { $0.childId == childId && $0.timestamp >= startOfDay && $0.timestamp <= endOfDay }
            .sorted { $0.timestamp > $1.timestamp }
    }
    
    func todayEntriesForChild(_ childId: UUID) -> [DiaryEntry] {
        return diaryEntriesForChild(childId, on: Date())
    }
    
    func recentEntriesForChild(_ childId: UUID, limit: Int = 5) -> [DiaryEntry] {
        return diaryEntries
            .filter { $0.childId == childId }
            .sorted { $0.timestamp > $1.timestamp }
            .prefix(limit)
            .map { $0 }
    }
    
    // MARK: - Incident CRUD
    func addIncident(_ incident: Incident) {
        incidents.insert(incident, at: 0)
        save()
    }
    
    func updateIncident(_ incident: Incident) {
        if let index = incidents.firstIndex(where: { $0.id == incident.id }) {
            incidents[index] = incident
            save()
        }
    }
    
    func deleteIncident(_ incident: Incident) {
        incidents.removeAll { $0.id == incident.id }
        save()
    }
    
    func incidentsForChild(_ childId: UUID) -> [Incident] {
        return incidents
            .filter { $0.childId == childId }
            .sorted { $0.dateTime > $1.dateTime }
    }
    
    func todayIncidents() -> [Incident] {
        let startOfDay = Date().startOfDay
        return incidents.filter { $0.dateTime >= startOfDay }
            .sorted { $0.dateTime > $1.dateTime }
    }
    
    func pendingReviewIncidents() -> [Incident] {
        return incidents
            .filter { $0.status == .submitted || $0.status == .underReview }
            .sorted { $0.dateTime > $1.dateTime }
    }
    
    // MARK: - Child Helpers
    func child(for id: UUID) -> ChildProfile? {
        children.first { $0.id == id }
    }
    
    func childrenWithAllergies() -> [ChildProfile] {
        children.filter { !$0.allergies.isEmpty }
    }
    
    // MARK: - Statistics
    func todayActivityCount(for childId: UUID) -> Int {
        todayEntriesForChild(childId).filter { $0.type == .activity }.count
    }
    
    func todayMealCount(for childId: UUID) -> Int {
        todayEntriesForChild(childId).filter { $0.type == .meal }.count
    }
    
    func weekIncidentCount() -> Int {
        let startOfWeek = Date().startOfWeek
        return incidents.filter { $0.dateTime >= startOfWeek }.count
    }
    
    func totalEntriesThisWeek() -> Int {
        let startOfWeek = Date().startOfWeek
        return diaryEntries.filter { $0.timestamp >= startOfWeek }.count
    }
    
    // MARK: - Daily Summary
    func generateDailySummary(for childId: UUID, on date: Date = Date()) -> DailySummary {
        let entries = diaryEntriesForChild(childId, on: date)
        let child = child(for: childId)
        
        let activities = entries.filter { $0.type == .activity }
        let meals = entries.filter { $0.type == .meal }
        let sleeps = entries.filter { $0.type == .sleep }
        let nappies = entries.filter { $0.type == .nappy }
        let wellbeings = entries.filter { $0.type == .wellbeing }
        
        let totalSleepMinutes = sleeps.reduce(0) { total, entry in
            if let dur = entry.sleepDurationMinutes { return total + dur }
            return total
        }
        
        return DailySummary(
            childName: child?.fullName ?? "Unknown",
            date: date,
            activityCount: activities.count,
            mealCount: meals.count,
            sleepCount: sleeps.count,
            totalSleepMinutes: totalSleepMinutes,
            nappyCount: nappies.count,
            wellbeingChecks: wellbeings.count,
            latestMood: wellbeings.last?.moodRating ?? .content,
            entries: entries
        )
    }
    
    // MARK: - Reset Data
    func resetToSampleData() {
        keyworker = SampleData.keyworker
        children = SampleData.children
        diaryEntries = SampleData.generateDiaryEntries()
        incidents = SampleData.generateIncidents()
        save()
    }
}

// MARK: - Daily Summary Model
struct DailySummary {
    let childName: String
    let date: Date
    let activityCount: Int
    let mealCount: Int
    let sleepCount: Int
    let totalSleepMinutes: Int
    let nappyCount: Int
    let wellbeingChecks: Int
    let latestMood: MoodRating
    let entries: [DiaryEntry]
    
    var totalSleepDuration: String {
        let hours = totalSleepMinutes / 60
        let minutes = totalSleepMinutes % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}
