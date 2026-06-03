// NurseryConnect | IncidentListView.swift
// RIDDOR-compliant incident list with notification timers, RIDDOR flags,
// severity sorting, and swipe actions. EYFS 2024 same-day enforcement.

import SwiftUI
import Combine

// MARK: - IncidentListView
struct IncidentListView: View {
    @Environment(DataManager.self) private var dataManager
    @State private var viewModel = IncidentViewModel()
    @State private var searchText = ""
    @State private var filterCategory: IncidentCategory?
    @State private var showFilters = false
    @State private var now = Date()

    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ncBackground.ignoresSafeArea()

                if sortedIncidents.isEmpty {
                    EmptyStateView(
                        icon: "exclamationmark.shield",
                        title: "No Incidents",
                        subtitle: "No incident reports have been filed. When incidents occur, they will appear here."
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // MARK: Header
                            headerSection
                            
                            // MARK: Stats Summary
                            statsSummary

                            // MARK: Filter Chips
                            if showFilters {
                                filterChipsRow
                            }

                            // MARK: Incident Cards
                            ForEach(groupedIncidents, id: \.key) { dateStr, incidents in
                                Section {
                                    ForEach(incidents) { incident in
                                        IncidentRowLink(
                                            incident: incident,
                                            childName: viewModel.childName(for: incident.childId) ?? "Unknown",
                                            now: now,
                                            onDelete: { viewModel.deleteIncident(incident) }
                                        )
                                    }
                                } header: {
                                    HStack {
                                        Text(dateStr)
                                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                                            .foregroundStyle(Color.ncTextSec)
                                        Spacer()
                                        Text("\(incidents.count) incident\(incidents.count == 1 ? "" : "s")")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundStyle(Color.ncTextSec)
                                    }
                                    .padding(.horizontal, 4)
                                    .padding(.top, 8)
                                }
                            }

                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("Incidents")
            
            .searchable(text: $searchText, prompt: "Search incidents")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    HStack(spacing: 8) {
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                showFilters.toggle()
                            }
                        } label: {
                            Image(systemName: showFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                                .font(.system(size: 18))
                                .foregroundStyle(showFilters ? Color.ncPrimary : Color.ncTextSec)
                                .frame(width: 44, height: 44)
                        }
                        .accessibilityLabel(showFilters ? "Hide filters" : "Show filters")

                        Button {
                            viewModel.prepareNewIncident()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(Color.ncPrimary)
                                .frame(width: 44, height: 44)
                        }
                        .accessibilityLabel("New incident report")
                    }
                }
            }
            .navigationDestination(for: Incident.self) { incident in
                IncidentDetailView(incident: incident)
            }
            .sheet(isPresented: $viewModel.showIncidentForm) {
                IncidentFormView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.dataManager = dataManager
            }
            .onReceive(timer) { _ in
                now = Date()
            }
            .toast($viewModel.toast)
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Incident Management")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ncText)
            
            Text("Track, manage, and report incidents in compliance with EYFS and RIDDOR guidelines.")
                .font(.system(size: 13))
                .foregroundStyle(Color.ncTextSec)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 8)
    }

    // MARK: - Sorted & Grouped Incidents
    private var sortedIncidents: [Incident] {
        var results = dataManager.incidents

        // Search filter
        if !searchText.isEmpty {
            results = results.filter { incident in
                incident.description.localizedCaseInsensitiveContains(searchText) ||
                incident.location.localizedCaseInsensitiveContains(searchText) ||
                incident.category.rawValue.localizedCaseInsensitiveContains(searchText) ||
                (viewModel.childName(for: incident.childId)?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }

        // Category filter
        if let cat = filterCategory {
            results = results.filter { $0.category == cat }
        }

        // Sort: RIDDOR reportable first within same date, then by timestamp descending
        return results.sorted { a, b in
            if Calendar.current.isDate(a.dateTime, inSameDayAs: b.dateTime) {
                let aRiddor = isRIDDORReportable(a)
                let bRiddor = isRIDDORReportable(b)
                if aRiddor != bRiddor { return aRiddor }
            }
            return a.dateTime > b.dateTime
        }
    }

    private var groupedIncidents: [(key: String, value: [Incident])] {
        let grouped = Dictionary(grouping: sortedIncidents) { incident in
            if incident.dateTime.isToday { return "Today" }
            if incident.dateTime.isYesterday { return "Yesterday" }
            return incident.dateTime.shortDateString
        }

        let order = ["Today", "Yesterday"]
        return grouped.sorted { a, b in
            let aIdx = order.firstIndex(of: a.key)
            let bIdx = order.firstIndex(of: b.key)
            if let ai = aIdx, let bi = bIdx { return ai < bi }
            if aIdx != nil { return true }
            if bIdx != nil { return false }
            return a.key > b.key
        }
    }

    // MARK: - Stats Summary
    private var statsSummary: some View {
        HStack(spacing: 12) {
            statChip(
                value: "\(dataManager.incidents.count)",
                label: "Total",
                color: Color.ncPrimary
            )
            statChip(
                value: "\(viewModel.pendingReview.count)",
                label: "Pending",
                color: Color.ncWarning
            )
            statChip(
                value: "\(viewModel.thisWeekIncidents.count)",
                label: "This Week",
                color: Color(hex: "A29BFE")
            )
        }
        .padding(.bottom, 4)
    }

    private func statChip(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(Color.ncTextSec)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.ncCard)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    // MARK: - Filter Chips
    private var filterChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(nil, label: "All")
                ForEach(IncidentCategory.allCases) { cat in
                    filterChip(cat, label: cat.rawValue)
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(.bottom, 4)
    }

    private func filterChip(_ category: IncidentCategory?, label: String) -> some View {
        let isSelected = filterCategory == category
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                filterCategory = category
            }
            HapticManager.selection()
        } label: {
            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(isSelected ? .white : Color.ncTextSec)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected
                              ? (category?.color ?? Color.ncPrimary)
                              : Color.white.opacity(0.06))
                )
        }
        .accessibilityLabel("Filter: \(label)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - RIDDOR Helpers
    private func isRIDDORReportable(_ incident: Incident) -> Bool {
        [.firstAidRequired, .safeguardingConcern, .allergicReaction, .medicalIncident]
            .contains(incident.category)
    }
}

// MARK: - Incident List Row
struct IncidentListRow: View {
    let incident: Incident
    let childName: String
    let now: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Top row: category + badges
            HStack(spacing: 8) {
                // Category icon
                ZStack {
                    Circle()
                        .fill(incident.category.color.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: incident.category.icon)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(incident.category.color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(childName)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.ncText)
                        .lineLimit(1)

                    Text(incident.category.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(incident.category.color)
                }

                Spacer()

                // Time chip
                Text(incident.dateTime.time12String)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.ncTextSec)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(Color.white.opacity(0.06))
                    )
            }

            // Description preview
            Text(incident.description)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(Color.ncTextSec)
                .lineLimit(2)

            // Bottom row: badges
            HStack(spacing: 8) {
                // Status badge
                IncidentStatusBadge(status: incident.status)

                // RIDDOR badge
                if isRIDDORReportable {
                    StatusBadge(
                        text: "RIDDOR",
                        color: Color(hex: "E74C3C"),
                        icon: "shield.fill",
                        size: .small
                    )
                }

                Spacer()

                // Notification timer badge
                notificationTimerBadge
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.ncCard)
                .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isRIDDORReportable
                        ? incident.category.color.opacity(0.2)
                        : Color.white.opacity(0.06),
                        lineWidth: 1)
        )
        .accessibilityLabel("\(childName), \(incident.category.rawValue), \(incident.status.rawValue)")
    }

    // MARK: Timer Badge
    @ViewBuilder
    private var notificationTimerBadge: some View {
        if incident.parentNotifiedAt == nil {
            let hoursSince = now.timeIntervalSince(incident.dateTime) / 3600
            let deadline = incident.dateTime.addingTimeInterval(4 * 3600)
            let remaining = deadline.timeIntervalSince(now)

            if remaining <= 0 {
                StatusBadge(
                    text: "OVERDUE",
                    color: Color(hex: "E74C3C"),
                    icon: "exclamationmark.triangle.fill",
                    size: .small
                )
            } else if hoursSince < 4 {
                let hrs = Int(remaining) / 3600
                let mins = (Int(remaining) % 3600) / 60

                StatusBadge(
                    text: "\(hrs)h \(mins)m left",
                    color: remaining < 7200 ? Color(hex: "E74C3C") : Color(hex: "F89F1B"),
                    icon: "clock.fill",
                    size: .small
                )
            }
        }
    }

    private var isRIDDORReportable: Bool {
        [.firstAidRequired, .safeguardingConcern, .allergicReaction, .medicalIncident]
            .contains(incident.category)
    }
}

// MARK: - IncidentRowLink Helper View
private struct IncidentRowLink: View {
    let incident: Incident
    let childName: String
    let now: Date
    let onDelete: () -> Void

    var body: some View {
        NavigationLink(value: incident) {
            IncidentListRow(incident: incident, childName: childName, now: now)
        }
        .buttonStyle(PlainButtonStyle())
        .rowActions(onDelete: onDelete)
    }
}

// MARK: - RowActions ViewModifier and Extension
private struct RowActions: ViewModifier {
    let onDelete: () -> Void

    func body(content: Content) -> some View {
        content
            .contextMenu {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
    }
}

private extension View {
    func rowActions(onDelete: @escaping () -> Void) -> some View {
        modifier(RowActions(onDelete: onDelete))
    }
}

// MARK: - Preview
#Preview {
    IncidentListView()
        .environment(DataManager.shared)
}
