// AvatarView.swift
// NurseryConnect
// Circular avatar with initials, optional status indicator dot, and allergy badge

import SwiftUI

struct AvatarView: View {
    let initials: String
    var color: Color
    var size: CGFloat
    var showStatus: Bool
    var statusColor: Color
    var hasAllergy: Bool
    var hasNoPhotoConsent: Bool
    
    init(
        initials: String,
        color: Color = .ncPrimary,
        size: CGFloat = 48,
        showStatus: Bool = false,
        statusColor: Color = .ncSuccess,
        hasAllergy: Bool = false,
        hasNoPhotoConsent: Bool = false
    ) {
        self.initials = initials
        self.color = color
        self.size = size
        self.showStatus = showStatus
        self.statusColor = statusColor
        self.hasAllergy = hasAllergy
        self.hasNoPhotoConsent = hasNoPhotoConsent
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    Text(initials)
                        .font(.system(size: size * 0.35, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
            
            if showStatus {
                Circle()
                    .fill(statusColor)
                    .frame(width: size * 0.25, height: size * 0.25)
                    .overlay(
                        Circle()
                            .stroke(Color.ncCard, lineWidth: 2)
                    )
                    .offset(x: 2, y: 2)
            }
            
            if hasAllergy {
                ZStack {
                    Circle()
                        .fill(Color.ncSecondary)
                        .frame(width: size * 0.3, height: size * 0.3)
                    Image(systemName: "exclamationmark")
                        .font(.system(size: size * 0.15, weight: .bold))
                        .foregroundStyle(.white)
                }
                .offset(x: 2, y: -size * 0.7)
            }
            
            if hasNoPhotoConsent {
                ZStack {
                    Circle()
                        .fill(Color.ncError)
                        .frame(width: size * 0.28, height: size * 0.28)
                    Image(systemName: "camera.fill")
                        .font(.system(size: size * 0.12, weight: .bold))
                        .foregroundStyle(.white)
                }
                .overlay(
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: size * 0.22, height: 1.5)
                        .rotationEffect(.degrees(-45))
                )
                .offset(x: -size * 0.7, y: 2)
            }
        }
    }
}

// MARK: - Child Avatar (convenience)
struct ChildAvatar: View {
    let child: ChildProfile
    var size: CGFloat
    var showAllergyBadge: Bool
    
    init(child: ChildProfile, size: CGFloat = 48, showAllergyBadge: Bool = true) {
        self.child = child
        self.size = size
        self.showAllergyBadge = showAllergyBadge
    }
    
    var body: some View {
        AvatarView(
            initials: child.initials,
            color: child.avatarColor,
            size: size,
            showStatus: true,
            statusColor: .ncSuccess,
            hasAllergy: showAllergyBadge && child.hasAllergies,
            hasNoPhotoConsent: !child.photographyConsent
        )
    }
}

// #Preview {
//     HStack(spacing: 16) {
//         AvatarView(initials: "OT", color: .ncPrimary, size: 56, showStatus: true, hasAllergy: true)
//         AvatarView(initials: "AO", color: .ncSecondary, size: 56, showStatus: true)
//         AvatarView(initials: "SW", color: Color(hex: "A29BFE"), size: 56, hasNoPhotoConsent: true)
//     }
//     .padding()
// }
