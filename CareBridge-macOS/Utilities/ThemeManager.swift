// ThemeManager.swift
// NurseryConnect
// Manages app-wide theming and appearance settings

import SwiftUI

@Observable
class ThemeManager {
    var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    var accentColor: Color = .ncPrimary
    
    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
    }
    
    var colorScheme: ColorScheme {
        isDarkMode ? .dark : .light
    }
    
    func toggle() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isDarkMode.toggle()
        }
    }
}
