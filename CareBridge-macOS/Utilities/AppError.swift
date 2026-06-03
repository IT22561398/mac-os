// AppError.swift
// NurseryConnect — Setting Manager (macOS)
// Centralized Error Handling

import Foundation

enum AppError: LocalizedError, Identifiable, Equatable {
    case dataCorruption(reason: String)
    case validationError(message: String)
    case networkTimeout
    case aiServiceUnavailable(details: String)
    case unhandledException(Error)
    
    var id: String {
        self.localizedDescription
    }
    
    var errorDescription: String? {
        switch self {
        case .dataCorruption(let reason):
            return "Data Corruption Error: \(reason)"
        case .validationError(let message):
            return "Validation Error: \(message)"
        case .networkTimeout:
            return "Network Timeout: The server took too long to respond."
        case .aiServiceUnavailable(let details):
            return "AI Analysis Unavailable: \(details)"
        case .unhandledException(let error):
            return "Unexpected Error: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .dataCorruption:
            return "Please try resetting the application data to resolve this issue."
        case .validationError:
            return "Please review your inputs and try again."
        case .networkTimeout:
            return "Please check your internet connection and try again."
        case .aiServiceUnavailable:
            return "The AI analysis server might be down. Check your connection or try again later."
        case .unhandledException:
            return "If this problem persists, please contact support."
        }
    }
    
    // Equatable implementation
    static func == (lhs: AppError, rhs: AppError) -> Bool {
        lhs.id == rhs.id
    }
}
