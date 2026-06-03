// GlassCard.swift
// NurseryConnect
// Glassmorphism card component with blur + transparency effect

import SwiftUI

struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat
    var padding: CGFloat
    @ViewBuilder var content: () -> Content
    
    init(cornerRadius: CGFloat = 20, padding: CGFloat = 16, @ViewBuilder content: @escaping () -> Content) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content
    }
    
    var body: some View {
        content()
            .padding(padding)
            .glassMorphism(cornerRadius: cornerRadius)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        LinearGradient(
            colors: [.ncPrimary, .ncGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Glass Card")
                    .font(.ncTitle())
                    .foregroundStyle(.white)
                Text("This is a glassmorphism card component")
                    .font(.ncBody())
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .padding()
    }
}
