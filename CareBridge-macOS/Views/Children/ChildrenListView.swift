// ChildrenListView.swift
// NurseryConnect — Setting Manager (macOS)
// Filterable, searchable list of children grouped by room with AI wellbeing scores

import SwiftUI

struct ChildrenListView: View {
    @Binding var selectedChildId: UUID?
    @Environment(SettingManagerDashboardViewModel.self) private var viewModel
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        @Bindable var vm = viewModel
        
        List(selection: $selectedChildId) {
            ForEach(viewModel.availableRooms, id: \.self) { room in
                let children = room == ManagerText.roomFilterAll
                    ? viewModel.filteredChildren
                    : viewModel.filteredChildren.filter { $0.roomAssignment == room }
                
                if !children.isEmpty && room != ManagerText.roomFilterAll {
                    Section(room) {
                        ForEach(children) { child in
                            childRow(child)
                                .tag(child.id)
                                .contextMenu {
                                    childContextMenu(child)
                                }
                                .onDrag {
                                    NSItemProvider(object: child.id.uuidString as NSString)
                                }
                        }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .searchable(text: $vm.searchText, prompt: ManagerText.Children.searchPrompt)
        .navigationTitle(ManagerText.Children.title)
        .toolbar {
            ToolbarItem {
                Picker(ManagerText.Children.roomFilterLabel, selection: $vm.selectedRoom) {
                    ForEach(viewModel.availableRooms, id: \.self) { room in
                        Text(room).tag(room)
                    }
                }
                .pickerStyle(.menu)
                .help(ManagerText.Children.roomFilterHelp)
            }
        }
    }
    
    // MARK: - Child Row
    private func childRow(_ child: ChildProfile) -> some View {
        HStack(spacing: 10) {
            // Avatar
            ChildAvatarView(
                initials: child.initials,
                color: child.avatarColor,
                size: 36
            )
            
            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(child.fullName)
                    .font(.callout.weight(.medium))
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text(child.age)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if child.hasAllergies {
                        Image(systemName: "allergens.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(.ncSecondary)
                    }
                }
            }
            
            Spacer()
            
            // AI Wellbeing Score Badge
            WellbeingScoreBadge(score: viewModel.wellbeingScore(for: child.id))
        }
        .padding(.vertical, 2)
    }
    
    // MARK: - Context Menu
    @ViewBuilder
    private func childContextMenu(_ child: ChildProfile) -> some View {
        Button(ManagerText.Children.openNewWindow) {
            openWindow(value: child.id)
        }
        
        Divider()
        
        Button(ManagerText.Children.viewDiaryEntries) {
            selectedChildId = child.id
        }
        
        Button(ManagerText.Children.viewIncidents) {
            selectedChildId = child.id
        }
    }
}

// MARK: - Wellbeing Score Badge
struct WellbeingScoreBadge: View {
    let score: Double
    
    var body: some View {
        Text(String(format: "%.0f", score))
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(scoreColor)
            )
    }
    
    private var scoreColor: Color {
        if score >= ManagerConstants.wellbeingScoreHighThreshold {
            return .ncSuccess
        } else if score >= ManagerConstants.wellbeingScoreLowThreshold {
            return .ncWarning
        } else {
            return .ncSecondary
        }
    }
}
