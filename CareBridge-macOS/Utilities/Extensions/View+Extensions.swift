// View+Extensions.swift
// NurseryConnect
// SwiftUI View extensions for glassmorphism, neumorphism, and animations

import SwiftUI

// MARK: - Glassmorphism Modifier
struct GlassMorphismModifier: ViewModifier {
    var cornerRadius: CGFloat
    var opacity: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .opacity(opacity)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.45),
                                Color.white.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// MARK: - Neumorphism Modifier
struct NeumorphismModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var cornerRadius: CGFloat
    var isPressed: Bool
    
    func body(content: Content) -> some View {
        content
            .background(
                Group {
                    if colorScheme == .dark {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color(hex: "191C26"))
                            .shadow(color: Color.black.opacity(0.5), radius: isPressed ? 2 : 10, x: isPressed ? 1 : 4, y: isPressed ? 1 : 6)
                            .shadow(color: Color(hex: "2A2E3D").opacity(0.6), radius: isPressed ? 2 : 8, x: isPressed ? -1 : -4, y: isPressed ? -1 : -4)
                    } else {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.07), radius: isPressed ? 2 : 12, x: isPressed ? 1 : 4, y: isPressed ? 1 : 8)
                            .shadow(color: Color.white.opacity(0.9), radius: isPressed ? 2 : 6, x: isPressed ? -1 : -3, y: isPressed ? -1 : -3)
                    }
                }
            )
    }
}

// MARK: - Animated Appear Modifier
struct AnimatedAppearModifier: ViewModifier {
    @State private var isVisible = false
    var delay: Double
    var offsetY: CGFloat
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : offsetY)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

// MARK: - Slide In From Edge
struct SlideInModifier: ViewModifier {
    @State private var isVisible = false
    var delay: Double
    var edge: Edge
    
    var offset: CGSize {
        switch edge {
        case .leading: return CGSize(width: -50, height: 0)
        case .trailing: return CGSize(width: 50, height: 0)
        case .top: return CGSize(width: 0, height: -30)
        case .bottom: return CGSize(width: 0, height: 30)
        }
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(isVisible ? .zero : offset)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

// MARK: - Pulse Animation
struct PulseModifier: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .animation(
                .easeInOut(duration: 1.2)
                .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}

// MARK: - Shimmer Effect
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.4),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: phase * geometry.size.width * 2 - geometry.size.width)
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

// MARK: - Card Style Modifier
struct CardStyleModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var cornerRadius: CGFloat
    var hasShadow: Bool
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(colorScheme == .dark ? Color(hex: "191C26") : .white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(colorScheme == .dark ? Color.white.opacity(0.07) : Color.black.opacity(0.05), lineWidth: 1)
            )
            .if(hasShadow) { view in
                view
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.45 : 0.05), radius: 18, x: 0, y: 8)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.25 : 0.03), radius: 4, x: 0, y: 2)
            }
    }
}

// MARK: - View Extensions
extension View {
    func glassMorphism(cornerRadius: CGFloat = 20, opacity: CGFloat = 0.8) -> some View {
        modifier(GlassMorphismModifier(cornerRadius: cornerRadius, opacity: opacity))
    }
    
    func neumorphic(cornerRadius: CGFloat = 16, isPressed: Bool = false) -> some View {
        modifier(NeumorphismModifier(cornerRadius: cornerRadius, isPressed: isPressed))
    }
    
    func animatedAppear(delay: Double = 0, offsetY: CGFloat = 20) -> some View {
        modifier(AnimatedAppearModifier(delay: delay, offsetY: offsetY))
    }
    
    func slideIn(delay: Double = 0, from edge: Edge = .bottom) -> some View {
        modifier(SlideInModifier(delay: delay, edge: edge))
    }
    
    func pulse() -> some View {
        modifier(PulseModifier())
    }
    
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
    
    func cardStyle(cornerRadius: CGFloat = 16, hasShadow: Bool = true) -> some View {
        modifier(CardStyleModifier(cornerRadius: cornerRadius, hasShadow: hasShadow))
    }
    
    // Conditional modifier
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    // Adaptive background
    func adaptiveBackground() -> some View {
        self.background(Color.ncBackground)
    }
}

// MARK: - Adaptive Colors
extension Color {
    static var ncBackground: Color {
#if os(macOS)
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.name == .darkAqua ? NSColor(Color.ncBackgroundDark) : NSColor(Color.ncBackgroundLight)
        })
#else
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color.ncBackgroundDark)
                : UIColor(Color.ncBackgroundLight)
        })
#endif
    }
    
    static var ncText: Color {
#if os(macOS)
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.name == .darkAqua ? .white : NSColor(Color.ncTextPrimary)
        })
#else
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.white
                : UIColor(Color.ncTextPrimary)
        })
#endif
    }
    
    static var ncTextSec: Color {
#if os(macOS)
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.name == .darkAqua ? NSColor(white: 0.7, alpha: 1) : NSColor(Color.ncTextSecondary)
        })
#else
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(white: 0.7, alpha: 1)
                : UIColor(Color.ncTextSecondary)
        })
#endif
    }
    
    static var ncCard: Color {
#if os(macOS)
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.name == .darkAqua ? NSColor(Color(hex: "191C26")) : .white
        })
#else
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "191C26"))
                : UIColor.white
        })
#endif
    }
}

// MARK: - Number Counting Animation
struct CountingNumberModifier: AnimatableModifier {
    var number: Double
    
    var animatableData: Double {
        get { number }
        set { number = newValue }
    }
    
    func body(content: Content) -> some View {
        Text("\(Int(number))")
            .font(.ncMono(28))
            .fontWeight(.bold)
    }
}
