// AlertCardView.swift
// NurseryConnect — Setting Manager (macOS)
// Wellbeing alert card with child info, reason, score, and review action

import SwiftUI

struct AlertCardView: View {
    let childName: String
    let childInitials: String
    let avatarColor: Color
    let reason: String
    let score: Double
    var onReview: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ChildAvatarView(
                initials: childInitials,
                color: avatarColor,
                size: 40
            )
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(childName)
                    .font(.callout.weight(.semibold))
                
                Text(reason)
                    .font(.caption)
                    .foregroundStyle(.ncSecondary)
            }
            
            Spacer()
            
            // Score badge
            WellbeingScoreBadge(score: score)
            
            // Review button
            if let onReview = onReview {
                Button(ManagerText.AIInsights.reviewButton) {
                    onReview()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .help(ManagerText.AIInsights.reviewHelp)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: ManagerConstants.cardCornerRadius)
                .fill(Color(nsColor: .controlBackgroundColor))
                .stroke(scoreColor.opacity(0.3), lineWidth: 1)
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
