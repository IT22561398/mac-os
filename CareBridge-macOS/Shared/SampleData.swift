// SampleData.swift
// NurseryConnect
// Realistic pre-populated sample data based on document requirements
// Includes 6 assigned children, 2 weeks of historical diary data, and incidents

import Foundation
import SwiftUI

struct SampleData {
    
    // MARK: - Keyworker Profile
    static let keyworker = KeyworkerProfile(
        id: UUID(uuidString: "A0000001-0001-0001-0001-000000000001")!,
        firstName: "Nadeesha",
        lastName: "Perera",
        email: "nadeesha.perera@nursery.lk",
        roomAssignment: "Sunshine Room",
        assignedChildrenIds: children.map { $0.id },
        profileImageName: "person.crop.circle.fill",
        qualification: "Level 3 Early Years Educator",
        startDate: Calendar.current.date(from: DateComponents(year: 2022, month: 9, day: 1))!
    )
    
    // MARK: - Children Profiles (6 children with varied backgrounds)
    static let children: [ChildProfile] = [
        ChildProfile(
            id: UUID(uuidString: "C0000001-0001-0001-0001-000000000001")!,
            firstName: "Dineth",
            lastName: "Jayasinghe",
            preferredName: "Dinu",
            dateOfBirth: Calendar.current.date(byAdding: .month, value: -38, to: Date())!,
            roomAssignment: "Sunshine Room",
            profileColor: "6366F1",
            parentName: "Nimali Jayasinghe",
            parentEmail: "nimali.jayasinghe@gmail.com",
            parentPhone: "0771234567",
            emergencyContact: "Chathura Jayasinghe (Father)",
            emergencyPhone: "0712345678",
            medicalConditions: [],
            allergies: [
                Allergen(name: "Peanuts", severity: .anaphylactic, notes: "EpiPen in medical drawer. Administer immediately if reaction occurs."),
                Allergen(name: "Tree Nuts", severity: .allergy, notes: "Avoid all tree nut products")
            ],
            dietaryRequirements: ["Nut-free"],
            photographyConsent: true,
            socialMediaConsent: true,
            dataProcessingConsent: true,
            sessionTimes: "8:00 AM – 5:30 PM",
            isActive: true
        ),
        ChildProfile(
            id: UUID(uuidString: "C0000002-0002-0002-0002-000000000002")!,
            firstName: "Tharushi",
            lastName: "Fernando",
            preferredName: "",
            dateOfBirth: Calendar.current.date(byAdding: .month, value: -28, to: Date())!,
            roomAssignment: "Sunshine Room",
            profileColor: "FB7185",
            parentName: "Anupama Fernando",
            parentEmail: "anupama.fernando@gmail.com",
            parentPhone: "0763456789",
            emergencyContact: "Kasun Fernando (Father)",
            emergencyPhone: "0754567890",
            medicalConditions: ["Mild eczema"],
            allergies: [
                Allergen(name: "Dairy", severity: .intolerance, notes: "Lactose intolerant — use oat milk alternative")
            ],
            dietaryRequirements: ["Dairy-free"],
            photographyConsent: true,
            socialMediaConsent: false,
            dataProcessingConsent: true,
            sessionTimes: "8:30 AM – 4:30 PM",
            isActive: true
        ),
        ChildProfile(
            id: UUID(uuidString: "C0000003-0003-0003-0003-000000000003")!,
            firstName: "Senuri",
            lastName: "De Silva",
            preferredName: "Senu",
            dateOfBirth: Calendar.current.date(byAdding: .month, value: -42, to: Date())!,
            roomAssignment: "Sunshine Room",
            profileColor: "A29BFE",
            parentName: "Dilani De Silva",
            parentEmail: "dilani.desilva@gmail.com",
            parentPhone: "0775678901",
            emergencyContact: "Ruwan De Silva (Father)",
            emergencyPhone: "0716789012",
            medicalConditions: [],
            allergies: [],
            dietaryRequirements: ["Vegetarian"],
            photographyConsent: true,
            socialMediaConsent: true,
            dataProcessingConsent: true,
            sessionTimes: "7:30 AM – 6:00 PM",
            isActive: true
        ),
        ChildProfile(
            id: UUID(uuidString: "C0000004-0004-0004-0004-000000000004")!,
            firstName: "Rizwan",
            lastName: "Nizam",
            preferredName: "",
            dateOfBirth: Calendar.current.date(byAdding: .month, value: -20, to: Date())!,
            roomAssignment: "Sunshine Room",
            profileColor: "55EFC4",
            parentName: "Fathima Nizam",
            parentEmail: "fathima.nizam@gmail.com",
            parentPhone: "0757890123",
            emergencyContact: "Ameen Nizam (Father)",
            emergencyPhone: "0748901234",
            medicalConditions: [],
            allergies: [],
            dietaryRequirements: ["Halal"],
            photographyConsent: true,
            socialMediaConsent: true,
            dataProcessingConsent: true,
            sessionTimes: "8:00 AM – 5:00 PM",
            isActive: true
        ),
        ChildProfile(
            id: UUID(uuidString: "C0000005-0005-0005-0005-000000000005")!,
            firstName: "Minoli",
            lastName: "Wijesinghe",
            preferredName: "",
            dateOfBirth: Calendar.current.date(byAdding: .month, value: -15, to: Date())!,
            roomAssignment: "Sunshine Room",
            profileColor: "FBBF24",
            parentName: "Hiruni Wijesinghe",
            parentEmail: "hiruni.wijesinghe@gmail.com",
            parentPhone: "0778901234",
            emergencyContact: "Somalatha Wijesinghe (Grandmother)",
            emergencyPhone: "0729012345",
            medicalConditions: ["Asthma (mild, inhaler in bag)"],
            allergies: [
                Allergen(name: "Eggs", severity: .allergy, notes: "Avoid all egg products including baked goods with egg")
            ],
            dietaryRequirements: ["Egg-free"],
            photographyConsent: true,
            socialMediaConsent: true,
            dataProcessingConsent: true,
            sessionTimes: "9:00 AM – 3:00 PM",
            isActive: true
        ),
        ChildProfile(
            id: UUID(uuidString: "C0000006-0006-0006-0006-000000000006")!,
            firstName: "Kavindu",
            lastName: "Rajapaksha",
            preferredName: "",
            dateOfBirth: Calendar.current.date(byAdding: .month, value: -32, to: Date())!,
            roomAssignment: "Sunshine Room",
            profileColor: "FD79A8",
            parentName: "Sachini Rajapaksha",
            parentEmail: "sachini.rajapaksha@gmail.com",
            parentPhone: "0760123456",
            emergencyContact: "Nuwan Rajapaksha (Father)",
            emergencyPhone: "0701234567",
            medicalConditions: [],
            allergies: [
                Allergen(name: "Gluten", severity: .intolerance, notes: "Coeliac disease — strictly gluten-free diet")
            ],
            dietaryRequirements: ["Gluten-free"],
            photographyConsent: false,
            socialMediaConsent: false,
            dataProcessingConsent: true,
            sessionTimes: "8:00 AM – 5:00 PM",
            isActive: true
        )
    ]
    
    // MARK: - Generate Diary Entries (2 weeks of realistic data)
    static func generateDiaryEntries() -> [DiaryEntry] {
        var entries: [DiaryEntry] = []
        let kwId = keyworker.id
        
        // Generate entries for past 14 days (weekdays only)
        for dayOffset in 0..<14 {
            let date = Date.daysAgo(dayOffset)
            let cal = Calendar.current
            let weekday = cal.component(.weekday, from: date)
            
            // Skip weekends
            if weekday == 1 || weekday == 7 { continue }
            
            for child in children {
                // Morning wellbeing check
                entries.append(DiaryEntry(
                    childId: child.id,
                    keyworkerId: kwId,
                    type: .wellbeing,
                    timestamp: date.settingTime(hour: 8, minute: Int.random(in: 15...45)),
                    notes: "Arrived in good spirits",
                    moodRating: [.happy, .happy, .content, .content, .happy].randomElement()!,
                    wellbeingCheckTime: .arrival,
                    physicalAppearance: "Clean, well-rested",
                    socialEngagement: "Greeted friends warmly"
                ))
                
                // Breakfast
                let breakfastFoods = ["Porridge with banana", "Wholegrain toast with beans", "Weetabix with milk", "Scrambled egg on toast", "Muesli with fruit"]
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
                
                // Morning activity
                let morningActivities: [ActivityType] = [.reading, .artsAndCrafts, .educational, .sensory, .music]
                entries.append(DiaryEntry(
                    childId: child.id,
                    keyworkerId: kwId,
                    type: .activity,
                    timestamp: date.settingTime(hour: 9, minute: Int.random(in: 15...45)),
                    notes: generateActivityNote(for: morningActivities[dayOffset % morningActivities.count]),
                    activityType: morningActivities[dayOffset % morningActivities.count],
                    activityDuration: Int.random(in: 20...45),
                    eyfsArea: "Communication & Language"
                ))
                
                // Morning snack
                entries.append(DiaryEntry(
                    childId: child.id,
                    keyworkerId: kwId,
                    type: .meal,
                    timestamp: date.settingTime(hour: 10, minute: Int.random(in: 0...20)),
                    notes: "",
                    mealType: .morningSnack,
                    foodOffered: ["Apple slices", "Breadsticks & hummus", "Pear slices", "Rice cakes", "Carrot sticks"][dayOffset % 5],
                    portionConsumed: [.all, .most, .all].randomElement()!,
                    drinkType: .water,
                    drinkAmountMl: Int.random(in: 50...120)
                ))
                
                // Nappy change (morning) - for younger children
                if child.dateOfBirth.ageInYears < 3 {
                    entries.append(DiaryEntry(
                        childId: child.id,
                        keyworkerId: kwId,
                        type: .nappy,
                        timestamp: date.settingTime(hour: 10, minute: Int.random(in: 30...50)),
                        notes: "",
                        nappyType: [.wet, .dirty, .wet, .both].randomElement()!,
                        creamApplied: Bool.random()
                    ))
                }
                
                // Outdoor play
                entries.append(DiaryEntry(
                    childId: child.id,
                    keyworkerId: kwId,
                    type: .activity,
                    timestamp: date.settingTime(hour: 11, minute: Int.random(in: 0...30)),
                    notes: "Enjoyed outdoor exploration in the garden",
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
                    notes: "",
                    moodRating: [.happy, .content, .content].randomElement()!,
                    wellbeingCheckTime: .midday,
                    socialEngagement: "Playing well with peers"
                ))
                
                // Lunch
                let lunchFoods = ["Chicken with roast vegetables", "Pasta bolognese", "Salmon fishcakes with peas", "Beef stew with mash", "Cheese & veg quesadilla"]
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
                
                // Nap (for younger children or if tired)
                if child.dateOfBirth.ageInYears < 3 || dayOffset % 3 == 0 {
                    let napStart = date.settingTime(hour: 12, minute: 45)
                    let napDuration = Int.random(in: 30...90)
                    let napEnd = Calendar.current.date(byAdding: .minute, value: napDuration, to: napStart)!
                    
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
                
                // Afternoon nappy
                if child.dateOfBirth.ageInYears < 3 {
                    entries.append(DiaryEntry(
                        childId: child.id,
                        keyworkerId: kwId,
                        type: .nappy,
                        timestamp: date.settingTime(hour: 14, minute: Int.random(in: 0...30)),
                        notes: "",
                        nappyType: [.wet, .wet, .dirty].randomElement()!,
                        creamApplied: false
                    ))
                }
                
                // Afternoon activity
                entries.append(DiaryEntry(
                    childId: child.id,
                    keyworkerId: kwId,
                    type: .activity,
                    timestamp: date.settingTime(hour: 14, minute: Int.random(in: 30...50)),
                    notes: "Engaged in creative play activity",
                    activityType: [.freePlay, .socialPlay, .indoorPlay, .artsAndCrafts].randomElement()!,
                    activityDuration: Int.random(in: 25...45),
                    eyfsArea: "Expressive Arts & Design"
                ))
                
                // Afternoon snack
                entries.append(DiaryEntry(
                    childId: child.id,
                    keyworkerId: kwId,
                    type: .meal,
                    timestamp: date.settingTime(hour: 15, minute: Int.random(in: 0...20)),
                    notes: "",
                    mealType: .afternoonSnack,
                    foodOffered: ["Yoghurt with berries", "Cucumber & cream cheese", "Melon chunks", "Cheese & crackers", "Banana & milk"][dayOffset % 5],
                    portionConsumed: [.all, .most, .all, .half].randomElement()!,
                    drinkType: [.water, .milk].randomElement()!,
                    drinkAmountMl: Int.random(in: 60...150)
                ))
                
                // Departure wellbeing
                if dayOffset > 0 { // Skip today's departure since day isn't over
                    entries.append(DiaryEntry(
                        childId: child.id,
                        keyworkerId: kwId,
                        type: .wellbeing,
                        timestamp: date.settingTime(hour: 16, minute: Int.random(in: 30...50)),
                        notes: "Had a great day!",
                        moodRating: [.happy, .happy, .content].randomElement()!,
                        wellbeingCheckTime: .departure,
                        socialEngagement: "Waved goodbye to friends"
                    ))
                }
            }
        }
        
        return entries.sorted { $0.timestamp > $1.timestamp }
    }
    
    // MARK: - Generate Incidents (5 realistic historical incidents)
    static func generateIncidents() -> [Incident] {
        return [
            Incident(
                childId: children[0].id, // Dineth
                keyworkerId: keyworker.id,
                category: .minorAccident,
                status: .acknowledged,
                dateTime: Date.daysAgo(2).settingTime(hour: 10, minute: 35),
                location: "Outdoor play area — near climbing frame",
                description: "Dineth tripped whilst running towards the climbing frame and grazed his left knee on the rubber safety surface. He was upset initially but calmed down quickly after comfort and first aid was applied.",
                immediateActionTaken: "Wound was cleaned with sterile water and a plaster was applied. Dineth was comforted and given quiet time with a book. He was happy to return to play after 10 minutes.",
                witnesses: ["Maleesha Wickramasinghe (Room Leader)", "Sanjaya Gunasekara (Volunteer)"],
                bodyMapMarkers: [
                    BodyMapMarker(side: .front, xPercent: 0.40, yPercent: 0.78, label: "Grazed left knee")
                ],
                submittedAt: Date.daysAgo(2).settingTime(hour: 10, minute: 50),
                reviewedAt: Date.daysAgo(2).settingTime(hour: 11, minute: 15),
                countersignedAt: Date.daysAgo(2).settingTime(hour: 11, minute: 20),
                parentNotifiedAt: Date.daysAgo(2).settingTime(hour: 11, minute: 25),
                acknowledgedAt: Date.daysAgo(2).settingTime(hour: 11, minute: 45),
                reviewerName: "Nimali Abeysekera (Setting Manager)"
            ),
            Incident(
                childId: children[1].id, // Tharushi
                keyworkerId: keyworker.id,
                category: .nearMiss,
                status: .acknowledged,
                dateTime: Date.daysAgo(5).settingTime(hour: 14, minute: 10),
                location: "Main playroom — near art station",
                description: "A small container of paint was knocked off the art table and narrowly missed Tharushi, who was sitting on the floor nearby. No contact was made and no injury occurred.",
                immediateActionTaken: "Paint was cleaned up immediately. Art table arrangement was adjusted to prevent containers being placed near edges. All children moved to a safe area during cleanup.",
                witnesses: ["Nadeesha Perera (Keyworker)"],
                bodyMapMarkers: [],
                submittedAt: Date.daysAgo(5).settingTime(hour: 14, minute: 20),
                reviewedAt: Date.daysAgo(5).settingTime(hour: 14, minute: 45),
                countersignedAt: Date.daysAgo(5).settingTime(hour: 14, minute: 50),
                parentNotifiedAt: Date.daysAgo(5).settingTime(hour: 15, minute: 00),
                acknowledgedAt: Date.daysAgo(5).settingTime(hour: 15, minute: 30),
                reviewerName: "Nimali Abeysekera (Setting Manager)",
                reviewNotes: "Art station layout reviewed and improved. Staff reminded about table edge safety."
            ),
            Incident(
                childId: children[4].id, // Minoli
                keyworkerId: keyworker.id,
                category: .allergicReaction,
                status: .countersigned,
                dateTime: Date.daysAgo(8).settingTime(hour: 12, minute: 45),
                location: "Dining area",
                description: "Minoli developed a mild rash on her forearms approximately 20 minutes after lunch. The meal was checked immediately and no eggs were present in the planned menu. Investigation revealed a trace amount of egg may have been present in the bread roll glaze (supplier confirmed later).",
                immediateActionTaken: "Minoli was monitored closely. Antihistamine was administered (parental consent on file). The reaction subsided within 30 minutes. Supplier was contacted. Bread rolls removed from menu pending investigation.",
                witnesses: ["Nadeesha Perera (Keyworker)", "Chamari Weerasinghe (Catering Staff)"],
                bodyMapMarkers: [
                    BodyMapMarker(side: .front, xPercent: 0.25, yPercent: 0.45, label: "Mild rash — left forearm"),
                    BodyMapMarker(side: .front, xPercent: 0.75, yPercent: 0.45, label: "Mild rash — right forearm")
                ],
                submittedAt: Date.daysAgo(8).settingTime(hour: 13, minute: 00),
                reviewedAt: Date.daysAgo(8).settingTime(hour: 13, minute: 15),
                countersignedAt: Date.daysAgo(8).settingTime(hour: 13, minute: 20),
                parentNotifiedAt: Date.daysAgo(8).settingTime(hour: 13, minute: 25),
                reviewerName: "Nimali Abeysekera (Setting Manager)",
                reviewNotes: "Supplier contacted. New allergen check protocol for all bread products implemented."
            ),
            Incident(
                childId: children[2].id, // Senuri
                keyworkerId: keyworker.id,
                category: .firstAidRequired,
                status: .acknowledged,
                dateTime: Date.daysAgo(10).settingTime(hour: 15, minute: 20),
                location: "Book corner — Sunshine Room",
                description: "Senuri bumped her forehead on the edge of the bookshelf while standing up quickly from sitting position. A small bump formed immediately. She was conscious and responsive at all times.",
                immediateActionTaken: "Cold compress applied to forehead immediately for 10 minutes. Senuri was monitored for signs of concussion (drowsiness, vomiting, confusion) for the remainder of the session. No concerning symptoms observed.",
                witnesses: ["Nadeesha Perera (Keyworker)", "Maleesha Wickramasinghe (Room Leader)"],
                bodyMapMarkers: [
                    BodyMapMarker(side: .front, xPercent: 0.55, yPercent: 0.05, label: "Small bump — right side of forehead")
                ],
                submittedAt: Date.daysAgo(10).settingTime(hour: 15, minute: 35),
                reviewedAt: Date.daysAgo(10).settingTime(hour: 15, minute: 50),
                countersignedAt: Date.daysAgo(10).settingTime(hour: 15, minute: 55),
                parentNotifiedAt: Date.daysAgo(10).settingTime(hour: 16, minute: 00),
                acknowledgedAt: Date.daysAgo(10).settingTime(hour: 16, minute: 15),
                reviewerName: "Nimali Abeysekera (Setting Manager)",
                reviewNotes: "Bookshelf corner protectors to be installed. Head injury monitoring protocol followed correctly."
            ),
            Incident(
                childId: children[3].id, // Rizwan
                keyworkerId: keyworker.id,
                category: .minorAccident,
                status: .parentNotified,
                dateTime: Date.daysAgo(1).settingTime(hour: 9, minute: 50),
                location: "Garden — sand pit area",
                description: "Rizwan got sand in his eyes while playing in the sand pit. He became distressed and started rubbing his eyes.",
                immediateActionTaken: "Eyes were gently flushed with clean water using an eye wash station. Rizwan was comforted and given a damp cloth. He was happy to return to play after 15 minutes. Eyes were checked again 30 minutes later — no redness or irritation remaining.",
                witnesses: ["Nadeesha Perera (Keyworker)"],
                bodyMapMarkers: [
                    BodyMapMarker(side: .front, xPercent: 0.45, yPercent: 0.10, label: "Sand in both eyes — irritation")
                ],
                submittedAt: Date.daysAgo(1).settingTime(hour: 10, minute: 05),
                reviewedAt: Date.daysAgo(1).settingTime(hour: 10, minute: 30),
                countersignedAt: Date.daysAgo(1).settingTime(hour: 10, minute: 35),
                parentNotifiedAt: Date.daysAgo(1).settingTime(hour: 10, minute: 40),
                reviewerName: "Nimali Abeysekera (Setting Manager)"
            )
        ]
    }
    
    // MARK: - Activity Note Generator
    static func generateActivityNote(for type: ActivityType) -> String {
        switch type {
        case .reading: return "Enjoyed story time — showed great interest in the pictures"
        case .artsAndCrafts: return "Painting activity — explored colour mixing with enthusiasm"
        case .educational: return "Number recognition session with counting blocks"
        case .sensory: return "Explored different textures with play dough and rice tray"
        case .music: return "Participated in group singing and rhythm activity"
        case .indoorPlay: return "Building with blocks in the construction area"
        case .outdoorPlay: return "Enjoyed outdoor exploration in the garden"
        case .freePlay: return "Choice-led play in the home corner"
        case .socialPlay: return "Playing cooperatively with peers in role play"
        case .restPeriod: return "Quiet rest time with soft music"
        }
    }
}
