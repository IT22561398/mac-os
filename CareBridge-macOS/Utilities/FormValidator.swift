// FormValidator.swift
// NurseryConnect
// Form validation helpers for incident and diary forms

import Foundation

struct FormValidator {
    
    static func isNotEmpty(_ text: String) -> Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    static func minLength(_ text: String, length: Int) -> Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).count >= length
    }
    
    static func validateIncidentForm(
        description: String,
        location: String,
        actionTaken: String,
        category: IncidentCategory?
    ) -> [String] {
        var errors: [String] = []
        
        if category == nil {
            errors.append("Please select an incident category")
        }
        if !isNotEmpty(description) {
            errors.append("Description is required")
        }
        if !minLength(description, length: 10) {
            errors.append("Description must be at least 10 characters")
        }
        if !isNotEmpty(location) {
            errors.append("Location is required")
        }
        if !isNotEmpty(actionTaken) {
            errors.append("Immediate action taken must be recorded")
        }
        
        return errors
    }
    
    static func validateActivityLog(
        activityType: ActivityType?,
        description: String
    ) -> [String] {
        var errors: [String] = []
        
        if activityType == nil {
            errors.append("Please select an activity type")
        }
        if !isNotEmpty(description) {
            errors.append("A brief description is required")
        }
        
        return errors
    }
}
