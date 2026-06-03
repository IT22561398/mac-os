// HapticManager.swift
// NurseryConnect
// Centralized haptic feedback for all app interactions

import Foundation
#if canImport(UIKit)
import UIKit
#endif

struct HapticManager {
    
    // Define a dummy enum for macOS so that method signatures match
#if os(macOS)
    enum DummyFeedbackStyle { case light, medium, heavy }
    enum DummyFeedbackType { case success, warning, error }
    typealias FeedbackStyle = DummyFeedbackStyle
    typealias FeedbackType = DummyFeedbackType
#else
    typealias FeedbackStyle = UIImpactFeedbackGenerator.FeedbackStyle
    typealias FeedbackType = UINotificationFeedbackGenerator.FeedbackType
#endif

    static func impact(_ style: FeedbackStyle = .medium) {
#if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
#endif
    }
    
    static func notification(_ type: FeedbackType) {
#if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
#endif
    }
    
    static func selection() {
#if canImport(UIKit)
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
#endif
    }
    
    // Convenience methods
    static func lightTap() {
        impact(.light)
    }
    
    static func mediumTap() {
        impact(.medium)
    }
    
    static func heavyTap() {
        impact(.heavy)
    }
    
    static func success() {
        notification(.success)
    }
    
    static func warning() {
        notification(.warning)
    }
    
    static func error() {
        notification(.error)
    }
}
