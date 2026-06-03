// ChildProfileView.swift
// NurseryConnect
// Read-only child profile card (Section 7.2) with personal, medical, dietary, and consent info

import SwiftUI

struct ChildProfileView: View {
    let child: ChildProfile
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    // Photography consent warning — Von Restorff
                    if !child.photographyConsent {
                        HStack(spacing: 12) {
                            ZStack {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white)
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: 26, height: 2)
                                    .rotationEffect(.degrees(-45))
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("NO PHOTOGRAPHY CONSENT")
                                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                                    .foregroundStyle(.white)
                                    .tracking(0.3)
                                Text("Do not photograph this child under any circumstances")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.9))
                            }

                            Spacer()
                        }
                        .padding(14)
                        .frame(minHeight: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(hex: "E74C3C"))
                        )
                        .accessibilityLabel("Warning: No photography consent for \(child.displayName). Do not photograph this child.")
                    }

                    // Profile header
                    profileHeader
                    
                    // Personal info
                    infoSection(title: "Personal Information", icon: "person.fill") {
                        infoRow("Full Name", child.fullName)
                        infoRow("Preferred Name", child.preferredName.isEmpty ? "—" : child.preferredName)
                        infoRow("Date of Birth", child.dateOfBirth.shortDateString)
                        infoRow("Age", child.age)
                        infoRow("Room", child.roomAssignment)
                        infoRow("Session Times", child.sessionTimes)
                    }
                    
                    // Family & Emergency
                    infoSection(title: "Family & Emergency", icon: "house.fill") {
                        infoRow("Parent/Guardian", child.parentName)
                        infoRow("Parent Email", child.parentEmail)
                        infoRow("Parent Phone", child.parentPhone)
                        Divider()
                        infoRow("Emergency Contact", child.emergencyContact)
                        infoRow("Emergency Phone", child.emergencyPhone)
                    }
                    
                    // Medical & Health
                    infoSection(title: "Health & Medical", icon: "cross.case.fill") {
                        if child.medicalConditions.isEmpty {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.ncSuccess)
                                Text("No medical conditions recorded")
                                    .font(.ncBody(14))
                                    .foregroundStyle(Color.ncTextSec)
                            }
                        } else {
                            ForEach(child.medicalConditions, id: \.self) { condition in
                                HStack(spacing: 8) {
                                    Image(systemName: "staroflife.fill")
                                        .font(.system(size: 10))
                                        .foregroundStyle(Color.ncWarning)
                                    Text(condition)
                                        .font(.ncBody(14))
                                        .foregroundStyle(Color.ncText)
                                }
                            }
                        }
                    }
                    
                    // Allergies
                    if !child.allergies.isEmpty {
                        allergySection
                    }
                    
                    // Dietary
                    if !child.dietaryRequirements.isEmpty {
                        infoSection(title: "Dietary Requirements", icon: "leaf.fill") {
                            ForEach(child.dietaryRequirements, id: \.self) { req in
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color.ncSuccess)
                                    Text(req)
                                        .font(.ncBody(14))
                                        .foregroundStyle(Color.ncText)
                                }
                            }
                        }
                    }
                    
                    // Consent Records (Section 8.2)
                    consentSection
                }
                .padding(16)
            }
            .background(Color.ncBackground)
            .navigationTitle("Child Profile")
            
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") { dismiss() }
                        .font(.ncButtonFont(14))
                        .foregroundStyle(Color.ncPrimary)
                }
            }
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 14) {
            ChildAvatar(child: child, size: 80)
            
            VStack(spacing: 4) {
                Text(child.fullName)
                    .font(.ncHeadline(22))
                    .foregroundStyle(Color.ncText)
                
                Text("\(child.age) · \(child.roomAssignment)")
                    .font(.ncBody(14))
                    .foregroundStyle(Color.ncTextSec)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .cardStyle()
        .animatedAppear(delay: 0.05)
    }
    
    // MARK: - Allergy Section
    private var allergySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(Color.ncWarning)
                Text("Allergies")
                    .font(.ncTitle(15))
                    .foregroundStyle(Color.ncText)
            }
            
            ForEach(child.allergies) { allergen in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(allergen.name)
                            .font(.ncBody(14))
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.ncText)
                        
                        Spacer()
                        
                        StatusBadge(
                            text: allergen.severity.rawValue,
                            color: allergen.severity.color,
                            size: .small
                        )
                    }
                    
                    if !allergen.notes.isEmpty {
                        Text(allergen.notes)
                            .font(.ncCaption(12))
                            .foregroundStyle(Color.ncTextSec)
                            .lineSpacing(2)
                    }
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(allergen.severity.color.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(allergen.severity.color.opacity(0.15), lineWidth: 1)
                        )
                )
            }
        }
        .padding(14)
        .cardStyle()
        .animatedAppear(delay: 0.15)
    }
    
    // MARK: - Consent Section
    private var consentSection: some View {
        infoSection(title: "GDPR Consent Records", icon: "lock.shield.fill") {
            consentRow("Photography", child.photographyConsent)
            consentRow("Social Media", child.socialMediaConsent)
            consentRow("Data Processing", child.dataProcessingConsent)
        }
    }
    
    private func consentRow(_ title: String, _ granted: Bool) -> some View {
        HStack {
            Text(title)
                .font(.ncBody(14))
                .foregroundStyle(Color.ncText)
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: granted ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(granted ? Color.ncSuccess : Color.ncError)
                Text(granted ? "Granted" : "Withheld")
                    .font(.ncCaption(12))
                    .foregroundStyle(granted ? Color.ncSuccess : Color.ncError)
            }
        }
    }
    
    // MARK: - Info Section Helper
    private func infoSection(title: String, icon: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundStyle(Color.ncPrimary)
                    .font(.system(size: 14))
                Text(title)
                    .font(.ncTitle(15))
                    .foregroundStyle(Color.ncText)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                content()
            }
        }
        .padding(14)
        .cardStyle()
        .animatedAppear(delay: 0.1)
    }
    
    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.ncCaption(12))
                .foregroundStyle(Color.ncTextSec)
                .frame(width: 120, alignment: .leading)
            Text(value)
                .font(.ncBody(14))
                .foregroundStyle(Color.ncText)
            Spacer()
        }
    }
}

#Preview {
    ChildProfileView(child: SampleData.children[0])
}
