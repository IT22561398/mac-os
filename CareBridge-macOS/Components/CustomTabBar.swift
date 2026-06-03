// NurseryConnect | CustomTabBar.swift
// Full redesign: premium tab bar + FAB with staggered spring animations,
// ultraThinMaterial backdrop, and AppState-driven navigation fix.
//
// BUG FIX 1 — FAB navigation: tapping an item sets appState.fabSelectedEntryType
//              and appState.showFABSheet = true. ContentView owns the sheet.
// BUG FIX 2 — Black gap: overlay uses .ignoresSafeArea() on the full ZStack,
//              and backdrop is .ultraThinMaterial instead of Color.black.

import SwiftUI

// MARK: - Tab Item Enum
enum TabItem: Int, CaseIterable, Identifiable {
    case dashboard = 0
    case diary     = 1
    case addNew    = 2
    case incidents = 3
    case settings  = 4

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .dashboard: return "Home"
        case .diary:     return "Diary"
        case .addNew:    return ""
        case .incidents: return "Incidents"
        case .settings:  return "Settings"
        }
    }

    /// SF Symbol used when this tab is the active selection (filled variant).
    var activeIcon: String {
        switch self {
        case .dashboard: return "house.fill"
        case .diary:     return "book.fill"
        case .addNew:    return "plus"
        case .incidents: return "exclamationmark.shield.fill"
        case .settings:  return "gearshape.fill"
        }
    }

    /// SF Symbol used in the inactive state (outline/lighter variant).
    var inactiveIcon: String {
        switch self {
        case .dashboard: return "house"
        case .diary:     return "book"
        case .addNew:    return "plus"
        case .incidents: return "exclamationmark.shield"
        case .settings:  return "gearshape"
        }
    }
}

// MARK: - FAB Action Model (shared within this file)
struct FABActionItem: Identifiable {
    let id       = UUID()
    let type     : DiaryEntryType
    let label    : String
    let icon     : String
    let gradient : [Color]
}

/// Single source of truth for all FAB action items — used by both
/// CustomTabBar and AddEntryMenu to avoid duplication.
extension FABActionItem {
    static let all: [FABActionItem] = [
        FABActionItem(
            type:     .activity,
            label:    "Log Activity",
            icon:     "figure.play",
            gradient: [Color(hex: "6366F1"), Color(hex: "8B5CF6")]
        ),
        FABActionItem(
            type:     .meal,
            label:    "Record Meal",
            icon:     "fork.knife",
            gradient: [Color(hex: "FF9F43"), Color(hex: "EE5A24")]
        ),
        FABActionItem(
            type:     .sleep,
            label:    "Log Sleep",
            icon:     "moon.zzz.fill",
            gradient: [Color(hex: "A29BFE"), Color(hex: "6C5CE7")]
        ),
        FABActionItem(
            type:     .nappy,
            label:    "Nappy Change",
            icon:     "arrow.triangle.2.circlepath",
            gradient: [Color(hex: "FFEAA7"), Color(hex: "FDCB6E")]
        ),
        FABActionItem(
            type:     .wellbeing,
            label:    "Wellbeing Check",
            icon:     "heart.fill",
            gradient: [Color(hex: "FB7185"), Color(hex: "C0392B")]
        ),
        FABActionItem(
            type:     .note,
            label:    "Add Note",
            icon:     "note.text",
            gradient: [Color(hex: "B2BEC3"), Color(hex: "636E72")]
        ),
    ]
}

// MARK: - Scale Press Button Style
/// Provides a subtle scale-down press effect for tactile feedback.
struct ScalePressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(
                .spring(response: 0.25, dampingFraction: 0.7),
                value: configuration.isPressed
            )
    }
}

// MARK: - CustomTabBar
struct CustomTabBar: View {

    @Binding var selectedTab: TabItem
    @Binding var showAddMenu: Bool

    @Environment(AppState.self)    private var appState
    @Environment(DataManager.self) private var dataManager
    @Environment(\.colorScheme)    private var colorScheme

    /// Drives the idle scale-pulse on the FAB when the menu is collapsed.
    @State private var fabPulse: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases) { tab in
                if tab == .addNew {
                    fabButton
                } else {
                    tabButton(tab)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(tabBarBackground)
        .overlay(alignment: .top) {
            // 0.5 pt hairline top separator (Nielsen #4: consistency with iOS)
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 0.5)
        }
        .onAppear {
            // Start infinite idle pulse loop (1.0 → 1.05 → 1.0, 2s)
            withAnimation(
                .easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
            ) {
                fabPulse = true
            }
        }
    }

    // MARK: - Regular Tab Button
    @ViewBuilder
    private func tabButton(_ tab: TabItem) -> some View {
        let isActive = selectedTab == tab

        Button {
            HapticManager.selection()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: isActive ? tab.activeIcon : tab.inactiveIcon)
                    .font(.system(size: 20, weight: isActive ? .bold : .regular))
                    .scaleEffect(isActive ? 1.1 : 1.0)
                    .foregroundStyle(
                        isActive
                            ? Color.ncPrimary
                            : Color.ncTextSecondary.opacity(0.65)
                    )
                    .animation(
                        .spring(response: 0.3, dampingFraction: 0.65),
                        value: isActive
                    )

                // Label only for active tab — reduces visual noise (Hick's Law)
                if isActive {
                    Text(tab.title)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.ncPrimary)
                        .transition(
                            .opacity.combined(with: .scale(scale: 0.8, anchor: .top))
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44) // Fitts's Law — 44 pt minimum touch target
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }

    // MARK: - Floating Action Button
    private var fabButton: some View {
        Button {
            HapticManager.mediumTap()
            withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                showAddMenu.toggle()
            }
        } label: {
            ZStack {
                // Outer glow halo — indicates open state
                Circle()
                    .fill(Color.ncPrimary.opacity(showAddMenu ? 0.22 : 0))
                    .frame(width: 76, height: 76)

                // Main 64 pt teal-to-emerald circle (Von Restorff — visually distinct)
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                    .shadow(
                        color: Color.ncPrimary.opacity(showAddMenu ? 0.55 : 0.35),
                        radius: showAddMenu ? 18 : 10,
                        y: 4
                    )
                    // Idle pulse only when menu is closed
                    .scaleEffect(showAddMenu ? 1.0 : (fabPulse ? 1.05 : 1.0))

                // Plus → X rotation
                Image(systemName: "plus")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
                    .rotationEffect(.degrees(showAddMenu ? 45 : 0))
            }
            .animation(
                .spring(response: 0.45, dampingFraction: 0.72),
                value: showAddMenu
            )
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
        .offset(y: -22) // Float 22 pt above the bar surface
        .accessibilityLabel(
            showAddMenu ? "Close quick actions" : "Open quick actions"
        )
    }

    // MARK: - Tab Bar Background
    private var tabBarBackground: some View {
        ZStack {
            if colorScheme == .dark {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(hex: "12141C").opacity(0.97))
                    .shadow(color: .black.opacity(0.45), radius: 28, y: -6)
            } else {
                RoundedRectangle(cornerRadius: 28)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.08), radius: 24, y: -5)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(
                    colorScheme == .dark
                        ? Color.white.opacity(0.06)
                        : Color.white.opacity(0.55),
                    lineWidth: 0.5
                )
        )
    }
}

// MARK: - AddEntryMenu Overlay
/// Full-screen overlay that sits in ContentView's root ZStack.
///
/// BUG FIX 2 (black gap):  The overlay ZStack must extend into safe areas.
/// Previously the ZStack was clipped to the layout area, leaving the status
/// bar region unstyled (appears black). Solution:
///   • Apply `.ignoresSafeArea()` to the backdrop ZStack.
///   • Use `.ultraThinMaterial` (system blur) instead of Color.black.
struct AddEntryMenu: View {
    @Binding var isPresented: Bool

    @Environment(AppState.self)    private var appState
    @Environment(DataManager.self) private var dataManager

    var body: some View {
        ZStack(alignment: .bottom) {

            // ── BACKDROP ───────────────────────────────────────────────────
            // Must fill the ENTIRE screen including safe areas.
            // Using two layered fills for the premium glass + teal tint effect.
            if isPresented {
                ZStack {
                    Rectangle().fill(.ultraThinMaterial)
                    Rectangle().fill(Color.ncPrimary.opacity(0.04))
                }
                .ignoresSafeArea() // ← THE FIX: extends above the status bar
                .onTapGesture { dismiss() }
                .transition(.opacity)
            }

            // ── ACTION ROWS ────────────────────────────────────────────────
            // Positioned in the bottom ~55% of the screen, above the tab bar.
            if isPresented {
                VStack(spacing: 10) {
                    ForEach(Array(FABActionItem.all.enumerated()), id: \.element.id) { index, action in
                        actionRow(action: action, index: index)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 112) // clears the 64pt FAB + 48pt tab bar
                .transition(.opacity)
            }
        }
        // Animate both the backdrop and rows together
        .animation(.spring(response: 0.45, dampingFraction: 0.72), value: isPresented)
        // Pass touches through when collapsed so tabs remain interactive
        .allowsHitTesting(isPresented)
    }

    // MARK: - Action Row
    private func actionRow(action: FABActionItem, index: Int) -> some View {
        // Staggered spring timing per design spec
        let appearDelay    = Double(index) * 0.05
        // Reverse stagger on dismiss — last item collapses first
        let dismissDelay   = Double(FABActionItem.all.count - 1 - index) * 0.04

        return Button {
            handleSelection(action.type)
        } label: {
            HStack(spacing: 14) {
                // Gradient icon circle (24 pt symbol, 48 pt touch target)
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: action.gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .shadow(
                            color: action.gradient[0].opacity(0.45),
                            radius: 8,
                            y: 3
                        )

                    Image(systemName: action.icon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                }

                Text(action.label)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.ncText)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.ncTextSecondary.opacity(0.45))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(minHeight: 44) // Fitts's Law
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.ncCard)
                    .shadow(color: .black.opacity(0.1), radius: 12, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(action.gradient[0].opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(ScalePressButtonStyle())
        .accessibilityLabel(action.label)
        // Each item gets its own delayed spring — creating a cascading waterfall
        .animation(
            .spring(response: 0.45, dampingFraction: 0.72)
                .delay(isPresented ? appearDelay : dismissDelay),
            value: isPresented
        )
    }

    // MARK: - Selection Handler
    /// BUG FIX 1: Instead of attempting to navigate inside the tab bar
    /// (which cannot reach sibling views), we write to AppState so ContentView
    /// can react and present the correct sheet. Full flow:
    ///
    ///   actionRow tap
    ///     → dismiss FAB menu (spring, 0.35s)
    ///     → DispatchQueue.main.asyncAfter(0.25s)
    ///       → appState.triggerFAB(entryType:, hasSelectedChild:)
    ///         → appState.showFABSheet = true
    ///           → ContentView .sheet fires
    ///             → DiaryEntryFormView pre-filled with entryType
    private func handleSelection(_ type: DiaryEntryType) {
        HapticManager.mediumTap()
        let hasChildren = !dataManager.children.isEmpty

        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
            isPresented = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            appState.triggerFAB(entryType: type, hasSelectedChild: hasChildren)
        }
    }

    private func dismiss() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
            isPresented = false
        }
    }
}

// MARK: - Preview
#Preview("Tab Bar") {
    ZStack {
        Color.ncBackground.ignoresSafeArea()
        VStack {
            Spacer()
            CustomTabBar(
                selectedTab: .constant(.dashboard),
                showAddMenu: .constant(false)
            )
            .padding(.horizontal, 12)
        }
    }
    .environment(AppState())
    .environment(DataManager.shared)
}

#Preview("FAB Menu Open") {
    ZStack {
        Color.ncBackground.ignoresSafeArea()
        AddEntryMenu(isPresented: .constant(true))
        VStack {
            Spacer()
            CustomTabBar(
                selectedTab: .constant(.dashboard),
                showAddMenu: .constant(true)
            )
            .padding(.horizontal, 12)
        }
    }
    .environment(AppState())
    .environment(DataManager.shared)
}
