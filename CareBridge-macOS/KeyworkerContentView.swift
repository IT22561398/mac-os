// NurseryConnect | ContentView.swift
// Main container view — hosts the tab bar, FAB overlay, and owns
// the AppState environment object that bridges FAB navigation.
//
// KEY RESPONSIBILITIES:
//   • Creates and injects AppState into the environment tree.
//   • Reacts to appState.showFABSheet to present DiaryEntryFormView.
//   • Reacts to appState.showChildPickerFirst to show a child picker sheet first.
//   • Routes global toasts triggered from any view via appState.globalToast.

import SwiftUI

struct KeyworkerContentView: View {

    // MARK: - Environment
    @Environment(DataManager.self) var dataManager

    // MARK: - App-wide State
    /// AppState is created here and injected downward via .environment().
    /// This is the single source of truth for FAB navigation.
    @State private var appState = AppState()

    // MARK: - Tab State
    @State private var selectedTab: TabItem = .dashboard
    @State private var showAddMenu: Bool = false

    // MARK: - FAB DiaryViewModel
    /// Owned here so the FAB sheet can pre-fill and immediately save an entry.
    /// This is separate from DailyDiaryView's own viewModel — that's intentional:
    /// FAB entries are quick-log actions, not full diary browsing sessions.
    @State private var fabDiaryViewModel = DiaryViewModel()

    // MARK: - Child Picker (shown before FAB sheet when no child is contextually selected)
    @State private var fabChildPickerPresented: Bool = false

    var body: some View {
        // @Observable types need Bindable to create $ bindings.
        // We create a local @Bindable view of appState here.
        @Bindable var bindableAppState = appState

        return ZStack {

            // ── TAB CONTENT ────────────────────────────────────────────────
            Group {
                switch selectedTab {
                case .dashboard:
                    KeyworkerDashboardView()
                case .diary:
                    DailyDiaryView()
                case .addNew:
                    // FAB is handled by the overlay — show diary as backing view
                    DailyDiaryView()
                case .incidents:
                    IncidentListView()
                case .settings:
                    SettingsView()
                }
            }

            // ── FAB MENU OVERLAY ───────────────────────────────────────────
            // Sits on top of content; ZStack renders this before the tab bar
            // so it appears above content but behind the tab bar visually.
            AddEntryMenu(isPresented: $showAddMenu)

            // ── TAB BAR ────────────────────────────────────────────────────
            VStack(spacing: 0) {
                Spacer()
                CustomTabBar(
                    selectedTab: $selectedTab,
                    showAddMenu: $showAddMenu
                )
                .padding(.horizontal, 12)
                .padding(.bottom, 0)
            }

            // ── IN-APP TOAST BANNER ────────────────────────────────────────
            InAppToastBanner()
        }
        // Inject AppState so CustomTabBar and AddEntryMenu can read/write it
        .environment(appState)
        .ignoresSafeArea(.keyboard, edges: .bottom)

        // MARK: FAB Sheet — Primary path (child already selected)
        // Uses Bindable projection per iOS 17 @Observable rules.
        .sheet(isPresented: $bindableAppState.showFABSheet, onDismiss: {
            appState.resetFABState()
        }) {
            fabEntrySheet
        }

        // MARK: Child Picker — Pre-step when no child context exists
        .sheet(isPresented: $bindableAppState.showChildPickerFirst) {
            FABChildPickerSheet(
                isPresented: $bindableAppState.showChildPickerFirst,
                onChildSelected: { child in
                    fabDiaryViewModel.selectedChildId = child.id
                    appState.showChildPickerFirst = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        appState.showFABSheet = true
                    }
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }

        // MARK: Global Toast
        .toast($bindableAppState.globalToast)

        // MARK: Notification Center Sheet
        .sheet(isPresented: $bindableAppState.showNotificationCenter) {
            NotificationCenterSheet()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }

        // MARK: Messages Sheet
        .sheet(isPresented: $bindableAppState.showMessagesView) {
            MessagesView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }

        // MARK: Attendance Sheet
        .sheet(isPresented: $bindableAppState.showAttendanceView) {
            AttendanceView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }

        // MARK: End-of-Day Checklist Sheet
        .sheet(isPresented: $bindableAppState.showEndOfDayChecklist) {
            EndOfDayChecklistView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }

        .onAppear {
            fabDiaryViewModel.dataManager = dataManager
            if fabDiaryViewModel.selectedChildId == nil,
               let first = dataManager.children.first {
                fabDiaryViewModel.selectedChildId = first.id
            }
        }
        .onChange(of: appState.fabSelectedEntryType) { _, newType in
            if let type = newType {
                fabDiaryViewModel.prepareNewEntry(type: type)
            }
        }
    }

    // MARK: - FAB Entry Sheet Content
    // NOTE: DiaryEntryFormView already contains its own NavigationStack with
    // Cancel button and title. We present it directly to avoid nested stacks.
    @ViewBuilder
    private var fabEntrySheet: some View {
        DiaryEntryFormView(viewModel: fabDiaryViewModel)
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .onDisappear {
                // Propagate any save toast to the global level
                if let toast = fabDiaryViewModel.toast {
                    appState.globalToast = toast
                    fabDiaryViewModel.toast = nil
                }
                appState.resetFABState()
            }
    }

}

// MARK: - FAB Child Picker Sheet
/// Presented as a prerequisite when the FAB is tapped but no child is
/// contextually selected. Shows a simple list of assigned children.
struct FABChildPickerSheet: View {
    @Binding var isPresented: Bool
    let onChildSelected: (ChildProfile) -> Void

    @Environment(DataManager.self) private var dataManager

    var body: some View {
        VStack(spacing: 0) {
            // Handle bar area
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.ncTextSecondary.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 12)

            Text("Quick Log — Select Child")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.ncText)
                .padding(.top, 16)
                .padding(.bottom, 8)

            Divider().padding(.horizontal, 20)

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(dataManager.children) { child in
                        Button {
                            HapticManager.selection()
                            onChildSelected(child)
                        } label: {
                            HStack(spacing: 14) {
                                ChildAvatar(child: child, size: 44)

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(child.displayName)
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Color.ncText)
                                    Text(child.age + " · " + child.roomAssignment)
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundStyle(Color.ncTextSec)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Color.ncTextSecondary.opacity(0.4))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(minHeight: 44)
                            .cardStyle()
                        }
                        .buttonStyle(PlainButtonStyle())
                        .accessibilityLabel("Select \(child.displayName)")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
        .background(Color.ncBackground)
    }
}

// MARK: - Preview
#Preview {
    KeyworkerContentView()
        .environment(DataManager.shared)
        .environment(ThemeManager())
        .environment(AttendanceManager.shared)
        .environment(MessageManager.shared)
        .environment(NotificationManager.shared)
        .environment(SleepTrackerManager.shared)
}
