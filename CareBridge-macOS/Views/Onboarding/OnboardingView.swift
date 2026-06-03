// OnboardingView.swift
// NurseryConnect
// 3-page onboarding flow with SF Symbol illustrations and parallax-like transitions

import SwiftUI

struct OnboardingView: View {
    @Binding var isFinished: Bool
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "book.and.wrench.fill",
            decorativeIcons: ["pencil.and.list.clipboard", "heart.text.clipboard.fill", "chart.bar.xaxis.ascending"],
            title: "Daily Diary",
            subtitle: "Log every moment of a child's day — activities, meals, sleep, nappies, and wellbeing — all from one beautiful interface.",
            color: .ncPrimary
        ),
        OnboardingPage(
            icon: "exclamationmark.shield.fill",
            decorativeIcons: ["cross.case.fill", "person.badge.shield.checkmark.fill", "doc.richtext.fill"],
            title: "Incident Reporting",
            subtitle: "RIDDOR-aligned digital forms with body map diagrams, witness recording, and a structured review workflow.",
            color: .ncSecondary
        ),
        OnboardingPage(
            icon: "lock.shield.fill",
            decorativeIcons: ["hand.raised.fill", "eye.slash.fill", "checkmark.seal.fill"],
            title: "Built for Compliance",
            subtitle: "Designed with UK GDPR, EYFS 2024, and Ofsted requirements at its core. Data minimisation by design.",
            color: Color(hex: "A29BFE")
        )
    ]
    
    var body: some View {
        ZStack {
            Color.ncBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Tab view with pages
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        onboardingPageView(page: page, index: index)
                            .tag(index)
                    }
                }
                
                .animation(.spring(response: 0.5), value: currentPage)
                
                // Bottom section
                VStack(spacing: 20) {
                    // Page indicators
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { i in
                            Capsule()
                                .fill(i == currentPage ? pages[currentPage].color : Color.ncTextSecondary.opacity(0.3))
                                .frame(width: i == currentPage ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }
                    
                    // Button
                    GradientButton(
                        title: currentPage == pages.count - 1 ? "Get Started" : "Continue",
                        icon: currentPage == pages.count - 1 ? "arrow.right" : nil,
                        gradient: [pages[currentPage].color, pages[currentPage].color.opacity(0.7)]
                    ) {
                        if currentPage < pages.count - 1 {
                            withAnimation(.spring(response: 0.4)) {
                                currentPage += 1
                            }
                        } else {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                isFinished = true
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                isFinished = true
                            }
                        }
                        .font(.ncBody(14))
                        .foregroundStyle(Color.ncTextSec)
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - Page View
    private func onboardingPageView(page: OnboardingPage, index: Int) -> some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Illustration area
            ZStack {
                // Background circle
                Circle()
                    .fill(page.color.opacity(0.08))
                    .frame(width: 220, height: 220)
                
                Circle()
                    .fill(page.color.opacity(0.04))
                    .frame(width: 280, height: 280)
                
                // Decorative orbiting icons
                ForEach(Array(page.decorativeIcons.enumerated()), id: \.offset) { i, icon in
                    let angle = (Double(i) / Double(page.decorativeIcons.count)) * 360 - 90
                    let radius: CGFloat = 110
                    
                    ZStack {
                        Circle()
                            .fill(page.color.opacity(0.12))
                            .frame(width: 44, height: 44)
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(page.color.opacity(0.7))
                    }
                    .offset(
                        x: cos(angle * .pi / 180) * radius,
                        y: sin(angle * .pi / 180) * radius
                    )
                }
                
                // Center icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [page.color, page.color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: page.color.opacity(0.3), radius: 16, y: 6)
                    
                    Image(systemName: page.icon)
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .animatedAppear(delay: 0.1)
            
            // Text content
            VStack(spacing: 12) {
                Text(page.title)
                    .font(.ncHeadline(28))
                    .foregroundStyle(Color.ncText)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.ncBody(15))
                    .foregroundStyle(Color.ncTextSec)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 32)
            .animatedAppear(delay: 0.2)
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Onboarding Page Model
struct OnboardingPage {
    let icon: String
    let decorativeIcons: [String]
    let title: String
    let subtitle: String
    let color: Color
}

#Preview {
    OnboardingView(isFinished: .constant(false))
}
