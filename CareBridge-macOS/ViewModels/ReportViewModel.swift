// ReportViewModel.swift
// NurseryConnect — Setting Manager (macOS)
// ViewModel for Report Generation — HTML styled reporting

import Foundation
import SwiftUI
import NaturalLanguage

@Observable
@MainActor
class ReportViewModel {
    // MARK: - Dependencies
    private let dataService = ManagerDataService.shared
    private let nlService = NLAnalysisService.shared
    
    // MARK: - State
    var startDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    var endDate: Date = Date()
    var reportType: ReportType = .weeklySummary
    var generatedReport: String = "" // HTML string
    var generatedPDFData: Data? = nil
    var isGenerating: Bool = false
    var nonEnglishEntries: [DiaryEntry] = []
    
    // MARK: - Generate Report
    
    func generateReport() {
        isGenerating = true
        
        // EDGE CASE: Start date cannot be after end date
        if startDate > endDate {
            AppLogger.ui.error("Edge case caught: startDate is after endDate.")
            endDate = startDate
        }
        
        var htmlContent = ""
        switch reportType {
        case .weeklySummary:
            htmlContent = generateWeeklySummary()
        case .incidentReport:
            htmlContent = generateIncidentReport()
        case .eyfsCoverage:
            htmlContent = generateEYFSCoverageReport()
        }
        
        generatedReport = htmlContent
        generatedPDFData = PDFGenerator.generatePDF(from: htmlContent)
        
        // Check language compliance
        checkLanguageCompliance()
        
        isGenerating = false
    }
    
    // MARK: - HTML Template
    private func getHTMLTemplate(title: String, content: String) -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="utf-8">
        <style>
            body { font-family: -apple-system, Helvetica, sans-serif; padding: 20px; color: #333; line-height: 1.6; }
            h1 { color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }
            h2 { color: #2980b9; margin-top: 30px; border-bottom: 1px solid #eee; padding-bottom: 5px; }
            .header { margin-bottom: 30px; }
            .header p { margin: 5px 0; }
            table { width: 100%; border-collapse: collapse; margin-top: 15px; font-size: 14px; }
            th, td { border: 1px solid #e0e0e0; padding: 10px; text-align: left; }
            th { background-color: #f4f6f8; color: #2c3e50; font-weight: 600; }
            tr:nth-child(even) { background-color: #fafafa; }
            .card { background: #f8f9fa; border-left: 4px solid #3498db; padding: 15px; margin-bottom: 15px; page-break-inside: avoid; }
            .card h3 { margin-top: 0; color: #2c3e50; }
            .badge { display: inline-block; padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; }
            .footer { margin-top: 50px; font-size: 12px; color: #7f8c8d; text-align: center; border-top: 1px solid #eee; padding-top: 20px; page-break-inside: avoid; }
            .grid { display: flex; flex-wrap: wrap; gap: 10px; margin-top: 10px; }
            .stat-box { background: #fff; border: 1px solid #ddd; padding: 10px; border-radius: 6px; width: 30%; text-align: center; }
            .stat-box .num { font-size: 24px; font-weight: bold; color: #3498db; }
            .stat-box .label { font-size: 12px; color: #7f8c8d; text-transform: uppercase; }
        </style>
        </head>
        <body>
            <div class="header">
                <h1>\(title)</h1>
                <p><strong>Setting:</strong> \(ManagerConstants.nurseryName)</p>
                <p><strong>Manager:</strong> \(dataService.managerProfile.fullName)</p>
                <p><strong>Period:</strong> \(startDate.shortDateString) &mdash; \(endDate.shortDateString)</p>
                <p><strong>Generated:</strong> \(Date().fullDateTimeString)</p>
            </div>
            \(content)
            <div class="footer">
                This report was generated securely by NurseryConnect AI Analytics.<br>
                Contains confidential data. Do not distribute without authorization.
            </div>
        </body>
        </html>
        """
    }
    
    // MARK: - Weekly Summary
    
    private func generateWeeklySummary() -> String {
        let entries = filteredDiaryEntries()
        let incidents = filteredIncidents()
        let children = dataService.allChildren
        
        var content = """
        <h2>Overview</h2>
        <div class="grid">
            <div class="stat-box"><div class="num">\(children.count)</div><div class="label">Children</div></div>
            <div class="stat-box"><div class="num">\(entries.count)</div><div class="label">Diary Entries</div></div>
            <div class="stat-box"><div class="num">\(incidents.count)</div><div class="label">Incidents</div></div>
        </div>
        
        <h2>Child Summaries</h2>
        """
        
        for child in children {
            let childEntries = entries.filter { $0.childId == child.id }
            let childIncidents = incidents.filter { $0.childId == child.id }
            let score = dataService.wellbeingScores[child.id] ?? 50.0
            
            let activities = childEntries.filter { $0.type == .activity }.count
            let meals = childEntries.filter { $0.type == .meal }.count
            let sleeps = childEntries.filter { $0.type == .sleep }.count
            let wellbeings = childEntries.filter { $0.type == .wellbeing }.count
            
            content += """
            <div class="card">
                <h3>\(child.fullName) (\(child.age)) &mdash; \(child.roomAssignment)</h3>
                <p><strong>AI Wellbeing Score:</strong> \(String(format: "%.1f", score))/100</p>
                <p><strong>Logs:</strong> Activities: \(activities) | Meals: \(meals) | Sleep: \(sleeps) | Wellbeing: \(wellbeings)</p>
                <p><strong>Incidents:</strong> \(childIncidents.count)</p>
            </div>
            """
        }
        
        if !incidents.isEmpty {
            content += """
            <h2>Incident Summary</h2>
            <table>
                <tr><th>Date</th><th>Child</th><th>Category</th><th>Status</th><th>Description</th></tr>
            """
            for incident in incidents {
                let childName = dataService.childName(for: incident.childId)
                content += """
                <tr>
                    <td>\(incident.dateTime.shortDateString)</td>
                    <td>\(childName)</td>
                    <td>\(incident.category.rawValue)</td>
                    <td>\(incident.status.rawValue)</td>
                    <td>\(incident.description.prefix(80))...</td>
                </tr>
                """
            }
            content += "</table>"
        }
        
        return getHTMLTemplate(title: "Weekly Summary Report", content: content)
    }
    
    // MARK: - Incident Report
    
    private func generateIncidentReport() -> String {
        let incidents = filteredIncidents()
        
        var content = """
        <h2>Overview</h2>
        <p>Total Incidents in Period: <strong>\(incidents.count)</strong></p>
        
        <h2>Detailed Incident Log</h2>
        """
        
        for incident in incidents {
            let childName = dataService.childName(for: incident.childId)
            let locations = nlService.extractLocations(from: incident.description)
            let extLocs = locations.isEmpty ? "None detected" : locations.joined(separator: ", ")
            
            var reviewHTML = ""
            if let reviewer = incident.reviewerName {
                reviewHTML = "<p><strong>Reviewed by:</strong> \(reviewer)</p>"
            }
            if let notes = incident.reviewNotes {
                reviewHTML += "<p><strong>Review Notes:</strong> \(notes)</p>"
            }
            
            content += """
            <div class="card">
                <h3>Incident: \(childName) (\(incident.dateTime.shortDateString))</h3>
                <table style="margin-top: 10px; margin-bottom: 10px;">
                    <tr><td><strong>Date/Time</strong></td><td>\(incident.dateTime.fullDateTimeString)</td></tr>
                    <tr><td><strong>Category</strong></td><td>\(incident.category.rawValue) (Severity: \(incident.category.severity.rawValue))</td></tr>
                    <tr><td><strong>Status</strong></td><td>\(incident.status.rawValue)</td></tr>
                    <tr><td><strong>Location</strong></td><td>\(incident.location)</td></tr>
                    <tr><td><strong>AI Extracted Locations</strong></td><td>\(extLocs)</td></tr>
                </table>
                <p><strong>Description:</strong><br>\(incident.description)</p>
                <p><strong>Immediate Action:</strong><br>\(incident.immediateActionTaken)</p>
                <p><strong>Witnesses:</strong> \(incident.witnesses.joined(separator: ", "))</p>
                \(reviewHTML)
            </div>
            """
        }
        
        return getHTMLTemplate(title: "Incident Report", content: content)
    }
    
    // MARK: - EYFS Coverage Report
    
    private func generateEYFSCoverageReport() -> String {
        let children = dataService.allChildren
        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 7
        
        var content = """
        <h2>EYFS Area Coverage Per Child</h2>
        <table>
            <tr>
                <th>Child</th>
        """
        
        for area in EYFSArea.allCases {
            content += "<th>\(area.shortName)</th>"
        }
        content += "</tr>"
        
        for child in children {
            let coverage = dataService.eyfsAreaCoverage(for: child.id, days: days)
            content += "<tr><td><strong>\(child.firstName)</strong></td>"
            for area in EYFSArea.allCases {
                let count = coverage[area] ?? 0
                let display = count == 0 ? "⚠️" : "\(count)"
                content += "<td>\(display)</td>"
            }
            content += "</tr>"
        }
        content += "</table>"
        content += "<p style='font-size: 12px; color: #e74c3c; margin-top: 10px;'>⚠️ Indicates no entries logged for this EYFS area (coverage gap).</p>"
        
        content += "<h2>Recommendations</h2><div class='card'>"
        var hasGaps = false
        for child in children {
            let coverage = dataService.eyfsAreaCoverage(for: child.id, days: days)
            let gaps = EYFSArea.allCases.filter { (coverage[$0] ?? 0) == 0 }
            if !gaps.isEmpty {
                hasGaps = true
                content += "<p><strong>\(child.fullName):</strong> Plan activities for \(gaps.map { $0.shortName }.joined(separator: ", "))</p>"
            }
        }
        if !hasGaps {
            content += "<p>All children have coverage across all EYFS areas.</p>"
        }
        content += "</div>"
        
        return getHTMLTemplate(title: "EYFS Coverage Report", content: content)
    }
    
    // MARK: - Language Compliance Check
    
    private func checkLanguageCompliance() {
        let entries = filteredDiaryEntries()
        nonEnglishEntries = entries.filter { entry in
            let text = entry.notes
            guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
            return !nlService.isEnglish(text)
        }
    }
    
    // MARK: - Helpers
    
    private func filteredDiaryEntries() -> [DiaryEntry] {
        dataService.allDiaryEntries.filter {
            $0.timestamp >= startDate.startOfDay && $0.timestamp <= endDate.endOfDay
        }
    }
    
    private func filteredIncidents() -> [Incident] {
        dataService.allIncidents.filter {
            $0.dateTime >= startDate.startOfDay && $0.dateTime <= endDate.endOfDay
        }
    }
    
    func detectLanguage(of text: String) -> NLLanguage {
        let (language, _) = nlService.detectLanguage(of: text)
        return language
    }
}
