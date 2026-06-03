// SentimentAnalysisFeedView.swift
// NurseryConnect — Setting Manager (macOS)
// AI diary observation list with sentiment badges and keyword tags

import SwiftUI

struct SentimentAnalysisFeedView: View {
    let entries: [(entry: DiaryEntry, result: SentimentAnalysisResult?)]
    @Binding var expandedEntryId: UUID?
    @Environment(ManagerDataService.self) private var dataService
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(entries, id: \.entry.id) { item in
                observationRow(item.entry, result: item.result)
            }
        }
    }
    
    // MARK: - Observation Row
    private func observationRow(_ entry: DiaryEntry, result: SentimentAnalysisResult?) -> some View {
        let isExpanded = expandedEntryId == entry.id
        
        return VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack(spacing: 8) {
                // Entry type icon
                Image(systemName: entry.displayIcon)
                    .font(.callout)
                    .foregroundStyle(entry.displayColor)
                    .frame(width: 24, height: 24)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(entry.displayColor.opacity(0.12))
                    )
                
                // Date and type
                VStack(alignment: .leading, spacing: 1) {
                    Text(entry.timestamp.shortDateString)
                        .font(.caption.weight(.medium))
                    Text(entry.displayTitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(ManagerText.SentimentFeed.keyworkerPrefix) \(dataService.keyworkerName(for: entry.keyworkerId))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Sentiment badge
                if let result = result {
                    SentimentBadge(sentiment: result.sentiment)
                }
            }
            
            // Note text
            Text(entry.notes)
                .font(.callout)
                .foregroundStyle(.primary)
                .lineLimit(isExpanded ? nil : 2)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        expandedEntryId = isExpanded ? nil : entry.id
                    }
                }
            
            // Keyword tags
            if let result = result, !result.extractedKeywords.isEmpty {
                ManagerFlowLayout(spacing: 8) {
                    ForEach(result.extractedKeywords.prefix(8), id: \.self) { keyword in
                        Text(keyword)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.ncPrimary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.ncPrimary.opacity(0.1))
                            )
                    }
                }
            }
            
            // Score detail (when expanded)
            if isExpanded, let result = result {
                HStack(spacing: 12) {
                    Label(
                        String(format: "\(ManagerText.SentimentFeed.rawPrefix) %.2f", result.rawSentimentScore),
                        systemImage: "number"
                    )
                    Label(
                        String(format: "\(ManagerText.SentimentFeed.normalizedPrefix) %.0f", result.normalizedScore),
                        systemImage: "chart.line.uptrend.xyaxis"
                    )
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor(for: result?.sentiment))
                .stroke(borderColor(for: result?.sentiment), lineWidth: 1)
        )
    }
    
    private func backgroundColor(for sentiment: SentimentAnalysisResult.SentimentCategory?) -> Color {
        guard let sentiment = sentiment else { return Color(nsColor: .controlBackgroundColor) }
        switch sentiment {
        case .concern: return .ncSecondary.opacity(0.05)
        default: return Color(nsColor: .controlBackgroundColor)
        }
    }
    
    private func borderColor(for sentiment: SentimentAnalysisResult.SentimentCategory?) -> Color {
        guard let sentiment = sentiment else { return .clear }
        switch sentiment {
        case .concern: return .ncSecondary.opacity(0.3)
        case .positive: return .ncSuccess.opacity(0.2)
        default: return .clear
        }
    }
}

// MARK: - Flow Layout (for keyword tags)
struct ManagerFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        return computeSize(rows: rows)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for view in row.views {
                let size = view.sizeThatFits(.unspecified)
                view.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += size.width + spacing
            }
            y += row.maxHeight + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentRow = Row()
        var currentWidth: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if currentWidth + size.width > maxWidth, !currentRow.views.isEmpty {
                rows.append(currentRow)
                currentRow = Row()
                currentWidth = 0
            }
            currentRow.views.append(view)
            currentRow.maxHeight = max(currentRow.maxHeight, size.height)
            currentWidth += size.width + spacing
        }
        if !currentRow.views.isEmpty {
            rows.append(currentRow)
        }
        return rows
    }

    private func computeSize(rows: [Row]) -> CGSize {
        let width = rows.map { $0.width(spacing: spacing) }.max() ?? 0
        let height = rows.map { $0.maxHeight }.reduce(0, +) + CGFloat(max(0, rows.count - 1)) * spacing
        return CGSize(width: width, height: height)
    }

    private struct Row {
        var views: [LayoutSubview] = []
        var maxHeight: CGFloat = 0
        func width(spacing: CGFloat) -> CGFloat {
            views.map { $0.sizeThatFits(.unspecified).width }.reduce(0, +) + CGFloat(max(0, views.count - 1)) * spacing
        }
    }
}
