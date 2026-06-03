// DiaryViewModel.swift
// NurseryConnect
// ViewModel for Daily Diary feature - manages diary entries for assigned children

import Foundation
import SwiftUI

@Observable
class DiaryViewModel {
    var dataManager: DataManager
    var selectedChildId: UUID?
    var selectedDate: Date = Date()
    var selectedEntryType: DiaryEntryType?
    var showEntryForm = false
    var editingEntry: DiaryEntry?
    var toast: ToastData?
    
    // Activity form fields
    var activityType: ActivityType?
    var activityDuration: Int = 30
    var activityNotes = ""
    var eyfsArea = ""
    
    // Sleep form fields
    var sleepStartTime = Date()
    var sleepEndTime = Date()
    var sleepPosition: SleepPosition = .back
    var sleepNotes = ""
    
    // Nappy form fields
    var nappyType: NappyType?
    var nappyConcerns = ""
    var creamApplied = false
    
    // Meal form fields
    var mealType: MealType?
    var foodOffered = ""
    var portionConsumed: PortionConsumed?
    var drinkType: DrinkType = .water
    var drinkAmount: Int = 100
    
    // Wellbeing form fields
    var moodRating: MoodRating?
    var wellbeingTime: WellbeingCheckTime = .arrival
    var physicalAppearance = ""
    var socialEngagement = ""
    
    // General note
    var generalNote = ""

    // Arrival form fields
    var arrivalTime = Date()
    var droppedOffBy = ""
    var arrivalMood: MoodRating? = .happy
    var parentalNotes = ""

    // Departure form fields
    var departureTime = Date()
    var collectedBy = ""
    var authorisedCollector = true
    var departureMood: MoodRating? = .happy
    var handoverNotes = ""

    // Milestone form fields
    var milestoneEyfsArea = ""
    var milestoneDescription = ""
    var milestoneNextSteps = ""
    var milestoneDate = Date()
    
    init(dataManager: DataManager = .shared) {
        self.dataManager = dataManager
        if let firstChild = dataManager.children.first {
            self.selectedChildId = firstChild.id
        }
    }
    
    var selectedChild: ChildProfile? {
        guard let id = selectedChildId else { return nil }
        return dataManager.child(for: id)
    }
    
    var todayEntries: [DiaryEntry] {
        guard let childId = selectedChildId else { return [] }
        return dataManager.diaryEntriesForChild(childId, on: selectedDate)
    }
    
    var entriesGroupedByType: [(type: DiaryEntryType, entries: [DiaryEntry])] {
        let grouped = Dictionary(grouping: todayEntries, by: { $0.type })
        return DiaryEntryType.allCases.compactMap { type in
            guard let entries = grouped[type], !entries.isEmpty else { return nil }
            return (type: type, entries: entries)
        }
    }
    
    var dailySummary: DailySummary? {
        guard let childId = selectedChildId else { return nil }
        return dataManager.generateDailySummary(for: childId, on: selectedDate)
    }
    
    // MARK: - Add/Edit Entry
    func prepareNewEntry(type: DiaryEntryType) {
        selectedEntryType = type
        editingEntry = nil
        resetFormFields()
        showEntryForm = true
    }
    
    func saveEntry() {
        guard let childId = selectedChildId else { return }
        guard let type = selectedEntryType else { return }
        
        var entry = DiaryEntry(
            id: editingEntry?.id ?? UUID(),
            childId: childId,
            keyworkerId: dataManager.keyworker.id,
            type: type,
            timestamp: Date()
        )
        
        // Populate type-specific fields
        switch type {
        case .arrival:
            let cleanedDroppedOffBy = droppedOffBy.trimmingCharacters(in: .whitespacesAndNewlines)
            if cleanedDroppedOffBy.isEmpty {
                toast = ToastData(type: .warning, message: "Please enter who dropped the child off")
                return
            }
            let cleanedNotes = parentalNotes.trimmingCharacters(in: .whitespacesAndNewlines)
            entry.timestamp = arrivalTime
            entry.arrivalTime = arrivalTime
            entry.droppedOffBy = cleanedDroppedOffBy
            entry.arrivalMood = arrivalMood
            entry.parentalNotes = cleanedNotes.isEmpty ? nil : cleanedNotes
            entry.notes = cleanedNotes

        case .departure:
            let cleanedCollectedBy = collectedBy.trimmingCharacters(in: .whitespacesAndNewlines)
            if cleanedCollectedBy.isEmpty {
                toast = ToastData(type: .warning, message: "Please enter who collected the child")
                return
            }
            let cleanedNotes = handoverNotes.trimmingCharacters(in: .whitespacesAndNewlines)
            entry.timestamp = departureTime
            entry.departureTime = departureTime
            entry.collectedBy = cleanedCollectedBy
            entry.authorisedCollector = authorisedCollector
            entry.departureMood = departureMood
            entry.handoverNotes = cleanedNotes.isEmpty ? nil : cleanedNotes
            entry.notes = cleanedNotes

        case .activity:
            guard let at = activityType else {
                toast = ToastData(type: .warning, message: "Please select an activity type")
                return
            }
            entry.activityType = at
            entry.activityDuration = activityDuration
            entry.notes = activityNotes
            entry.eyfsArea = eyfsArea.isEmpty ? nil : eyfsArea
            
        case .sleep:
            entry.sleepStartTime = sleepStartTime
            entry.sleepEndTime = sleepEndTime
            entry.sleepPosition = sleepPosition
            let calculatedDuration = Int(sleepEndTime.timeIntervalSince(sleepStartTime) / 60)
            if calculatedDuration <= 0 {
                toast = ToastData(type: .warning, message: "Sleep end time must be after start time")
                return
            }
            entry.sleepDurationMinutes = calculatedDuration
            entry.notes = sleepNotes
            entry.sleepDisturbances = sleepNotes.isEmpty ? nil : sleepNotes
            
        case .nappy:
            guard let nt = nappyType else {
                toast = ToastData(type: .warning, message: "Please select a nappy type")
                return
            }
            entry.nappyType = nt
            entry.nappyConcerns = nappyConcerns.isEmpty ? nil : nappyConcerns
            entry.creamApplied = creamApplied
            entry.notes = nappyConcerns
            
        case .meal:
            guard let mt = mealType else {
                toast = ToastData(type: .warning, message: "Please select a meal type")
                return
            }
            entry.mealType = mt
            entry.foodOffered = foodOffered.isEmpty ? nil : foodOffered
            entry.portionConsumed = portionConsumed
            entry.drinkType = drinkType
            entry.drinkAmountMl = drinkAmount
            entry.notes = ""
            
        case .wellbeing:
            guard let mood = moodRating else {
                toast = ToastData(type: .warning, message: "Please select a mood rating")
                return
            }
            entry.moodRating = mood
            entry.wellbeingCheckTime = wellbeingTime
            entry.physicalAppearance = physicalAppearance.isEmpty ? nil : physicalAppearance
            entry.socialEngagement = socialEngagement.isEmpty ? nil : socialEngagement
            entry.notes = ""

        case .milestone:
            let cleanedDescription = milestoneDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            if cleanedDescription.isEmpty {
                toast = ToastData(type: .warning, message: "Please describe the milestone")
                return
            }
            entry.timestamp = milestoneDate
            entry.milestoneDate = milestoneDate
            let cleanedArea = milestoneEyfsArea.trimmingCharacters(in: .whitespacesAndNewlines)
            let cleanedNext = milestoneNextSteps.trimmingCharacters(in: .whitespacesAndNewlines)
            entry.milestoneEyfsArea = cleanedArea.isEmpty ? nil : cleanedArea
            entry.milestoneDescription = cleanedDescription
            entry.milestoneNextSteps = cleanedNext.isEmpty ? nil : cleanedNext
            entry.notes = cleanedDescription
            
        case .note:
            guard !generalNote.isEmpty else {
                toast = ToastData(type: .warning, message: "Please enter a note")
                return
            }
            entry.notes = generalNote
        }
        
        if editingEntry != nil {
            dataManager.updateDiaryEntry(entry)
            toast = ToastData(type: .success, message: "Entry updated successfully")
        } else {
            dataManager.addDiaryEntry(entry)
            toast = ToastData(type: .success, message: "\(type.rawValue) logged successfully")
        }
        
        HapticManager.success()
        showEntryForm = false
        resetFormFields()
    }
    
    func deleteEntry(_ entry: DiaryEntry) {
        dataManager.deleteDiaryEntry(entry)
        HapticManager.notification(.warning)
        toast = ToastData(type: .info, message: "Entry deleted")
    }
    
    func resetFormFields() {
        activityType = nil
        activityDuration = 30
        activityNotes = ""
        eyfsArea = ""
        sleepStartTime = Date()
        sleepEndTime = Date()
        sleepPosition = .back
        sleepNotes = ""
        nappyType = nil
        nappyConcerns = ""
        creamApplied = false
        mealType = nil
        foodOffered = ""
        portionConsumed = nil
        drinkType = .water
        drinkAmount = 100
        moodRating = nil
        wellbeingTime = .arrival
        physicalAppearance = ""
        socialEngagement = ""
        generalNote = ""
        arrivalTime = Date()
        droppedOffBy = ""
        arrivalMood = .happy
        parentalNotes = ""
        departureTime = Date()
        collectedBy = ""
        authorisedCollector = true
        departureMood = .happy
        handoverNotes = ""
        milestoneEyfsArea = ""
        milestoneDescription = ""
        milestoneNextSteps = ""
        milestoneDate = Date()
    }
}
