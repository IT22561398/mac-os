// ManagerSampleData.swift
// NurseryConnect — Setting Manager (macOS)
// Extends Assignment 1 SampleData with Setting Manager-specific data
// Includes: Manager profile, realistic UK nursery observation notes with varied sentiment

import Foundation
import SwiftUI

struct ManagerSampleData {
    
    // MARK: - Setting Manager Profile
    static let settingManager = SettingManagerProfile(
        id: UUID(uuidString: "2B1F7C44-0002-0002-0002-000000000002")!,
        fullName: "Rebecca Hartley",
        role: "Setting Manager",
        nurseryName: "Bright Meadows Nursery & Preschool",
        roomsManaged: ["Bluebell Room", "Acorn Room", "Willow Room"],
        lastLoginAt: Date()
    )
    
    // MARK: - Realistic UK Childcare Observation Notes
    // These generate varied sentiment scores when analyzed by NaturalLanguage
    
    /// Positive development observations
    static let positiveNotes: [String] = [
        "Freddie demonstrated excellent turn-taking skills during group play today, engaging confidently with his peers and sharing resources independently.",
        "Showed wonderful problem-solving today during the junk-modelling activity, carefully joining boxes together and adapting the design when a piece would not balance. Lovely persistence!",
        "Made super progress with letter sounds today — confidently recognised every sound in their name and had a go at forming the letters without any prompting.",
        "Absolutely thriving outdoors, showing fantastic balance and coordination on the wobble bridge. Real confidence and a brilliant sense of adventure!",
        "Joined in beautifully at story time, answering questions about the characters with enthusiasm and offering imaginative ideas about how the tale might end.",
        "Showed genuine kindness today — spotted a friend who had no one to play with and warmly invited them into their dinosaur game. So thoughtful!",
        "Wonderful focus in the music session — kept a steady beat on the drum and led the group through the call-and-response song with great confidence.",
        "Lovely progress with early number work — counted a set of ten conkers accurately and is starting to grasp that the last number tells us how many.",
        "Really blossoming socially — set up a 'café' in the home corner and happily gave each friend a job, chatting away as they took everyone's order.",
        "Brilliant imagination during printing today — chose and combined colours all by themselves and gave a detailed account of the picture they had created."
    ]
    
    /// Concern / negative observations
    static let concernNotes: [String] = [
        "Yusuf seemed unsettled for much of the morning. He was hesitant to join in with activities and needed extra reassurance from his keyworker throughout.",
        "Was upset at drop-off and took a long while to settle. Left breakfast untouched and became tearful again during morning carpet time.",
        "Noticeably quiet today — kept away from the other children during free choice and preferred to stay tucked in the reading corner for most of the session.",
        "Found lunchtime difficult — pushed the plate away and grew distressed when gently encouraged. Needed close one-to-one support for around twenty minutes.",
        "Struggled to separate from their parent once more this morning. Cried for roughly fifteen minutes after saying goodbye and sought constant comfort from staff.",
        "Did not want to take part in the group activities and became tearful when invited to join in. Stayed close to their keyworker for most of the afternoon."
    ]
    
    /// Neutral / factual observations
    static let neutralNotes: [String] = [
        "Oscar finished his lunch, eating most of his rice. He was settled and calm during the afternoon quiet time.",
        "Took part in the planned water tray activity for around twenty minutes before moving across to the small-world area.",
        "Arrived promptly for the morning session. Had a morning snack and explored the table-top activities on offer.",
        "Completed the planned phonics task alongside the group. Practised the 'm' sound with a little adult support.",
        "Rested for about forty-five minutes after lunch. Woke happily and went on to have an afternoon snack.",
        "Played near friends at the sand tray during the morning. Joined in with the actions during singing at carpet time.",
        "Ate roughly half of the meal offered today. Took sips of water across the session whenever it was offered.",
        "Spent time in the outdoor area using the scooters and trikes. Came back indoors for snack at the usual time."
    ]
    
    // MARK: - Generate Enhanced Diary Entries with Rich Notes
    
    /// Generate diary entries with varied, realistic observation notes for NL analysis
    static func generateEnhancedDiaryEntries() -> [DiaryEntry] {
        var entries: [DiaryEntry] = []
        let children = SampleData.children
        let kwId = SampleData.keyworker.id
        
        for dayOffset in 0..<14 {
            let date = Date.daysAgo(dayOffset)
            let cal = Calendar.current
            let weekday = cal.component(.weekday, from: date)
            
            // Skip weekends
            if weekday == 1 || weekday == 7 { continue }
            
            for (childIndex, child) in children.enumerated() {
                // Morning wellbeing — with detailed notes
                let wellbeingNote: String
                if dayOffset < 3 && childIndex == 1 { // Tharushi — recent concerns
                    wellbeingNote = concernNotes[dayOffset % concernNotes.count]
                } else if childIndex == 0 { // Dineth — mostly positive
                    wellbeingNote = positiveNotes[dayOffset % positiveNotes.count]
                } else {
                    wellbeingNote = neutralNotes[dayOffset % neutralNotes.count]
                }
                
                entries.append(DiaryEntry(
                    childId: child.id,
                    keyworkerId: kwId,
                    type: .wellbeing,
                    timestamp: date.settingTime(hour: 8, minute: Int.random(in: 15...45)),
                    notes: wellbeingNote,
                    moodRating: childIndex == 1 && dayOffset < 3 ?
                        [.unsettled, .poorly, .upset].randomElement()! :
                        [.happy, .happy, .content, .content, .happy].randomElement()!,
                    wellbeingCheckTime: .arrival,
                    physicalAppearance: "Clean, well-rested",
                    socialEngagement: childIndex == 1 && dayOffset < 3 ?
                        "Reluctant to interact" : "Greeted friends warmly"
                ))
                
                // Breakfast
                let breakfastFoods = ["Creamy porridge with pear", "Wholemeal toast with scrambled egg",
                                      "Cornflakes with warm milk", "Crumpets with a little butter", "Greek yoghurt with berries"]
                entries.append(DiaryEntry(
                    childId: child.id,
                    keyworkerId: kwId,
                    type: .meal,
                    timestamp: date.settingTime(hour: 8, minute: Int.random(in: 30...50)),
                    notes: "",
                    mealType: .breakfast,
                    foodOffered: breakfastFoods[dayOffset % breakfastFoods.count],
                    portionConsumed: [.all, .most, .most, .half, .all].randomElement()!,
                    drinkType: child.dateOfBirth.ageInYears < 2 ? .milk : .water,
                    drinkAmountMl: Int.random(in: 80...200)
                ))
                
                // Morning activity with rich observation notes
                let morningActivities: [ActivityType] = [.reading, .artsAndCrafts,
                    .educational, .sensory, .music]
                let activityType = morningActivities[dayOffset % morningActivities.count]
                let activityNote: String
                
                if childIndex == 0 && dayOffset % 2 == 0 {
                    activityNote = positiveNotes[(dayOffset + childIndex) % positiveNotes.count]
                } else if childIndex == 1 && dayOffset < 2 {
                    activityNote = concernNotes[(dayOffset + childIndex) % concernNotes.count]
                } else {
                    activityNote = SampleData.generateActivityNote(for: activityType)
                }
                
                let eyfsAreas = ["Communication & Language", "Physical Development",
                                 "Personal, Social & Emotional Development",
                                 "Literacy", "Mathematics",
                                 "Understanding the World", "Expressive Arts & Design"]
                
                entries.append(DiaryEntry(
                    childId: child.id,
                    keyworkerId: kwId,
                    type: .activity,
                    timestamp: date.settingTime(hour: 9, minute: Int.random(in: 15...45)),
                    notes: activityNote,
                    activityType: activityType,
                    activityDuration: Int.random(in: 20...45),
                    eyfsArea: eyfsAreas[(dayOffset + childIndex) % eyfsAreas.count]
                ))
                
                // Outdoor play
                entries.append(DiaryEntry(
                    childId: child.id,
                    keyworkerId: kwId,
                    type: .activity,
                    timestamp: date.settingTime(hour: 11, minute: Int.random(in: 0...30)),
                    notes: "Enjoyed outdoor exploration in the garden area",
                    activityType: .outdoorPlay,
                    activityDuration: Int.random(in: 30...50),
                    eyfsArea: "Physical Development"
                ))
                
                // Midday wellbeing
                entries.append(DiaryEntry(
                    childId: child.id,
                    keyworkerId: kwId,
                    type: .wellbeing,
                    timestamp: date.settingTime(hour: 11, minute: 45),
                    notes: childIndex == 1 && dayOffset < 2 ?
                        "Still appearing unsettled, not engaging well with peers" :
                        "In good spirits, playing well with friends",
                    moodRating: childIndex == 1 && dayOffset < 2 ?
                        .unsettled : [.happy, .content, .content].randomElement()!,
                    wellbeingCheckTime: .midday,
                    socialEngagement: "Playing with peers"
                ))
                
                // Lunch
                let lunchFoods = ["Roast chicken with seasonal vegetables", "Vegetable pasta bake",
                                  "Cod fish fingers with garden peas", "Lentil cottage pie with mash",
                                  "Veggie bean wrap with sweetcorn"]
                entries.append(DiaryEntry(
                    childId: child.id,
                    keyworkerId: kwId,
                    type: .meal,
                    timestamp: date.settingTime(hour: 12, minute: Int.random(in: 0...15)),
                    notes: "",
                    mealType: .lunch,
                    foodOffered: lunchFoods[dayOffset % lunchFoods.count],
                    portionConsumed: [.all, .most, .half, .most, .all].randomElement()!,
                    drinkType: .water,
                    drinkAmountMl: Int.random(in: 100...250)
                ))
                
                // Sleep (younger children)
                if child.dateOfBirth.ageInYears < 3 || dayOffset % 3 == 0 {
                    let napStart = date.settingTime(hour: 12, minute: 45)
                    let napDuration = Int.random(in: 30...90)
                    let napEnd = Calendar.current.date(byAdding: .minute,
                        value: napDuration, to: napStart)!
                    
                    entries.append(DiaryEntry(
                        childId: child.id,
                        keyworkerId: kwId,
                        type: .sleep,
                        timestamp: napStart,
                        notes: napDuration > 60 ? "Slept well, no disturbances" : "Short rest",
                        sleepStartTime: napStart,
                        sleepEndTime: napEnd,
                        sleepPosition: [.back, .back, .side].randomElement()!,
                        sleepDurationMinutes: napDuration
                    ))
                }
                
                // Afternoon activity
                let pmNote: String
                if childIndex == 2 {
                    pmNote = positiveNotes[(dayOffset + 3) % positiveNotes.count]
                } else {
                    pmNote = "Engaged in creative play activity"
                }
                
                entries.append(DiaryEntry(
                    childId: child.id,
                    keyworkerId: kwId,
                    type: .activity,
                    timestamp: date.settingTime(hour: 14, minute: Int.random(in: 30...50)),
                    notes: pmNote,
                    activityType: [.freePlay, .socialPlay, .indoorPlay, .artsAndCrafts].randomElement()!,
                    activityDuration: Int.random(in: 25...45),
                    eyfsArea: "Expressive Arts & Design"
                ))
                
                // Departure wellbeing
                if dayOffset > 0 {
                    entries.append(DiaryEntry(
                        childId: child.id,
                        keyworkerId: kwId,
                        type: .wellbeing,
                        timestamp: date.settingTime(hour: 16, minute: Int.random(in: 30...50)),
                        notes: childIndex == 1 && dayOffset < 2 ?
                            "Remained somewhat withdrawn today, monitor tomorrow" :
                            "Had a lovely day, waved goodbye to friends",
                        moodRating: childIndex == 1 && dayOffset < 2 ?
                            .unsettled : [.happy, .happy, .content].randomElement()!,
                        wellbeingCheckTime: .departure,
                        socialEngagement: "Waved goodbye to friends"
                    ))
                }
            }
        }
        
        return entries.sorted { $0.timestamp > $1.timestamp }
    }
    
    // MARK: - Generate Wellbeing Alerts
    
    static func generateWellbeingAlerts() -> [ChildWellbeingAlert] {
        let children = SampleData.children
        
        return [
            ChildWellbeingAlert(
                childId: children[1].id, // Tharushi
                childName: children[1].fullName,
                alertType: .lowWellbeingScore,
                wellbeingScore: 38.5,
                triggeredAt: Date.daysAgo(1),
                recommendedAction: "Review the recent diary entries and arrange a check-in with the keyworker. A parent conversation may also be helpful."
            ),
            ChildWellbeingAlert(
                childId: children[1].id, // Tharushi
                childName: children[1].fullName,
                alertType: .concernFlagged,
                wellbeingScore: 38.5,
                triggeredAt: Date(),
                recommendedAction: "Several concern entries logged over the last three days — set up a meeting with the parents and keyworker to discuss next steps."
            ),
            ChildWellbeingAlert(
                childId: children[4].id, // Minoli
                childName: children[4].fullName,
                alertType: .eyfsGap,
                wellbeingScore: 62.0,
                triggeredAt: Date.daysAgo(2),
                recommendedAction: "No Mathematics or Literacy activities recorded this week. Plan some focused next-step activities to close the gap."
            ),
            ChildWellbeingAlert(
                childId: children[3].id, // Rizwan
                childName: children[3].fullName,
                alertType: .incidentOverdue,
                wellbeingScore: 55.0,
                triggeredAt: Date(),
                recommendedAction: "Parent notification is overdue for the sand pit incident. Please contact the parent as a priority."
            )
        ]
    }

    // MARK: - Sentiment Results (Pre-computed)

    static func generateSentimentResults(for entries: [DiaryEntry]) -> [SentimentAnalysisResult] {
        let nlService = NLAnalysisService.shared
        return entries.compactMap { entry in
            let trimmed = entry.notes.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            return nlService.analyzeSentimentResult(text: entry.notes, diaryEntryId: entry.id)
        }
    }
}
