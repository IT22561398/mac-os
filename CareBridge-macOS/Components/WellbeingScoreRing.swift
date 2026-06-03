// WellbeingScoreRing.swift
// NurseryConnect — Setting Manager (macOS)
// Circular progress indicator for AI Wellbeing Score (0-100)

import SwiftUI

struct WellbeingScoreRing: View {
    let score: Double
    let trend: WellbeingTrend
    var size: CGFloat = 120
    
    @State private var animatedProgress: Double = 0
    
    private var progress: Double {
        min(max(score / 100.0, 0), 1)
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
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(scoreColor.opacity(0.15), lineWidth: size * 0.08)
                .frame(width: size, height: size)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [scoreColor.opacity(0.5), scoreColor]),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(
                        lineWidth: size * 0.08,
                        lineCap: .round
                    )
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
            
            // Center content
            VStack(spacing: 2) {
                Text(String(format: "%.0f", score))
                    .font(.system(size: size * 0.28, weight: .bold, design: .rounded))
                    .foregroundStyle(scoreColor)
                
                // Trend arrow
                HStack(spacing: 2) {
                    Image(systemName: trend.icon)
                        .font(.system(size: size * 0.09))
                    Text(trend.rawValue)
                        .font(.system(size: size * 0.08, weight: .medium))
                }
                .foregroundStyle(trend.color)
                
                Text(ManagerText.Wellbeing.scoreLabel)
                    .font(.system(size: size * 0.08))
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2)) {
                animatedProgress = progress
            }
        }
        .onChange(of: score) { _, newValue in
            withAnimation(.easeInOut(duration: 0.8)) {
                animatedProgress = min(max(newValue / 100.0, 0), 1)
            }
        }
    }
}
