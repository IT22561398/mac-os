// EmptyStateView.swift
// NurseryConnect
// Illustrated empty state component with SF Symbol, title, and call-to-action

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var buttonTitle: String?
    var buttonAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.ncPrimary.opacity(0.08))
                    .frame(width: 120, height: 120)
                
                Circle()
                    .fill(Color.ncPrimary.opacity(0.05))
                    .frame(width: 160, height: 160)
                
                Image(systemName: icon)
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(Color.ncPrimary)
            }
            .animatedAppear(delay: 0.1, offsetY: 10)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.ncTitle())
                    .foregroundStyle(Color.ncText)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.ncBody(14))
                    .foregroundStyle(Color.ncTextSec)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .animatedAppear(delay: 0.2, offsetY: 10)
            .padding(.horizontal, 40)
            
            if let buttonTitle = buttonTitle {
                GradientButton(title: buttonTitle, isFullWidth: false) {
                    buttonAction?()
                }
                .animatedAppear(delay: 0.3, offsetY: 10)
                .padding(.top, 8)
            }
            
            Spacer()
        }
    }
}

#Preview {
    EmptyStateView(
        icon: "doc.text.magnifyingglass",
        title: "No Entries Yet",
        subtitle: "Start logging activities for this child. Tap the + button to add a new diary entry.",
        buttonTitle: "Add First Entry"
    )
}
