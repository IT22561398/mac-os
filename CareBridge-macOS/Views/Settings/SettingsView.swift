// SettingsView.swift
// NurseryConnect
// Settings & Profile screen with theme toggle, about, and data management

import SwiftUI

struct SettingsView: View {
    @Environment(DataManager.self) var dataManager
    @Environment(ThemeManager.self) var themeManager
    @State private var showResetConfirm = false
    @State private var showAbout = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Profile card
                    profileCard
                    
                    // Appearance
                    settingsSection(title: "Appearance") {
                        toggleRow(
                            icon: "moon.fill",
                            iconColor: Color(hex: "A29BFE"),
                            title: "Dark Mode",
                            isOn: Binding(
                                get: { themeManager.isDarkMode },
                                set: { _ in themeManager.toggle() }
                            )
                        )
                    }
                    
                    // About
                    settingsSection(title: "Information") {
                        navigationRow(icon: "info.circle.fill", iconColor: .ncPrimary, title: "About NurseryConnect") {
                            showAbout = true
                        }
                        
                        staticRow(icon: "building.2.fill", iconColor: .ncSuccess, title: "Nursery", value: AppConfig.nurseryName)
                        staticRow(icon: "person.badge.shield.checkmark.fill", iconColor: .ncWarning, title: "Role", value: "Keyworker")
                        staticRow(icon: "house.fill", iconColor: Color(hex: "A29BFE"), title: "Room", value: dataManager.keyworker.roomAssignment)
                    }
                    
                    // Compliance
                    settingsSection(title: "Compliance") {
                        staticRow(icon: "lock.shield.fill", iconColor: .ncPrimary, title: "UK GDPR", value: "Active")
                        staticRow(icon: "checkmark.seal.fill", iconColor: .ncSuccess, title: "EYFS 2024", value: "Compliant")
                        staticRow(icon: "doc.text.fill", iconColor: .ncWarning, title: "Data Retention", value: "Automated")
                    }
                    
                    // Account
                    settingsSection(title: "Account") {
                        actionRow(icon: "arrow.left.square.fill", iconColor: .ncPrimary, title: "Switch Role") {
                            NotificationCenter.default.post(name: .logout, object: nil)
                        }
                    }
                    
                    // Data
                    settingsSection(title: "Data Management") {
                        actionRow(icon: "arrow.counterclockwise", iconColor: .ncWarning, title: "Reset to Sample Data") {
                            showResetConfirm = true
                        }
                    }
                    
                    // Version
                    VStack(spacing: 4) {
                        Text("NurseryConnect MVP")
                            .font(.ncCaption(12))
                            .foregroundStyle(Color.ncTextSec)
                        Text("Version 1.0.0 · Build 2026.1")
                            .font(.ncMono(10))
                            .foregroundStyle(Color.ncTextSecondary.opacity(0.5))
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 100)
                }
                .padding(.horizontal, 16)
            }
            .background(Color.ncBackground)
            .navigationTitle("Settings")
            
            .alert("Reset Data?", isPresented: $showResetConfirm) {
                Button("Reset", role: .destructive) {
                    dataManager.resetToSampleData()
                    HapticManager.notification(.success)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will replace all data with fresh sample data. This cannot be undone.")
            }
            .sheet(isPresented: $showAbout) {
                aboutView
            }
        }
    }
    
    // MARK: - Profile Card
    private var profileCard: some View {
        HStack(spacing: 14) {
            AvatarView(
                initials: dataManager.keyworker.initials,
                color: .ncPrimary,
                size: 60,
                showStatus: true,
                statusColor: .ncSuccess
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(dataManager.keyworker.fullName)
                    .font(.ncTitle(18))
                    .foregroundStyle(Color.ncText)
                Text(dataManager.keyworker.qualification)
                    .font(.ncCaption(12))
                    .foregroundStyle(Color.ncTextSec)
                Text("Since \(dataManager.keyworker.startDate.shortDateString)")
                    .font(.ncMono(10))
                    .foregroundStyle(Color.ncTextSec)
            }
            
            Spacer()
        }
        .padding(16)
        .cardStyle()
        .animatedAppear(delay: 0.05)
    }
    
    // MARK: - Section
    private func settingsSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.ncCaption(11))
                .foregroundStyle(Color.ncTextSec)
                .tracking(0.5)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                content()
            }
            .cardStyle()
        }
    }
    
    // MARK: - Row Types
    private func toggleRow(icon: String, iconColor: Color, title: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            settingsIcon(icon, color: iconColor)
            Text(title)
                .font(.ncBody(15))
                .foregroundStyle(Color.ncText)
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(.ncPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
    
    private func navigationRow(icon: String, iconColor: Color, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                settingsIcon(icon, color: iconColor)
                Text(title)
                    .font(.ncBody(15))
                    .foregroundStyle(Color.ncText)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.ncTextSec)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func staticRow(icon: String, iconColor: Color, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            settingsIcon(icon, color: iconColor)
            Text(title)
                .font(.ncBody(15))
                .foregroundStyle(Color.ncText)
            Spacer()
            Text(value)
                .font(.ncCaption(13))
                .foregroundStyle(Color.ncTextSec)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
    
    private func actionRow(icon: String, iconColor: Color, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                settingsIcon(icon, color: iconColor)
                Text(title)
                    .font(.ncBody(15))
                    .foregroundStyle(iconColor)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func settingsIcon(_ name: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(color.opacity(0.12))
                .frame(width: 28, height: 28)
            Image(systemName: name)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(color)
        }
    }
    
    // MARK: - About View
    private var aboutView: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Logo
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.ncGradientStart, .ncGradientEnd],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(.white)
                    }
                    .padding(.top, 20)
                    
                    Text("NurseryConnect")
                        .font(.ncHeadline(24))
                        .foregroundStyle(Color.ncText)
                    
                    Text(AppConfig.tagline)
                        .font(.ncBody(14))
                        .foregroundStyle(Color.ncTextSec)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About")
                            .font(.ncTitle(16))
                            .foregroundStyle(Color.ncText)
                        
                        Text("NurseryConnect is an MVP iOS application designed for UK Early Years settings. This build focuses on the Keyworker role, implementing Daily Diary & Activity Monitoring and Incident Reporting features.")
                            .font(.ncBody(14))
                            .foregroundStyle(Color.ncTextSec)
                            .lineSpacing(3)
                        
                        Divider().padding(.vertical, 4)
                        
                        Text("Compliance")
                            .font(.ncTitle(16))
                            .foregroundStyle(Color.ncText)
                        
                        Text("Designed with UK GDPR data minimisation principles, EYFS 2024 requirements, and RIDDOR-aligned incident reporting. Data is stored locally on-device with no external transmission.")
                            .font(.ncBody(14))
                            .foregroundStyle(Color.ncTextSec)
                            .lineSpacing(3)
                        
                        Divider().padding(.vertical, 4)
                        
                        Text("Technology")
                            .font(.ncTitle(16))
                            .foregroundStyle(Color.ncText)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            techRow("Language", "Swift 5.9+")
                            techRow("Framework", "SwiftUI")
                            techRow("Architecture", "MVVM")
                            techRow("Min iOS", "17.0")
                            techRow("Persistence", "JSON + UserDefaults")
                            techRow("Charts", "Swift Charts")
                            techRow("Dependencies", "Native only — zero 3rd party")
                        }
                    }
                    .padding(16)
                    .cardStyle()
                    
                    Text("© 2026 Little Stars Nursery & Daycare")
                        .font(.ncCaption(11))
                        .foregroundStyle(Color.ncTextSecondary.opacity(0.5))
                        .padding(.bottom, 20)
                }
                .padding(.horizontal, 16)
            }
            .background(Color.ncBackground)
            .navigationTitle("About")
            
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") { showAbout = false }
                        .font(.ncButtonFont(14))
                        .foregroundStyle(Color.ncPrimary)
                }
            }
        }
    }
    
    private func techRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.ncCaption(12))
                .foregroundStyle(Color.ncTextSec)
                .frame(width: 100, alignment: .leading)
            Text(value)
                .font(.ncMono(12))
                .foregroundStyle(Color.ncText)
        }
    }
}

#Preview {
    SettingsView()
        .environment(DataManager.shared)
        .environment(ThemeManager())
}
