// Date+Extensions.swift
// NurseryConnect
// Date formatting helpers for diary entries, timestamps, and display

import Foundation

extension Date {
    // MARK: - Formatters (cached for performance)
    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()
    
    private static let time12Formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()
    
    private static let shortDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d MMM yyyy"
        return f
    }()
    
    private static let dayMonthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d MMM"
        return f
    }()
    
    private static let fullDateTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d MMM yyyy, HH:mm"
        return f
    }()
    
    private static let dayNameFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        return f
    }()
    
    private static let shortDayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f
    }()
    
    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        return f
    }()
    
    // MARK: - Formatted Strings
    var timeString: String {
        Date.timeFormatter.string(from: self)
    }
    
    var time12String: String {
        Date.time12Formatter.string(from: self)
    }
    
    var shortDateString: String {
        Date.shortDateFormatter.string(from: self)
    }
    
    var dayMonthString: String {
        Date.dayMonthFormatter.string(from: self)
    }
    
    var fullDateTimeString: String {
        Date.fullDateTimeFormatter.string(from: self)
    }
    
    var dayName: String {
        Date.dayNameFormatter.string(from: self)
    }
    
    var shortDayName: String {
        Date.shortDayFormatter.string(from: self)
    }
    
    // MARK: - Relative Time
    var relativeTimeString: String {
        let now = Date()
        let diff = now.timeIntervalSince(self)
        
        if diff < 60 {
            return "Just now"
        } else if diff < 3600 {
            let mins = Int(diff / 60)
            return "\(mins)m ago"
        } else if diff < 86400 {
            let hours = Int(diff / 3600)
            return "\(hours)h ago"
        } else if diff < 172800 {
            return "Yesterday"
        } else {
            return shortDateString
        }
    }
    
    // MARK: - Helpers
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self) ?? self
    }
    
    var startOfWeek: Date {
        let cal = Calendar.current
        let components = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return cal.date(from: components) ?? self
    }
    
    var ageInYears: Int {
        Calendar.current.dateComponents([.year], from: self, to: Date()).year ?? 0
    }
    
    var ageString: String {
        let components = Calendar.current.dateComponents([.year, .month], from: self, to: Date())
        let years = components.year ?? 0
        let months = components.month ?? 0
        
        if years == 0 {
            return "\(months) month\(months == 1 ? "" : "s")"
        } else if months == 0 {
            return "\(years) year\(years == 1 ? "" : "s")"
        } else {
            return "\(years)y \(months)m"
        }
    }
    
    // Duration between two dates
    func durationString(to end: Date) -> String {
        let diff = end.timeIntervalSince(self)
        let hours = Int(diff) / 3600
        let minutes = (Int(diff) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    // Create date with time components
    func settingTime(hour: Int, minute: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: self) ?? self
    }
    
    // Days ago
    static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    }
}

// MARK: - Duration Formatting
extension TimeInterval {
    var durationString: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes) min"
        }
    }
}
