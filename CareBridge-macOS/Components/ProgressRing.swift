// ProgressRing.swift
// NurseryConnect
// Animated circular progress ring for statistics display

import SwiftUI

struct ProgressRing: View {
    let progress: Double // 0.0 to 1.0
    var color: Color
    var lineWidth: CGFloat
    var size: CGFloat
    var showPercentage: Bool
    var label: String?
    
    @State private var animatedProgress: Double = 0
    
    init(
        progress: Double,
        color: Color = .ncPrimary,
        lineWidth: CGFloat = 8,
        size: CGFloat = 80,
        showPercentage: Bool = true,
        label: String? = nil
    ) {
        self.progress = progress
        self.color = color
        self.lineWidth = lineWidth
        self.size = size
        self.showPercentage = showPercentage
        self.label = label
    }
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Background ring
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: lineWidth)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(
                        AngularGradient(
                            colors: [color.opacity(0.6), color],
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360 * animatedProgress)
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                
                // Center text
                if showPercentage {
                    Text("\(Int(animatedProgress * 100))%")
                        .font(.ncMono(size * 0.22))
                        .fontWeight(.bold)
                        .foregroundStyle(Color.ncText)
                }
            }
            .frame(width: size, height: size)
            
            if let label = label {
                Text(label)
                    .font(.ncCaption(11))
                    .foregroundStyle(Color.ncTextSec)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.3)) {
                animatedProgress = min(progress, 1.0)
            }
        }
    }
}

// MARK: - Mini Progress Ring (for inline use)
struct MiniProgressRing: View {
    let progress: Double
    var color: Color
    
    init(progress: Double, color: Color = .ncPrimary) {
        self.progress = progress
        self.color = color
    }
    
    var body: some View {
        ProgressRing(
            progress: progress,
            color: color,
            lineWidth: 4,
            size: 36,
            showPercentage: false
        )
    }
}

// #Preview {
//     HStack(spacing: 24) {
//         ProgressRing(progress: 0.75, color: .ncPrimary, label: "Activities")
//         ProgressRing(progress: 0.5, color: .ncSuccess, label: "Meals")
//         ProgressRing(progress: 0.9, color: .ncSecondary, label: "Goals")
//     }
//     .padding()
// }
