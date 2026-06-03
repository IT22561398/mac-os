// SplashView.swift
// NurseryConnect
// Animated splash screen with logo animation and gradient background

import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    @State private var showTitle = false
    @State private var showTagline = false
    @State private var scaleEffect: CGFloat = 0.3
    @State private var rotationAngle: Double = -30
    @State private var gradientOffset: CGFloat = 0
    @Binding var isFinished: Bool
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [
                    Color(hex: "6366F1"),
                    Color(hex: "8B5CF6"),
                    Color(hex: "0E1016").opacity(0.35)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .hueRotation(.degrees(gradientOffset))
            .ignoresSafeArea()
            
            // Floating decorative circles
            floatingCircles
            
            VStack(spacing: 24) {
                Spacer()
                
                // Logo
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 140, height: 140)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                    
                    // Main circle
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 110, height: 110)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                        .shadow(color: .ncPrimary.opacity(0.3), radius: 20)
                    
                    // Star icon
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 50, weight: .light))
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(rotationAngle))
                }
                .scaleEffect(scaleEffect)
                
                // App name
                if showTitle {
                    VStack(spacing: 6) {
                        Text("NurseryConnect")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        if showTagline {
                            Text("Caring Together, Connected Always")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                
                Spacer()
                
                // Nursery name
                if showTagline {
                    VStack(spacing: 4) {
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.5))
                        Text("Little Stars Nursery & Daycare")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .transition(.opacity)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    // MARK: - Floating Circles
    private var floatingCircles: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 200, height: 200)
                .offset(x: -100, y: -250)
                .scaleEffect(isAnimating ? 1.3 : 0.9)
            
            Circle()
                .fill(Color.ncAccent.opacity(0.08))
                .frame(width: 150, height: 150)
                .offset(x: 120, y: 300)
                .scaleEffect(isAnimating ? 1.1 : 0.8)
            
            Circle()
                .fill(Color.white.opacity(0.04))
                .frame(width: 100, height: 100)
                .offset(x: 130, y: -150)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
        }
        .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isAnimating)
    }
    
    // MARK: - Animations
    private func startAnimations() {
        // Logo scale & rotation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            scaleEffect = 1.0
            rotationAngle = 0
        }
        
        // Floating circles
        withAnimation(.easeInOut(duration: 2)) {
            isAnimating = true
        }
        
        // Gradient animation
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: true)) {
            gradientOffset = 30
        }
        
        // Title
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5)) {
            showTitle = true
        }
        
        // Tagline
        withAnimation(.easeOut(duration: 0.5).delay(1.0)) {
            showTagline = true
        }
        
        // Dismiss after 2.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                isFinished = true
            }
        }
    }
}

#Preview {
    SplashView(isFinished: .constant(false))
}
