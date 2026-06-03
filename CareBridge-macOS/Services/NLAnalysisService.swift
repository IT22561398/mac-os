// NLAnalysisService.swift
// NurseryConnect — Setting Manager (macOS)
// Centralized NaturalLanguage framework integration
// Provides: Sentiment Analysis, Keyword Extraction, Location Entity Extraction,
//           Language Detection, and Aggregate Wellbeing Score computation
//
// NaturalLanguage APIs used:
//   - NLTagger (.sentimentScore) — diary entry sentiment classification
//   - NLTagger (.lexicalClass) — developmental keyword extraction (nouns, verbs, adjectives)
//   - NLTagger (.nameType) — named entity recognition for incident locations
//   - NLLanguageRecognizer — language detection for Ofsted compliance

import Foundation
import NaturalLanguage

@Observable
class NLAnalysisService {
    static let shared = NLAnalysisService()
    
    // MARK: - EYFS Developmental Vocabulary
    /// Keywords that map to specific EYFS learning areas
    private let eyfsKeywordMap: [String: EYFSArea] = [
        // Communication & Language
        "speaking": .communicationAndLanguage,
        "listening": .communicationAndLanguage,
        "talking": .communicationAndLanguage,
        "vocabulary": .communicationAndLanguage,
        "language": .communicationAndLanguage,
        "communication": .communicationAndLanguage,
        "conversation": .communicationAndLanguage,
        "story": .communicationAndLanguage,
        "singing": .communicationAndLanguage,
        "words": .communicationAndLanguage,
        
        // Physical Development
        "climbing": .physicalDevelopment,
        "running": .physicalDevelopment,
        "jumping": .physicalDevelopment,
        "balancing": .physicalDevelopment,
        "coordination": .physicalDevelopment,
        "motor": .physicalDevelopment,
        "physical": .physicalDevelopment,
        "movement": .physicalDevelopment,
        "catching": .physicalDevelopment,
        "throwing": .physicalDevelopment,
        
        // PSED
        "sharing": .personalSocialEmotional,
        "turn-taking": .personalSocialEmotional,
        "confidence": .personalSocialEmotional,
        "feelings": .personalSocialEmotional,
        "emotions": .personalSocialEmotional,
        "friendship": .personalSocialEmotional,
        "behaviour": .personalSocialEmotional,
        "independence": .personalSocialEmotional,
        "empathy": .personalSocialEmotional,
        "cooperating": .personalSocialEmotional,
        
        // Literacy
        "reading": .literacy,
        "writing": .literacy,
        "letters": .literacy,
        "phonics": .literacy,
        "books": .literacy,
        "mark-making": .literacy,
        "drawing": .literacy,
        
        // Mathematics
        "counting": .mathematics,
        "numbers": .mathematics,
        "shapes": .mathematics,
        "measuring": .mathematics,
        "sorting": .mathematics,
        "patterns": .mathematics,
        "comparing": .mathematics,
        
        // Understanding the World
        "exploring": .understandingTheWorld,
        "nature": .understandingTheWorld,
        "science": .understandingTheWorld,
        "technology": .understandingTheWorld,
        "animals": .understandingTheWorld,
        "plants": .understandingTheWorld,
        "seasons": .understandingTheWorld,
        "environment": .understandingTheWorld,
        
        // Expressive Arts & Design
        "painting": .expressiveArtsAndDesign,
        "music": .expressiveArtsAndDesign,
        "creative": .expressiveArtsAndDesign,
        "dance": .expressiveArtsAndDesign,
        "role-play": .expressiveArtsAndDesign,
        "imagination": .expressiveArtsAndDesign,
        "craft": .expressiveArtsAndDesign,
        "colour": .expressiveArtsAndDesign,
        "art": .expressiveArtsAndDesign
    ]
    
    // MARK: - Sentiment Analysis (Core AI Feature)
    
    /// Analyze sentiment using the NaturalLanguage sentimentScore scheme.
    /// Returns raw score (-1.0 to 1.0) as required by the assignment spec.
    func analyzeSentiment(text: String) -> Double {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return 0.0 }

        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = trimmed
        let (sentiment, _) = tagger.tag(
            at: trimmed.startIndex,
            unit: .paragraph,
            scheme: .sentimentScore
        )
        return Double(sentiment?.rawValue ?? "0") ?? 0.0
    }

    /// Build a full SentimentAnalysisResult using raw and normalized scores.
    func analyzeSentimentResult(text: String, diaryEntryId: UUID = UUID()) -> SentimentAnalysisResult {
        let rawScore = analyzeSentiment(text: text)
        let normalizedScore = normalizeSentimentScore(rawScore)
        let category: SentimentAnalysisResult.SentimentCategory =
            rawScore >= ManagerConstants.sentimentPositiveRawThreshold ? .positive :
            rawScore >= ManagerConstants.sentimentNeutralRawThreshold ? .neutral : .concern
        let keywords = extractKeywords(from: text)

        return SentimentAnalysisResult(
            diaryEntryId: diaryEntryId,
            rawScore: rawScore,
            normalized: normalizedScore,
            category: category,
            keywords: keywords
        )
    }
    
    /// Analyze sentiment for a specific diary entry
    func analyzeSentiment(entry: DiaryEntry) -> SentimentAnalysisResult {
        analyzeSentimentResult(text: entry.notes, diaryEntryId: entry.id)
    }
    
    // MARK: - Keyword Extraction (EYFS Vocabulary Detection)
    
    /// Extract developmental keywords from text using NLTokenizer with NLTagger filtering.
    /// Filters for nouns, verbs, and adjectives with length > 3 characters.
    func extractKeywords(from text: String) -> [String] {
        guard !text.isEmpty else { return [] }

        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text

        let stopWords: Set<String> = [
            "and", "with", "from", "that", "this", "were", "they",
            "them", "then", "into", "near", "over", "under", "very"
        ]

        var keywords: [String] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            let word = String(text[range]).lowercased()
            if word.count <= 3 || stopWords.contains(word) {
                return true
            }

            let (tag, _) = tagger.tag(
                at: range.lowerBound,
                unit: .word,
                scheme: .lexicalClass
            )
            if tag == .noun || tag == .verb || tag == .adjective {
                keywords.append(word)
            }
            return true
        }

        return Array(Set(keywords))
    }
    
    /// Extract keywords and map them to EYFS areas
    func extractEYFSKeywords(from text: String) -> [String: EYFSArea] {
        let keywords = extractKeywords(from: text)
        var mapped: [String: EYFSArea] = [:]
        
        for keyword in keywords {
            if let area = eyfsKeywordMap[keyword] {
                mapped[keyword] = area
            }
        }
        
        return mapped
    }
    
    // MARK: - Location Entity Extraction (Incident Analysis)
    
    /// Extract location entities from incident descriptions using NLTagger nameType scheme.
    /// Uses NER (Named Entity Recognition) to identify place names.
    func extractLocations(from text: String) -> [String] {
        guard !text.isEmpty else { return [] }
        
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        
        var locations: [String] = []
        let options: NLTagger.Options = [.omitWhitespace, .joinNames]
        
        tagger.enumerateTags(
            in: text.startIndex..<text.endIndex,
            unit: .word,
            scheme: .nameType,
            options: options
        ) { tag, range in
            if tag == .placeName {
                locations.append(String(text[range]))
            }
            return true
        }
        
        // Also extract location-like keywords from the text pattern
        // Nursery-specific location detection (NER may miss indoor locations)
        let nurseryLocations = [
            "outdoor play area", "climbing frame", "main playroom", "art station",
            "dining area", "book corner", "sunshine room", "rainbow room",
            "star room", "garden", "sand pit", "kitchen", "bathroom",
            "sleep room", "sensory room", "music area", "reception",
            "cloakroom", "corridor", "entrance", "car park"
        ]
        
        let lowerText = text.lowercased()
        for loc in nurseryLocations {
            if lowerText.contains(loc) && !locations.map({ $0.lowercased() }).contains(loc) {
                // Capitalize the found location
                locations.append(loc.capitalized)
            }
        }
        
        return Array(Set(locations))
    }
    
    // MARK: - Language Detection (Ofsted Compliance)
    
    /// Detect the language of a text string using NLLanguageRecognizer.
    /// All nursery records must be in English for Ofsted compliance.
    func detectLanguage(of text: String) -> (language: NLLanguage, confidence: Double) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return (.undetermined, 0.0)
        }
        
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        
        let language = recognizer.dominantLanguage ?? .undetermined
        let hypotheses = recognizer.languageHypotheses(withMaximum: 1)
        let confidence = hypotheses.first?.value ?? 0.0
        
        return (language, confidence)
    }
    
    /// Check if text is in English
    func isEnglish(_ text: String) -> Bool {
        let (language, confidence) = detectLanguage(of: text)
        return language == .english && confidence > 0.5
    }
    
    // MARK: - Aggregate Wellbeing Score
    
    /// Compute an aggregate wellbeing score (0-100) for a child based on their diary entries.
    /// Uses weighted average: recent entries (last 7 days) = 60%, older entries = 40%.
    func computeWellbeingScore(entries: [DiaryEntry]) -> Double {
        let notedEntries = entries.filter { !$0.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        guard !notedEntries.isEmpty else { return 50.0 } // neutral default
        
        let now = Date()
        let calendar = Calendar.current
        
        let recentEntries = notedEntries.filter {
            let days = calendar.dateComponents([.day], from: $0.timestamp, to: now).day ?? 99
            return days < ManagerConstants.recentWindowDays
        }
        
        let olderEntries = notedEntries.filter {
            let days = calendar.dateComponents([.day], from: $0.timestamp, to: now).day ?? 0
            return days >= ManagerConstants.recentWindowDays
        }
        
        let recentScores = recentEntries.compactMap { entry -> Double? in
            guard !entry.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
            return analyzeSentimentResult(text: entry.notes, diaryEntryId: entry.id).normalizedScore
        }
        
        let olderScores = olderEntries.compactMap { entry -> Double? in
            guard !entry.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
            return analyzeSentimentResult(text: entry.notes, diaryEntryId: entry.id).normalizedScore
        }
        
        let recentAvg = recentScores.isEmpty ? 50.0 : recentScores.reduce(0, +) / Double(recentScores.count)
        let olderAvg = olderScores.isEmpty ? 50.0 : olderScores.reduce(0, +) / Double(olderScores.count)
        
        if recentScores.isEmpty && olderScores.isEmpty {
            return 50.0
        } else if recentScores.isEmpty {
            return olderAvg
        } else if olderScores.isEmpty {
            return recentAvg
        }
        
        return (recentAvg * 0.6) + (olderAvg * 0.4)
    }
    
    /// Compute the wellbeing trend by comparing recent 7 days vs previous 7 days
    func computeWellbeingTrend(entries: [DiaryEntry]) -> WellbeingTrend {
        let now = Date()
        let calendar = Calendar.current
        
        let recentEntries = entries.filter {
            let days = calendar.dateComponents([.day], from: $0.timestamp, to: now).day ?? 99
            return days < 7
        }
        
        let olderEntries = entries.filter {
            let days = calendar.dateComponents([.day], from: $0.timestamp, to: now).day ?? 99
            return days >= 7 && days < 14
        }
        
        let recentScores = recentEntries.compactMap { entry -> Double? in
            guard !entry.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
            return analyzeSentimentResult(text: entry.notes, diaryEntryId: entry.id).normalizedScore
        }
        
        let olderScores = olderEntries.compactMap { entry -> Double? in
            guard !entry.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
            return analyzeSentimentResult(text: entry.notes, diaryEntryId: entry.id).normalizedScore
        }
        
        guard !recentScores.isEmpty, !olderScores.isEmpty else { return .stable }
        
        let recentAvg = recentScores.reduce(0, +) / Double(recentScores.count)
        let olderAvg = olderScores.reduce(0, +) / Double(olderScores.count)
        
        let diff = recentAvg - olderAvg
        
        if diff > 5 {
            return .improving
        } else if diff < -5 {
            return .declining
        } else {
            return .stable
        }
    }
    
    /// Generate daily sentiment scores over the analysis window
    func dailySentimentScores(entries: [DiaryEntry], days: Int = 14) -> [(date: Date, score: Double)] {
        let calendar = Calendar.current
        var dailyScores: [(date: Date, score: Double)] = []
        
        for dayOffset in (0..<days).reversed() {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date())!
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
            
            let dayEntries = entries.filter {
                $0.timestamp >= startOfDay && $0.timestamp <= endOfDay &&
                !$0.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            
            if dayEntries.isEmpty {
                // Use 50 (neutral) for days with no entries
                dailyScores.append((date: startOfDay, score: 50.0))
            } else {
                let scores = dayEntries.map { analyzeSentimentResult(text: $0.notes, diaryEntryId: $0.id).normalizedScore }
                let avg = scores.reduce(0, +) / Double(scores.count)
                dailyScores.append((date: startOfDay, score: avg))
            }
        }
        
        return dailyScores
    }

    private func normalizeSentimentScore(_ rawScore: Double) -> Double {
        ((rawScore + 1.0) / 2.0) * 100.0
    }
}
