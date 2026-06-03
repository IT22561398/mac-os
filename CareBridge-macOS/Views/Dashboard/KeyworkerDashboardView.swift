// NurseryConnect | KeyworkerDashboardView.swift
// Real dynamic dashboard — all data from DashboardViewModel computed properties.
// Zero hardcoded values. Live refresh on .onAppear and .entrySaved notification.
//
// DESIGN PRINCIPLES APPLIED:
//   • Gestalt Proximity & Grouping — logical section clusters
//   • Von Restorff: HIGH priority cards are coral, allergen banner uses red border
//   • Fitts's Law: all interactive elements ≥ 44pt
//   • Progressive Disclosure: recommendations only shown when gaps exist
//   • Miller's Law: max 3 stat chips
//   • Hick's Law: "Log Now →" pre-fills form type, minimising decision friction
//   • WCAG 2.1 AA: all interactives have .accessibilityLabel

import SwiftUI

struct KeyworkerDashboardView: View {

    // MARK: - Environment & ViewModel
    @Environment(DataManager.self) var dataManager
    @Environment(SleepTrackerManager.self) var sleepTracker
    @Environment(NotificationManager.self) var notificationManager
    @Environment(MessageManager.self) var messageManager
    @Environment(AttendanceManager.self) var attendanceManager
    @Environment(AppState.self) var appState
    @State private var viewModel = DashboardViewModel()

    // MARK: - Navigation State
    @State private var selectedChildForSheet: ChildProfile? = nil
    @State private var fabRecommendation: DashboardRecommendation? = nil
    @State private var fabDiaryViewModel = DiaryViewModel()

    // MARK: - Toolbar state
    @State private var searchVisible: Bool = false

    // MARK: - Time-based emoji
    private var greetingEmoji: String {
        let h = Calendar.current.component(.hour, from: Date())
        return h < 12 ? "☀️" : h < 17 ? "🌤️" : "🌙"
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.ncBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        heroHeader
                        statsChipsRow
                        quickActionsGrid
                        sleepTrackerSection
                        allergyAlertSection
                        todayMenuSection
                        photoConsentWarning
                        childCarousel

                        Spacer(minLength: 120) // Tab bar clearance
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            
            .toolbar { toolbarContent }

            // Sheet: child profile detail
            .sheet(item: $selectedChildForSheet) { child in
                ChildProfileView(child: child)
            }

            // Sheet: "Log Now" quick entry
            .sheet(item: $fabRecommendation) { rec in
                DiaryEntryFormView(
                    viewModel: {
                        fabDiaryViewModel.dataManager = dataManager
                        fabDiaryViewModel.selectedChildId = rec.child.id
                        fabDiaryViewModel.prepareNewEntry(type: rec.actionType)
                        return fabDiaryViewModel
                    }(),
                    preselectedChildId: rec.child.id
                )
                .environment(dataManager)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .onDisappear { viewModel.refresh() }
            }
        }
        .onAppear {
            viewModel.dataManager = dataManager
            fabDiaryViewModel.dataManager = dataManager
            viewModel.refresh()
        }
        // Live refresh when any entry is saved anywhere in the app
        .onReceive(NotificationCenter.default.publisher(for: .entrySaved)) { _ in
            viewModel.refresh()
        }
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            AvatarView(
                initials: viewModel.keyworker.initials,
                color: .ncPrimary,
                size: 36,
                showStatus: true,
                statusColor: .ncSuccess
            )
            .accessibilityLabel("Keyworker: \(viewModel.keyworker.fullName)")
        }

        ToolbarItem(placement: .principal) {
            Text("NurseryConnect")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ncPrimary)
        }

        ToolbarItem(placement: .automatic) {
            HStack(spacing: 6) {
                // Messages button
                Button {
                    appState.showMessagesView = true
                    HapticManager.lightTap()
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "message.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.ncPrimary)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Color.ncPrimary.opacity(0.1)))

                        if messageManager.unreadCount > 0 {
                            Text("\(messageManager.unreadCount)")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 16, height: 16)
                                .background(Circle().fill(Color(hex: "FB7185")))
                                .offset(x: 4, y: -4)
                        }
                    }
                }
                .accessibilityLabel("Messages. \(messageManager.unreadCount) unread.")

                // Notification bell
                Button {
                    appState.showNotificationCenter = true
                    HapticManager.lightTap()
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.ncPrimary)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Color.ncPrimary.opacity(0.1)))

                        if notificationManager.unreadCount > 0 {
                            Text("\(notificationManager.unreadCount)")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 16, height: 16)
                                .background(Circle().fill(Color(hex: "FB7185")))
                                .offset(x: 4, y: -4)
                        }
                    }
                }
                .accessibilityLabel("Notifications. \(notificationManager.unreadCount) unread.")

                // Search
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        searchVisible.toggle()
                    }
                    HapticManager.selection()
                } label: {
                    Image(systemName: searchVisible ? "xmark.circle.fill" : "magnifyingglass")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.ncPrimary)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.ncPrimary.opacity(0.1)))
                }
                .accessibilityLabel(searchVisible ? "Close search" : "Search children")
            }
        }
    }

    // MARK: - Hero Header
    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text("\(viewModel.greeting), \(viewModel.keyworker.firstName)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ncText)
                Text(greetingEmoji)
                    .font(.system(size: 26))
            }
            .accessibilityLabel("\(viewModel.greeting), \(viewModel.keyworker.firstName)")

            HStack(spacing: 5) {
                Image(systemName: "calendar")
                    .font(.system(size: 12, weight: .medium))
                Text(viewModel.todayDateString)
                    .font(.system(size: 13, weight: .regular))
            }
            .foregroundStyle(Color.ncTextSec)
            .accessibilityLabel("Today is \(viewModel.todayDateString)")

            if searchVisible {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.ncTextSec)
                    TextField("Search children...", text: $viewModel.searchText)
                        .font(.system(size: 15))
                        .autocorrectionDisabled()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.ncCard)
                        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
                )
                .transition(.opacity.combined(with: .scale(scale: 0.97, anchor: .top)))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Quick Stats Chips
    private var statsChipsRow: some View {
        HStack(spacing: 12) {
            statsChip(
                icon:  "person.2.fill",
                value: "\(viewModel.childrenCheckedInToday)",
                label: "Checked In",
                color: .ncPrimary
            )
            statsChip(
                icon:  "doc.text.fill",
                value: "\(viewModel.entriesToday)",
                label: "Entries Today",
                color: Color(hex: "A29BFE")
            )
            statsChip(
                icon:  "exclamationmark.triangle.fill",
                value: "\(viewModel.activeAlerts)",
                label: "Active Alerts",
                color: viewModel.activeAlerts > 0 ? Color(hex: "FB7185") : Color.ncTextSecondary
            )
        }
    }

    private func statsChip(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 10) {
            ZStack {
                Circle().fill(color.opacity(0.14)).frame(width: 42, height: 42)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(color)
            }
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ncText)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.ncTextSec)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.ncCard)
                .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 4)
        )
        .accessibilityLabel("\(label): \(value)")
    }

    // MARK: - Allergy Alert Section
    // Shown only when children with allergies had a meal today (Von Restorff)
    @ViewBuilder
    private var allergyAlertSection: some View {
        if !viewModel.allergyAlertItems.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.ncSecondary)
                    Text("Allergen Alerts — Meals Today")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.ncText)
                    Spacer()
                    Text("\(viewModel.allergyAlertItems.count)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 22, height: 22)
                        .background(Circle().fill(Color.ncSecondary))
                }

                ForEach(viewModel.allergyAlertItems) { alert in
                    allergyCard(alert: alert)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.ncSecondary.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.ncSecondary.opacity(0.25), lineWidth: 1)
                    )
            )
            .accessibilityLabel("Allergen alerts section — \(viewModel.allergyAlertItems.count) children with allergies had meals today")
        }
    }

    private func allergyCard(alert: AllergyAlertItem) -> some View {
        HStack(spacing: 12) {
            ChildAvatar(child: alert.child, size: 40)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(alert.child.displayName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.ncText)
                    Text("• meal at \(alert.mealTime.time12String)")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.ncTextSec)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
                        ForEach(alert.allergies) { allergen in
                            AllergenBadge(allergen: allergen)
                        }
                    }
                }
            }

            Spacer()
        }
        .accessibilityLabel("\(alert.child.displayName) had a meal at \(alert.mealTime.time12String). Allergens: \(alert.allergies.map { $0.name }.joined(separator: ", "))")
    }

    // MARK: - Recommendations Section
    @ViewBuilder
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Section header
            HStack {
                Image(systemName: viewModel.allRecordsUpToDate
                      ? "checkmark.seal.fill"
                      : "bell.badge.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(viewModel.allRecordsUpToDate ? Color.ncSuccess : Color.ncAccent)

                Text(viewModel.allRecordsUpToDate ? "All Records Up to Date" : "Today's Action Items")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ncText)

                Spacer()

                if !viewModel.allRecordsUpToDate {
                    Text("\(viewModel.todayRecommendations.count)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 22, height: 22)
                        .background(Circle().fill(Color.ncSecondary))
                }
            }

            // Empty state — all complete
            if viewModel.allRecordsUpToDate {
                allUpToDateCard
            } else {
                // Priority-ordered recommendation cards
                ForEach(viewModel.todayRecommendations) { rec in
                    recommendationCard(rec)
                }
            }
        }
    }

    // MARK: - All Up To Date Card
    private var allUpToDateCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 52))
                .foregroundStyle(Color.ncSuccess)
                .shadow(color: Color.ncSuccess.opacity(0.3), radius: 12, y: 4)

            VStack(spacing: 6) {
                Text("🎉 All records complete!")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ncText)
                Text("All children's diary records are up to date for today.")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.ncTextSec)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.ncSuccess.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.ncSuccess.opacity(0.2), lineWidth: 1)
                )
        )
        .accessibilityLabel("All children's records are up to date for today")
    }

    // MARK: - Recommendation Card
    private func recommendationCard(_ rec: DashboardRecommendation) -> some View {
        let tint = rec.priority.tintColor

        return HStack(spacing: 14) {
            // Child avatar with priority indicator dot
            ZStack(alignment: .topTrailing) {
                ChildAvatar(child: rec.child, size: 46)

                // Priority dot (Von Restorff — HIGH is coral, stands out)
                Circle()
                    .fill(tint)
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                    .offset(x: 2, y: -2)
            }

            // Message text
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: rec.priority.icon)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(tint)
                    Text(rec.priority.label)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(tint)
                        .textCase(.uppercase)
                        .tracking(0.4)
                }
                Text(rec.message)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.ncText)
                    .lineLimit(2)
            }

            Spacer()

            // Log Now button (Fitts's Law: min 44pt, clear CTA)
            Button {
                HapticManager.mediumTap()
                fabRecommendation = rec
            } label: {
                VStack(spacing: 2) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(tint)
                    Text("Log")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(tint)
                }
                .frame(width: 44, height: 44)
                .background(Circle().fill(tint.opacity(0.12)))
            }
            .accessibilityLabel("Log \(rec.actionType.rawValue) for \(rec.child.firstName)")
        }
        .padding(14)
        .frame(minHeight: 44)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.ncCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(tint.opacity(0.22), lineWidth: 1)
                )
        )
        .shadow(color: tint.opacity(0.08), radius: 8, x: 0, y: 3)
        // LEFT tint bar (Gestalt — priority grouping at a glance)
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(tint)
                .frame(width: 4)
                .padding(.vertical, 10)
                .padding(.leading, -1)
                .clipped()
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityLabel("\(rec.priority.label) priority: \(rec.message). Tap to log now.")
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Quick Actions Grid
    private var quickActionsGrid: some View {
        HStack(spacing: 12) {
            quickActionButton(
                icon: "person.badge.clock",
                label: "Attendance",
                color: Color(hex: "55EFC4"),
                badge: "\(attendanceManager.presentCount)/\(dataManager.children.count)"
            ) {
                appState.showAttendanceView = true
            }

            quickActionButton(
                icon: "checklist",
                label: "End of Day",
                color: Color(hex: "A29BFE"),
                badge: nil
            ) {
                appState.showEndOfDayChecklist = true
            }

            quickActionButton(
                icon: "message.fill",
                label: "Messages",
                color: Color(hex: "74B9FF"),
                badge: messageManager.unreadCount > 0 ? "\(messageManager.unreadCount)" : nil
            ) {
                appState.showMessagesView = true
            }
        }
    }

    private func quickActionButton(icon: String, label: String, color: Color, badge: String?, action: @escaping () -> Void) -> some View {
        Button {
            HapticManager.lightTap()
            action()
        } label: {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.14))
                            .frame(width: 42, height: 42)
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(color)
                    }

                    if let badge = badge {
                        Text(badge)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(minWidth: 16, minHeight: 16)
                            .background(Capsule().fill(Color(hex: "FB7185")))
                            .offset(x: 6, y: -4)
                    }
                }

                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.ncTextSec)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.ncCard)
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
            )
        }
        .buttonStyle(ScalePressButtonStyle())
        .accessibilityLabel("\(label)\(badge.map { ". \($0)" } ?? "")")
    }

    // MARK: - Sleep Tracker Section
    private var sleepTrackerSection: some View {
        SleepTrackerWidget()
    }

    // MARK: - Today Menu Section
    private var todayMenuSection: some View {
        TodayMenuCard()
    }

    // MARK: - Photography Consent Warning
    @ViewBuilder
    private var photoConsentWarning: some View {
        let noConsentChildren = dataManager.children.filter { !$0.photographyConsent }
        if !noConsentChildren.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                    Text("PHOTOGRAPHY CONSENT WARNING")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .tracking(0.4)
                    Spacer()
                    Text("\(noConsentChildren.count)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color(hex: "E74C3C"))
                        .frame(width: 22, height: 22)
                        .background(Circle().fill(.white))
                }

                ForEach(noConsentChildren) { child in
                    HStack(spacing: 10) {
                        ChildAvatar(child: child, size: 32)
                        Text("\(child.displayName) — DO NOT photograph")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: "E74C3C"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .accessibilityLabel("Photography consent warning: \(noConsentChildren.count) children do not have photography consent")
        }
    }

    // MARK: - Child Carousel
    private var childCarousel: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("My Children")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ncText)
                Spacer()
                Text("\(viewModel.assignedChildren.count) assigned")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.ncTextSec)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.ncPrimary.opacity(0.1)))
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(Array(viewModel.assignedChildren.enumerated()), id: \.element.id) { index, child in
                        childCard(child: child, index: index)
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0.75)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.97)
                            }
                    }
                }
                .padding(.horizontal, 2)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollClipDisabled()
        }
    }

    // MARK: - Child Card
    private func childCard(child: ChildProfile, index: Int) -> some View {
        let summary = viewModel.todayEntrySummary(for: child.id)
        let mood    = viewModel.latestMood(for: child.id)
        let hueAngle = Double(index) * 40.0
        let baseColor = Color(
            hue: (0.48 + hueAngle / 360.0).truncatingRemainder(dividingBy: 1.0),
            saturation: 0.60, brightness: 0.82
        )
        let deepColor = Color(
            hue: (0.48 + hueAngle / 360.0).truncatingRemainder(dividingBy: 1.0),
            saturation: 0.75, brightness: 0.65
        )

        return Button {
            HapticManager.lightTap()
            selectedChildForSheet = child
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Gradient top band
                ZStack(alignment: .topTrailing) {
                    LinearGradient(
                        colors: [baseColor, deepColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 88)

                    // Allergen dot (Von Restorff)
                    if child.hasAllergies {
                        Circle().fill(Color.ncSecondary).frame(width: 12, height: 12)
                            .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                            .padding(10)
                    }

                    // Overlapping avatar
                    VStack {
                        Spacer()
                        HStack {
                            AvatarView(
                                initials: child.initials,
                                color: deepColor,
                                size: 52,
                                showStatus: true,
                                statusColor: .white.opacity(0.9)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
                            .padding(.leading, 14)
                            .padding(.bottom, -26)
                            Spacer()
                        }
                    }
                }
                .clipShape(
                    .rect(
                        topLeadingRadius: 20, bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0, topTrailingRadius: 20
                    )
                )

                // Card body
                VStack(alignment: .leading, spacing: 8) {
                    // Name + mood
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(child.displayName)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.ncText)
                        if let mood = mood {
                            Text(mood.emoji)
                                .font(.system(size: 13))
                        }
                    }
                    .padding(.top, 32) // Avatar overlap clearance

                    Text(child.age + " · " + child.roomAssignment)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.ncTextSec)

                    // Live entry counts
                    Text(viewModel.lastEntryTime(for: child.id))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.ncPrimary)

                    Divider().padding(.vertical, 2)

                    // Mini stats
                    HStack(spacing: 0) {
                        miniStat(icon: "figure.play", count: summary.activities,
                                 label: "Activities", color: .ncPrimary)
                        Divider().frame(height: 28)
                        miniStat(icon: "fork.knife", count: summary.meals,
                                 label: "Meals", color: Color(hex: "FF9F43"))
                        Divider().frame(height: 28)
                        miniStat(icon: "moon.zzz.fill", count: summary.sleeps,
                                 label: "Sleep", color: Color(hex: "A29BFE"))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
                .background(Color.ncCard)
                .clipShape(
                    .rect(
                        topLeadingRadius: 0, bottomLeadingRadius: 20,
                        bottomTrailingRadius: 20, topTrailingRadius: 0
                    )
                )
            }
            .frame(width: 200)
            .background(Color.ncCard)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.10), radius: 14, x: 0, y: 5)
        }
        .buttonStyle(ScalePressButtonStyle())
        .accessibilityLabel(
            "\(child.displayName), \(child.age). Activities: \(summary.activities), Meals: \(summary.meals), Sleep sessions: \(summary.sleeps)"
        )
    }

    private func miniStat(icon: String, count: Int, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(color)
            Text("\(count)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ncText)
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(Color.ncTextSec)
        }
        .frame(maxWidth: .infinity)
        .accessibilityLabel("\(label): \(count)")
    }
}

// MARK: - Preview
#Preview {
    KeyworkerDashboardView()
        .environment(DataManager.shared)
}
