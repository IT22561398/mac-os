// NeumorphicCard.swift
// NurseryConnect
// Neumorphic card with soft inner/outer shadows

import SwiftUI

struct NeumorphicCard<Content: View>: View {
    var cornerRadius: CGFloat
    var padding: CGFloat
    @State private var isPressed = false
    var isInteractive: Bool
    var action: (() -> Void)?
    @ViewBuilder var content: () -> Content
    
    init(
        cornerRadius: CGFloat = 16,
        padding: CGFloat = 16,
        isInteractive: Bool = false,
        action: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.isInteractive = isInteractive
        self.action = action
        self.content = content
    }
    
    var body: some View {
        content()
            .padding(padding)
            .neumorphic(cornerRadius: cornerRadius, isPressed: isPressed)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .if(isInteractive) { view in
                view.onTapGesture {
                    HapticManager.lightTap()
                    withAnimation(.spring(response: 0.2)) {
                        isPressed = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.spring(response: 0.3)) {
                            isPressed = false
                        }
                        action?()
                    }
                }
            }
    }
}

#Preview {
    VStack(spacing: 24) {
        NeumorphicCard {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundStyle(Color.ncAccent)
                Text("Neumorphic Card")
                    .font(.ncTitle())
            }
        }
        
        NeumorphicCard(isInteractive: true) {
            Text("Tap Me!")
                .font(.ncButtonFont())
        }
    }
    .padding(32)
    .background(Color.ncBackgroundLight)
}
