// AIInsightsDashboardView.swift
// NurseryConnect — Setting Manager (macOS)
// AI Insights list — children with flagged wellbeing concerns

import SwiftUI

struct AIInsightsListView: View {
    @Binding var selectedChildId: UUID?
    @Environment(SettingManagerDashboardViewModel.self) private var viewModel
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        List(selection: $selectedChildId) {
            // Flagged children
            Section(ManagerText.AIInsights.concernsSection(viewModel.wellbeingAlerts.count)) {
                if viewModel.wellbeingAlerts.isEmpty {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.ncSuccess)
                        Text(ManagerText.AIInsights.noConcerns)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                } else {
                    ForEach(viewModel.wellbeingAlerts) { alert in
                        alertRow(alert)
                            .tag(alert.childId)
                    }
                }
            }
            
            // All children with scores
            Section(ManagerText.AIInsights.allChildrenSection) {
                ForEach(viewModel.allChildren.sorted(by: {
                    viewModel.wellbeingScore(for: $0.id) < viewModel.wellbeingScore(for: $1.id)
                })) { child in
                    childScoreRow(child)
                        .tag(child.id)
                        .contextMenu {
                            Button(ManagerText.AIInsights.openNewWindow) {
                                openWindow(value: child.id)
                            }
                            
                            Button(ManagerText.AIInsights.viewDetails) {
                                selectedChildId = child.id
                            }
                        }
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle(ManagerText.Menu.aiInsights)
    }
    
    // MARK: - Alert Row
    private func alertRow(_ alert: ChildWellbeingAlert) -> some View {
        HStack(spacing: 10) {
            Image(systemName: alert.alertType.iconName)
                .foregroundStyle(alert.alertType.severityColor)
                .font(.callout)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(alert.alertType.severityColor.opacity(0.12))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(alert.childName)
                    .font(.callout.weight(.medium))
                
                Text(alert.alertType.displayName)
                    .font(.caption)
                    .foregroundStyle(alert.alertType.severityColor)
                
                Text(alert.recommendedAction)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            WellbeingScoreBadge(score: alert.wellbeingScore)
        }
        .padding(.vertical, 2)
    }
    
    // MARK: - Child Score Row
    private func childScoreRow(_ child: ChildProfile) -> some View {
        HStack(spacing: 10) {
            ChildAvatarView(
                initials: child.initials,
                color: child.avatarColor,
                size: 32
            )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(child.fullName)
                    .font(.callout.weight(.medium))
                
                HStack(spacing: 4) {
                    Text(child.roomAssignment)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    // Trend indicator
                    let trend = viewModel.wellbeingTrend(for: child.id)
                    Image(systemName: trend.icon)
                        .font(.caption2)
                        .foregroundStyle(trend.color)
                    Text(trend.rawValue)
                        .font(.caption2)
                        .foregroundStyle(trend.color)
                }
            }
            
            Spacer()
            
            WellbeingScoreBadge(score: viewModel.wellbeingScore(for: child.id))
            
            Button(ManagerText.AIInsights.reviewButton) {
                openWindow(value: child.id)
            }
            .buttonStyle(.borderless)
            .font(.caption)
            .foregroundStyle(.ncPrimary)
        }
        .padding(.vertical, 2)
    }
}
