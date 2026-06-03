// OverviewDashboardView.swift
// NurseryConnect — Setting Manager (macOS)
// Main dashboard with metric cards, attention list, and EYFS heatmap

import SwiftUI
import Charts

struct OverviewDashboardView: View {
    @Environment(SettingManagerDashboardViewModel.self) private var viewModel
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Top header
                dashboardHeader
                
                // Metric cards
                metricsRow
                
                // Children needing attention
                attentionSection
                
                // EYFS Heatmap
                eyfsHeatmapSection
            }
            .padding(24)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle(ManagerText.Dashboard.title)
    }
    
    // MARK: - Header
    private var dashboardHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(ManagerText.Dashboard.greeting(
                    name: viewModel.managerProfile.fullName.components(separatedBy: " ").first ?? ManagerText.unknownLabel,
                    timeOfDay: timeOfDayGreeting
                ))
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.primary)
                
                Text(ManagerText.Dashboard.nurseryDate(ManagerConstants.nurseryName, date: Date().shortDateString))
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if viewModel.isAnalyzing {
                HStack(spacing: 8) {
                    ProgressView()
                        .controlSize(.small)
                    Text(ManagerText.Dashboard.aiAnalysisRunning)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ncPrimary.opacity(0.1))
                )
            }
        }
    }
    
    // MARK: - Metrics Row
    private var metricsRow: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 16) {
            MetricCardView(
                title: ManagerText.Metrics.childrenTodayTitle,
                value: "\(viewModel.totalChildrenToday)/\(viewModel.totalExpected)",
                icon: "person.3.fill",
                color: .ncPrimary,
                subtitle: ManagerText.Metrics.childrenTodaySubtitle
            )
            
            MetricCardView(
                title: ManagerText.Metrics.pendingIncidentsTitle,
                value: "\(viewModel.pendingIncidentCount)",
                icon: "exclamationmark.triangle.fill",
                color: viewModel.pendingIncidentCount > 0 ? .ncSecondary : .ncSuccess,
                subtitle: viewModel.pendingIncidentCount > 0
                    ? ManagerText.Metrics.pendingIncidentsNeedsAttention
                    : ManagerText.Metrics.pendingIncidentsAllClear
            )
            
            MetricCardView(
                title: ManagerText.Metrics.wellbeingFlagsTitle,
                value: "\(viewModel.flaggedWellbeingCount)",
                icon: "brain.head.profile",
                color: viewModel.flaggedWellbeingCount > 0 ? .ncWarning : .ncSuccess,
                subtitle: viewModel.flaggedWellbeingCount > 0
                    ? ManagerText.Metrics.wellbeingFlagsSubtitle
                    : ManagerText.Metrics.wellbeingFlagsAllWell
            )
            
            MetricCardView(
                title: ManagerText.Metrics.staffRatioTitle,
                value: viewModel.staffRatioDisplay,
                icon: "person.2.badge.gearshape",
                color: viewModel.staffToChildRatioCompliant ? .ncSuccess : .ncSecondary,
                subtitle: viewModel.staffToChildRatioCompliant
                    ? ManagerText.Metrics.staffRatioCompliant
                    : ManagerText.Metrics.staffRatioReview
            )
        }
    }
    
    // MARK: - Attention Section
    private var attentionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(.ncWarning)
                Text(ManagerText.Dashboard.attentionTitle)
                    .font(.title3.weight(.semibold))
                Spacer()
            }
            
            let attention = viewModel.childrenNeedingAttention()
            
            if attention.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.ncSuccess)
                        .font(.title2)
                    Text(ManagerText.Dashboard.attentionAllClearTitle)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: ManagerConstants.cardCornerRadius)
                        .fill(.ncSuccess.opacity(0.08))
                        .stroke(.ncSuccess.opacity(0.2), lineWidth: 1)
                )
            } else {
                ForEach(attention, id: \.child.id) { item in
                    AlertCardView(
                        childName: item.child.fullName,
                        childInitials: item.child.initials,
                        avatarColor: item.child.avatarColor,
                        reason: item.reason,
                        score: item.score,
                        onReview: {
                            openWindow(value: item.child.id)
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - EYFS Heatmap
    private var eyfsHeatmapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.xaxis")
                    .foregroundStyle(.ncPrimary)
                Text(ManagerText.Dashboard.eyfsHeatmapTitle)
                    .font(.title3.weight(.semibold))
                Spacer()
            }
            
            EYFSHeatmapView()
        }
    }
    
    // MARK: - Greeting
    private var timeOfDayGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return ManagerText.TimeOfDay.morning
        case 12..<17: return ManagerText.TimeOfDay.afternoon
        default: return ManagerText.TimeOfDay.evening
        }
    }
}
