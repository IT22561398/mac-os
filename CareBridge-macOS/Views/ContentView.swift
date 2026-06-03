// ContentView.swift
// NurseryConnect — Setting Manager (macOS)
// Root view with NavigationSplitView three-column layout

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(SettingManagerDashboardViewModel.self) private var viewModel
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    var body: some View {
        @Bindable var vm = viewModel
        
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // COLUMN 1 — Sidebar
            SidebarView(selection: $vm.selectedSidebarItem)
                .navigationSplitViewColumnWidth(min: 200, ideal: 220, max: 260)
        } content: {
            // COLUMN 2 — Content List
            ContentListView(
                selection: vm.selectedSidebarItem,
                selectedChildId: $vm.selectedChildId,
                selectedIncident: $vm.selectedIncident
            )
            .navigationSplitViewColumnWidth(min: 280, ideal: 320, max: 400)
        } detail: {
            // COLUMN 3 — Detail
            DetailColumnView(
                selectedChild: vm.selectedChild,
                selectedIncident: vm.selectedIncident,
                sidebarSelection: vm.selectedSidebarItem
            )
        }
        .navigationSplitViewStyle(.balanced)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar) {
                    Image(systemName: "sidebar.left")
                }
                .help(ManagerText.Toolbar.toggleSidebarHelp)
            }
            
            ToolbarItem(placement: .principal) {
                HStack(spacing: 12) {
                    Image(systemName: "building.2.fill")
                        .foregroundStyle(.ncPrimary)
                        .font(.title3)
                    
                    Text(ManagerConstants.appTitle)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    if viewModel.isAnalyzing {
                        ProgressView()
                            .controlSize(.small)
                            .padding(.leading, 4)
                        Text(ManagerText.analyzingLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task { await viewModel.runNLAnalysis() }
                } label: {
                    Label(ManagerText.Toolbar.refreshAiLabel, systemImage: "brain.head.profile")
                }
                .keyboardShortcut("r", modifiers: [.command, .shift])
                .help(ManagerText.Toolbar.refreshAiHelp)
                .disabled(viewModel.isAnalyzing)
            }
        }
        .task {
            await viewModel.runNLAnalysis()
        }
        .onReceive(NotificationCenter.default.publisher(for: .openIncidentQueue)) { _ in
            viewModel.selectedSidebarItem = .incidentQueue
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToReports)) { _ in
            viewModel.selectedSidebarItem = .reports
        }
    }
    
    private func toggleSidebar() {
        withAnimation {
            if columnVisibility == .all {
                columnVisibility = .doubleColumn
            } else {
                columnVisibility = .all
            }
        }
    }
}

// MARK: - Content List View (Column 2)
struct ContentListView: View {
    let selection: SidebarItem
    @Binding var selectedChildId: UUID?
    @Binding var selectedIncident: Incident?
    
    var body: some View {
        switch selection {
        case .overview:
            OverviewContentList()
        case .allChildren:
            ChildrenListView(selectedChildId: $selectedChildId)
        case .incidentQueue:
            IncidentQueueView(selectedIncident: $selectedIncident)
        case .aiInsights:
            AIInsightsListView(selectedChildId: $selectedChildId)
        case .reports:
            ReportGeneratorView()
        case .settings:
            SettingsContentView()
        }
    }
}

// MARK: - Detail Column View (Column 3)
struct DetailColumnView: View {
    @Environment(ReportViewModel.self) private var reportVM
    let selectedChild: ChildProfile?
    let selectedIncident: Incident?
    let sidebarSelection: SidebarItem
    
    var body: some View {
        Group {
            switch sidebarSelection {
            case .overview:
                OverviewDashboardView()
            case .allChildren, .aiInsights:
                if let child = selectedChild {
                    ChildDevelopmentDetailView(childId: child.id)
                        .id(child.id)
                } else {
                    EmptyDetailView(
                        icon: "person.crop.circle.badge.questionmark",
                        title: ManagerText.EmptyState.selectChildTitle,
                        subtitle: ManagerText.EmptyState.selectChildSubtitle
                    )
                }
            case .incidentQueue:
                if let incident = selectedIncident {
                    IncidentReviewDetailView(incident: incident)
                        .id(incident.id)
                } else {
                    EmptyDetailView(
                        icon: "checkmark.shield",
                        title: ManagerText.EmptyState.noIncidentTitle,
                        subtitle: ManagerText.EmptyState.noIncidentSubtitle
                    )
                }
            case .reports:
                if let pdfData = reportVM.generatedPDFData {
                    PDFPreviewView(pdfData: pdfData)
                } else {
                    EmptyDetailView(
                        icon: "doc.text.magnifyingglass",
                        title: ManagerText.EmptyState.reportPreviewTitle,
                        subtitle: ManagerText.EmptyState.reportPreviewSubtitle
                    )
                }
            case .settings:
                EmptyDetailView(
                    icon: "gearshape.2",
                    title: ManagerText.EmptyState.settingsTitle,
                    subtitle: ManagerText.EmptyState.settingsSubtitle
                )
            }
        }
    }
}

// MARK: - Empty Detail Placeholder
struct EmptyDetailView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundStyle(.tertiary)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            Text(subtitle)
                .font(.body)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Overview Content List
struct OverviewContentList: View {
    @Environment(SettingManagerDashboardViewModel.self) private var viewModel
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        List {
            Section(ManagerText.OverviewList.quickActions) {
                Label(ManagerText.OverviewList.actionViewChildren, systemImage: "person.3.fill")
                    .foregroundStyle(.ncPrimary)
                    .onDrop(of: [UTType.text], isTargeted: nil) { providers in
                        guard let provider = providers.first else { return false }
                        _ = provider.loadObject(ofClass: NSString.self) { string, _ in
                            if let string = string as? String, let uuid = UUID(uuidString: string) {
                                DispatchQueue.main.async {
                                    openWindow(value: uuid)
                                }
                            }
                        }
                        return true
                    }
                Label(ManagerText.OverviewList.actionReviewIncidents, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.ncSecondary)
                Label(ManagerText.OverviewList.actionGenerateReport, systemImage: "doc.text.fill")
                    .foregroundStyle(.ncWarning)
            }
            
            Section(ManagerText.OverviewList.recentAlerts(viewModel.wellbeingAlerts.count)) {
                ForEach(viewModel.wellbeingAlerts.prefix(5)) { alert in
                    HStack {
                        Image(systemName: alert.alertType.iconName)
                            .foregroundStyle(alert.alertType.severityColor)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(alert.childName)
                                .font(.callout.weight(.medium))
                            Text(alert.alertType.displayName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle(ManagerText.Menu.overview)
    }
}

// MARK: - Settings Content
struct SettingsContentView: View {
    @Environment(ManagerDataService.self) private var dataService
    
    var body: some View {
        List {
            Section(ManagerText.Settings.managerProfile) {
                LabeledContent(ManagerText.Settings.name, value: dataService.managerProfile.fullName)
                LabeledContent(ManagerText.Settings.role, value: dataService.managerProfile.role)
                LabeledContent(ManagerText.Settings.nursery, value: dataService.managerProfile.nurseryName)
            }
            
            Section("Account") {
                Button("Switch Role / Logout") {
                    NotificationCenter.default.post(name: .logout, object: nil)
                }
                .foregroundStyle(.ncSecondary)
            }
            
            Section(ManagerText.Settings.dataManagement) {
                Button(ManagerText.Settings.resetSampleData) {
                    dataService.resetToSampleData()
                }
                .foregroundStyle(.ncSecondary)
            }
            
            Section(ManagerText.Settings.about) {
                LabeledContent(ManagerText.Settings.app, value: ManagerText.Settings.appValue)
                LabeledContent(ManagerText.Settings.version, value: ManagerText.Settings.versionValue)
                LabeledContent(ManagerText.Settings.platform, value: ManagerText.Settings.platformValue)
                LabeledContent(ManagerText.Settings.framework, value: ManagerText.Settings.frameworkValue)
            }
        }
        .listStyle(.inset)
        .navigationTitle(ManagerText.EmptyState.settingsTitle)
    }
}
