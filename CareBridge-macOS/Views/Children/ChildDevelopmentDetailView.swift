// ChildDevelopmentDetailView.swift
// NurseryConnect — Setting Manager (macOS)
// CORE NEW FEATURE: AI-Powered Child Development Analytics
// Integrates NaturalLanguage framework sentiment analysis + Swift Charts

import SwiftUI
import Charts

struct ChildDevelopmentDetailView: View {
    let childId: UUID
    @State private var analyticsVM = ChildAnalyticsViewModel()
    @State private var showExpandedEntry: UUID?
    
    var body: some View {
        Group {
            if analyticsVM.isLoading {
                ProgressView(ManagerText.ChildAnalytics.loading)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let child = analyticsVM.selectedChild {
                ScrollView {
                    VStack(spacing: 24) {
                        // Top: AI Wellbeing Intelligence Card
                        wellbeingIntelligenceCard(child)
                        
                        // Middle: Charts
                        chartsSection
                        
                        // Bottom: AI Observation Analysis Feed
                        observationFeed
                    }
                    .padding(24)
                }
                .background(Color(nsColor: .windowBackgroundColor))
                .navigationTitle(ManagerText.ChildAnalytics.navigationTitle(child.fullName))
            } else {
                Text(ManagerText.ChildAnalytics.childNotFound)
                    .foregroundStyle(.secondary)
            }
        }
        .task {
            await analyticsVM.loadAnalysis(for: childId)
        }
    }
    
    // MARK: - AI Wellbeing Intelligence Card
    private func wellbeingIntelligenceCard(_ child: ChildProfile) -> some View {
        HStack(spacing: 24) {
            // Child info
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    ChildAvatarView(
                        initials: child.initials,
                        color: child.avatarColor,
                        size: 56
                    )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(child.fullName)
                            .font(.title2.weight(.bold))
                        
                        HStack(spacing: 8) {
                            Label(child.age, systemImage: "birthday.cake")
                            Label(child.roomAssignment, systemImage: "door.left.hand.open")
                        }
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        
                        Text("\(ManagerText.ChildAnalytics.keyworkerPrefix) \(analyticsVM.keyworkerName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Allergen warnings
                if child.hasAllergies {
                    HStack(spacing: 4) {
                        Image(systemName: "allergens.fill")
                            .foregroundStyle(.ncSecondary)
                        Text(child.allergies.map { $0.name }.joined(separator: ", "))
                            .font(.caption)
                            .foregroundStyle(.ncSecondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.ncSecondary.opacity(0.1))
                    )
                }
            }
            
            Spacer()
            
            // Wellbeing Score Ring
            VStack(spacing: 8) {
                WellbeingScoreRing(
                    score: analyticsVM.wellbeingScore,
                    trend: analyticsVM.wellbeingTrend,
                    size: 120
                )
                
                Text(ManagerText.ChildAnalytics.basedOnObservations(analyticsVM.analyzedEntryCount))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                if let lastTime = ManagerDataService.shared.lastAnalysisTime {
                    Text(ManagerText.ChildAnalytics.updated(lastTime.relativeTimeString))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: ManagerConstants.cardCornerRadius)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
        )
    }
    
    // MARK: - Charts Section
    private var chartsSection: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                // Wellbeing Trend Line Chart
                chartCard(title: ManagerText.ChildAnalytics.wellbeingTrendTitle, icon: "chart.xyaxis.line") {
                    WellbeingTrendChartView(data: analyticsVM.wellbeingTrendChartData())
                        .frame(height: 200)
                }
                
                // Mood Distribution Pie
                chartCard(title: ManagerText.ChildAnalytics.moodDistributionTitle, icon: "chart.pie.fill") {
                    MoodDistributionChartView(data: analyticsVM.moodPieChartData())
                        .frame(height: 200)
                }
            }
            
            // EYFS Coverage Bar Chart
            chartCard(title: ManagerText.ChildAnalytics.eyfsCoverageTitle, icon: "chart.bar.fill") {
                EYFSCoverageBarChartView(data: analyticsVM.eyfsBarChartData())
                    .frame(height: 200)
            }
        }
    }
    
    // MARK: - Chart Card Wrapper
    private func chartCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundStyle(.ncPrimary)
                Text(title)
                    .font(.headline)
            }
            
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: ManagerConstants.cardCornerRadius)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        )
    }
    
    // MARK: - Observation Feed
    private var observationFeed: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundStyle(.ncPrimary)
                Text(ManagerText.ChildAnalytics.observationFeedTitle)
                    .font(.title3.weight(.semibold))
                Spacer()
                Text(ManagerText.ChildAnalytics.observationCount(analyticsVM.analyzedEntries.count))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            SentimentAnalysisFeedView(
                entries: analyticsVM.analyzedEntries,
                expandedEntryId: $showExpandedEntry
            )
        }
    }
}
