// GradientButton.swift
// NurseryConnect
// Primary action button with gradient fill, press animation, and haptic feedback

import SwiftUI

struct GradientButton: View {
    let title: String
    var icon: String?
    var gradientColors: [Color]
    var isFullWidth: Bool
    var isDisabled: Bool
    var isLoading: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(
        title: String,
        icon: String? = nil,
        gradient: [Color] = [.ncGradientStart, .ncGradientEnd],
        isFullWidth: Bool = true,
        isDisabled: Bool = false,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.gradientColors = gradient
        self.isFullWidth = isFullWidth
        self.isDisabled = isDisabled
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            guard !isDisabled && !isLoading else { return }
            HapticManager.mediumTap()
            action()
        }) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.9)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(title)
                        .font(.ncButtonFont())
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                Group {
                    if isDisabled {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.25))
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: gradientColors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: gradientColors.first?.opacity(0.35) ?? .clear, radius: isPressed ? 6 : 14, y: isPressed ? 3 : 8)
                    }
                }
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Secondary Button Style
struct SecondaryButton: View {
    let title: String
    var icon: String?
    var color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(title: String, icon: String? = nil, color: Color = .ncPrimary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            HapticManager.lightTap()
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }
                Text(title)
                    .font(.ncButtonFont(14))
            }
            .foregroundStyle(color)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(color.opacity(0.12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(color.opacity(0.22), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// #Preview {
//     VStack(spacing: 16) {
//         GradientButton(title: "Save Entry", icon: "checkmark") {}
//         GradientButton(title: "Submit Report", gradient: [.ncSecondary, .ncGradientWarm]) {}
//         GradientButton(title: "Disabled", isDisabled: true) {}
//         GradientButton(title: "Loading...", isLoading: true) {}
//         
//         HStack {
//             SecondaryButton(title: "Cancel", icon: "xmark") {}
//             SecondaryButton(title: "Edit", icon: "pencil", color: .ncWarning) {}
//         }
//     }
//     .padding()
// }
