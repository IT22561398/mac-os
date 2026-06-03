// SentimentBadge.swift
// NurseryConnect — Setting Manager (macOS)
// Sentiment classification badge (positive/neutral/concern)

import SwiftUI

struct SentimentBadge: View {
    let sentiment: SentimentAnalysisResult.SentimentCategory
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: sentiment.icon)
                .font(.system(size: 9))
            Text(sentiment.displayName)
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundStyle(sentiment.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(sentiment.color.opacity(0.12))
                .stroke(sentiment.color.opacity(0.3), lineWidth: 0.5)
        )
    }
}
