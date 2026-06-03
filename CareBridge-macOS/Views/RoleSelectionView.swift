// RoleSelectionView.swift
// NurseryConnect
// Launch screen to select between Keyworker and Manager roles

import SwiftUI

struct RoleSelectionView: View {
    @Binding var selectedRole: AppRole?
    
    @State private var isHoveringKeyworker = false
    @State private var isHoveringManager = false
    @State private var appearAnimation = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.ncBackgroundLight, Color.ncPrimary.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(
                            LinearGradient(colors: [.ncPrimary, .ncSecondary], startPoint: .top, endPoint: .bottom)
                        )
                        .scaleEffect(appearAnimation ? 1.0 : 0.5)
                        .opacity(appearAnimation ? 1.0 : 0.0)
                        
                    Text("Welcome to NurseryConnect")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.ncText)
                        .opacity(appearAnimation ? 1.0 : 0.0)
                        
                    Text("Select your role to continue")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.ncTextSec)
                        .opacity(appearAnimation ? 1.0 : 0.0)
                }
                .padding(.bottom, 20)
                
                // Role Cards
                HStack(spacing: 40) {
                    // Keyworker Card
                    RoleCardView(
                        title: "Keyworker",
                        description: "Daily diary, attendance, and activity tracking",
                        icon: "person.text.rectangle.fill",
                        color: .ncPrimary,
                        isHovering: $isHoveringKeyworker
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            selectedRole = .keyworker
                        }
                    }
                    .offset(y: appearAnimation ? 0 : 50)
                    .opacity(appearAnimation ? 1.0 : 0.0)
                    
                    // Manager Card
                    RoleCardView(
                        title: "Setting Manager",
                        description: "Analytics, reports, and incident management",
                        icon: "chart.bar.doc.horizontal.fill",
                        color: .ncSecondary,
                        isHovering: $isHoveringManager
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            selectedRole = .manager
                        }
                    }
                    .offset(y: appearAnimation ? 0 : 50)
                    .opacity(appearAnimation ? 1.0 : 0.0)
                }
            }
            .padding(60)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appearAnimation = true
            }
        }
    }
}

struct RoleCardView: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    @Binding var isHovering: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(color.opacity(isHovering ? 0.2 : 0.1))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: icon)
                        .font(.system(size: 40))
                        .foregroundStyle(color)
                        .scaleEffect(isHovering ? 1.1 : 1.0)
                }
                .animation(.spring(), value: isHovering)
                
                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.ncText)
                    
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.ncTextSec)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(width: 260, height: 280)
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.ncCard)
                    .shadow(
                        color: color.opacity(isHovering ? 0.3 : 0.1),
                        radius: isHovering ? 20 : 10,
                        x: 0,
                        y: isHovering ? 10 : 5
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(color.opacity(isHovering ? 0.5 : 0.1), lineWidth: 2)
            )
            .scaleEffect(isHovering ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovering)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
