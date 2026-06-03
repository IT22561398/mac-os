// ChildAvatarView.swift
// NurseryConnect — Setting Manager (macOS)
// Reusable child avatar circle with initials

import SwiftUI

struct ChildAvatarView: View {
    let initials: String
    let color: Color
    var size: CGFloat = 40
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
            
            Text(initials)
                .font(.system(size: size * 0.35, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
    }
}
