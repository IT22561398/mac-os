// AppLogger.swift
// NurseryConnect — Setting Manager (macOS)
// Structured OSLog integration for comprehensive debugging

import Foundation
import os.log

struct AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.nurseryconnect.carebridge"
    
    // MARK: - Log Categories
    static let ui = Logger(subsystem: subsystem, category: "UI")
    static let network = Logger(subsystem: subsystem, category: "Network")
    static let data = Logger(subsystem: subsystem, category: "Data")
    static let analytics = Logger(subsystem: subsystem, category: "Analytics")
    static let testing = Logger(subsystem: subsystem, category: "Testing")
    
    // Static helper to quickly log application-level events
    static let app = Logger(subsystem: subsystem, category: "Application")
}
