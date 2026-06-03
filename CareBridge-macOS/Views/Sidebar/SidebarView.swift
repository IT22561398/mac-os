// SidebarView.swift
// NurseryConnect — Setting Manager (macOS)
// Navigation sidebar with sections, badges, and manager profile card

import SwiftUI

struct SidebarView: View {
    @Binding var selection: SidebarItem
    @Environment(SettingManagerDashboardViewModel.self) private var viewModel
    @Environment(ManagerDataService.self) private var dataService
    
    var body: some View {
        VStack(spacing: 0) {
            // App Header
            headerView
            
            Divider()
                .padding(.horizontal)
            
            // Navigation Items
            List(selection: $selection) {
                Section(ManagerText.Sidebar.dashboardSection) {
                    sidebarRow(for: .overview)
                }
                
                Section(ManagerText.Sidebar.managementSection) {
                    sidebarRow(for: .allChildren, badge: viewModel.allChildren.count)
                    sidebarRow(for: .incidentQueue, badge: viewModel.pendingIncidentCount)
                    sidebarRow(for: .aiInsights, badge: viewModel.flaggedWellbeingCount)
                }
                
                Section(ManagerText.Sidebar.toolsSection) {
                    sidebarRow(for: .reports)
                    sidebarRow(for: .settings)
                }
            }
            .listStyle(.sidebar)
            
            Divider()
                .padding(.horizontal)
            
            // Manager Profile Card
            managerProfileCard
        }
        .background(.windowBackground)
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack(spacing: 10) {
            Image(systemName: "building.2.fill")
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.ncPrimary, .ncGradientEnd],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(ManagerConstants.appTitle)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text(ManagerText.settingManagerRole)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
    
    // MARK: - Sidebar Row
    private func sidebarRow(for item: SidebarItem, badge: Int? = nil) -> some View {
        Label {
            HStack {
                Text(item.rawValue)
                Spacer()
                if let badge = badge, badge > 0 {
                    Text("\(badge)")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(badgeColor(for: item))
                        )
                }
            }
        } icon: {
            Image(systemName: item.icon)
                .foregroundStyle(item.color)
                .frame(width: 20)
        }
        .tag(item)
    }
    
    private func badgeColor(for item: SidebarItem) -> Color {
        switch item {
        case .incidentQueue: return .ncSecondary
        case .aiInsights: return .ncWarning
        default: return .ncPrimary
        }
    }
    
    // MARK: - Manager Profile Card
    private var managerProfileCard: some View {
        HStack(spacing: 10) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.ncPrimary, .ncGradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)
                
                Text(dataService.managerProfile.initials)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(dataService.managerProfile.fullName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Text(dataService.managerProfile.role)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Online indicator
            Circle()
                .fill(Color.ncSuccess)
                .frame(width: 8, height: 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
