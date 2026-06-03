// CareBridgeApp.swift
// NurseryConnect — Setting Manager (macOS)
// App entry point with WindowGroup, multi-window support, and macOS Menu Commands

import SwiftUI
import AppKit

enum AppRole {
    case keyworker
    case manager
}

@main
struct CareBridgeApp: App {
    @State private var currentRole: AppRole? = nil
    
    // Shared State for Manager
    @State private var dashboardVM = SettingManagerDashboardViewModel()
    @State private var dataService = ManagerDataService.shared
    @State private var reportVM = ReportViewModel()
    
    // Shared State for Keyworker
    @State private var appState = AppState()
    
    var body: some Scene {
        // MARK: - Main Window
        WindowGroup(ManagerText.mainWindowTitle) {
            mainViewWithLogout
                .frame(minWidth: 1100, minHeight: 700)
        }
        .defaultSize(width: 1280, height: 800)
        .commands {
            // Replace default New Item
            CommandGroup(replacing: .newItem) {
                Button(ManagerText.Menu.newIncidentWindow) {
                    // Opens incident queue — handled via notification
                    NotificationCenter.default.post(
                        name: .openIncidentQueue, object: nil
                    )
                }
                .keyboardShortcut("i", modifiers: [.command, .shift])
            }
            
            // Reports menu
            CommandMenu(ManagerText.Menu.reports) {
                Button(ManagerText.Menu.exportWeeklySummary) {
                    NotificationCenter.default.post(
                        name: .navigateToReports, object: nil
                    )
                }
                .keyboardShortcut("e", modifiers: [.command])
                
                Button(ManagerText.Menu.generateEyfsReport) {
                    NotificationCenter.default.post(
                        name: .navigateToReports, object: "eyfs"
                    )
                }
                
                Divider()
                
                Button(ManagerText.Menu.refreshAiAnalysis) {
                    Task {
                        await dashboardVM.runNLAnalysis()
                    }
                }
                .keyboardShortcut("r", modifiers: [.command, .shift])
            }
            
            // Account & Debug menu
            CommandMenu("Account") {
                Button("Switch Role / Logout") {
                    NotificationCenter.default.post(
                        name: .logout, object: nil
                    )
                }
                .keyboardShortcut("l", modifiers: [.command, .shift])
                
                Divider()
                
                Button("Run Diagnostics & Tests") {
                    NotificationCenter.default.post(
                        name: .openDiagnostics, object: nil
                    )
                }
                .keyboardShortcut("d", modifiers: [.command, .shift])
            }
            
            // View menu
            CommandMenu(ManagerText.Menu.view) {
                Button(ManagerText.Menu.overview) {
                    dashboardVM.selectedSidebarItem = .overview
                }
                .keyboardShortcut("1", modifiers: [.command])
                
                Button(ManagerText.Menu.allChildren) {
                    dashboardVM.selectedSidebarItem = .allChildren
                }
                .keyboardShortcut("2", modifiers: [.command])
                
                Button(ManagerText.Menu.incidentQueue) {
                    dashboardVM.selectedSidebarItem = .incidentQueue
                }
                .keyboardShortcut("3", modifiers: [.command])
                
                Button(ManagerText.Menu.aiInsights) {
                    dashboardVM.selectedSidebarItem = .aiInsights
                }
                .keyboardShortcut("4", modifiers: [.command])
                
                Button(ManagerText.Menu.reportsItem) {
                    dashboardVM.selectedSidebarItem = .reports
                }
                .keyboardShortcut("5", modifiers: [.command])
            }
        }
        
        // MARK: - Child Profile Window (Multi-Window)
        WindowGroup(ManagerText.childProfileWindowTitle, for: UUID.self) { $childId in
            if let id = childId {
                ChildDevelopmentDetailView(childId: id)
                    .environment(dataService)
            }
        }
        .defaultSize(width: 900, height: 700)
        
        // MARK: - Diagnostics & Testing Window
        WindowGroup("Diagnostics & Testing Dashboard", id: "diagnostics") {
            DiagnosticsDashboardView()
        }
        .defaultSize(width: 600, height: 500)
        
        // MARK: - Settings Window
        Settings {
            SettingsContentView()
                .environment(dataService)
                .frame(width: 450, height: 350)
        }
        
        // MARK: - Menu Bar Extra (Status Bar App)
        MenuBarExtra("NurseryConnect Status", systemImage: "building.2.crop.circle.fill") {
            Button("Open Dashboard") {
                dashboardVM.selectedSidebarItem = .overview
            }
            Button("View Incident Queue") {
                dashboardVM.selectedSidebarItem = .incidentQueue
            }
            
            Divider()
            
            Button("Refresh AI Insights") {
                Task { await dashboardVM.runNLAnalysis() }
            }
            
            Divider()
            
            Button("Quit NurseryConnect") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: [.command])
        }
    }
    
    @ViewBuilder
    private var mainView: some View {
        if let role = currentRole {
            if role == .manager {
                ContentView()
                    .environment(dashboardVM)
                    .environment(dataService)
                    .environment(reportVM)
                    .onAppear {
                        // Load enhanced sample data on first launch
                        if !UserDefaults.standard.bool(forKey: "nc_manager_data_loaded") {
                            let entries = ManagerSampleData.generateEnhancedDiaryEntries()
                            DataManager.shared.diaryEntries = entries
                            DataManager.shared.save()
                            UserDefaults.standard.set(true, forKey: "nc_manager_data_loaded")
                        }
                    }
            } else {
                KeyworkerContentView()
                    .environment(appState)
                    .environment(DataManager.shared)
                    .environment(ThemeManager())
                    .environment(AttendanceManager.shared)
                    .environment(MessageManager.shared)
                    .environment(NotificationManager.shared)
                    .environment(SleepTrackerManager.shared)
            }
        } else {
            RoleSelectionView(selectedRole: $currentRole)
                .frame(minWidth: 800, minHeight: 600)
        }
    }
    
    // Extracted view with onReceive
    @Environment(\.openWindow) private var openWindow
    
    @ViewBuilder
    private var mainViewWithLogout: some View {
        mainView
            .onReceive(NotificationCenter.default.publisher(for: .logout)) { _ in
                withAnimation {
                    currentRole = nil
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .openDiagnostics)) { _ in
                openWindow(id: "diagnostics")
            }
    }
}

// MARK: - Notification Names for Menu Commands
extension Notification.Name {
    static let openIncidentQueue = Notification.Name("openIncidentQueue")
    static let navigateToReports = Notification.Name("navigateToReports")
    static let logout = Notification.Name("logout")
    static let openDiagnostics = Notification.Name("openDiagnostics")
}
