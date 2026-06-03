// NurseryConnect | AppState.swift
// Shared @Observable state bridge — connects the FAB in CustomTabBar to the
// DiaryEntryFormView sheet presented by ContentView.
//
// STATE FLOW:
//   FAB tap → appState.fabSelectedEntryType = .activity
//            → appState.showFABSheet = true
//            → ContentView .sheet(isPresented:) fires
//            → DiaryEntryFormView pre-filled with type
//            → save() → sheet dismissed → toast in ContentView

import SwiftUI

// MARK: - AppState (iOS 17 @Observable)
@Observable
final class AppState {

    // MARK: FAB Navigation State
    /// The entry type the user tapped from the FAB menu.
    /// nil means no selection has been made yet.
    var fabSelectedEntryType: DiaryEntryType? = nil

    /// Set to true when the FAB action sheet should be presented.
    /// Owned and presented by ContentView.
    var showFABSheet: Bool = false

    /// Set to true when no child is selected in DiaryViewModel and we
    /// need to show the child-picker before opening the entry form.
    var showChildPickerFirst: Bool = false

    // MARK: - Sheet Navigation
    var showNotificationCenter: Bool = false
    var showMessagesView: Bool = false
    var showAttendanceView: Bool = false
    var showEndOfDayChecklist: Bool = false

    // MARK: - Global Toast
    /// Top-level toast accessible from any screen branched below ContentView.
    var globalToast: ToastData? = nil

    // MARK: - FAB Trigger
    /// Call from CustomTabBar when a FAB action item is tapped.
    /// Accepts an optional current child ID — if nil, child picker is shown first.
    func triggerFAB(entryType: DiaryEntryType, hasSelectedChild: Bool) {
        fabSelectedEntryType = entryType
        if hasSelectedChild {
            showFABSheet = true
        } else {
            showChildPickerFirst = true
        }
    }

    /// Clears all FAB navigation state after the sheet has been dismissed.
    func resetFABState() {
        fabSelectedEntryType = nil
        showFABSheet = false
        showChildPickerFirst = false
    }
}
