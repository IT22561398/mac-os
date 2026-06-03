// StatusBadge.swift
// NurseryConnect
// Color-coded status badges for incidents and diary entries

import SwiftUI

struct StatusBadge: View {
    let text: String
    var color: Color
    var icon: String?
    var size: BadgeSize
    
    enum BadgeSize {
        case small, medium, large
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 10
            case .medium: return 12
            case .large: return 14
            }
        }
        
        var paddingH: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 10
            case .large: return 14
            }
        }
        
        var paddingV: CGFloat {
            switch self {
            case .small: return 4
            case .medium: return 5
            case .large: return 7
            }
        }
    }
    
    init(text: String, color: Color = .ncPrimary, icon: String? = nil, size: BadgeSize = .medium) {
        self.text = text
        self.color = color
        self.icon = icon
        self.size = size
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: size.fontSize, weight: .semibold))
            }
            Text(text)
                .font(.system(size: size.fontSize, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(color)
        .padding(.horizontal, size.paddingH)
        .padding(.vertical, size.paddingV)
        .background(
            Capsule()
                .fill(color.opacity(0.12))
        )
        .overlay(
            Capsule()
                .stroke(color.opacity(0.22), lineWidth: 0.75)
        )
    }
}

// MARK: - Incident Status Badge
struct IncidentStatusBadge: View {
    let status: IncidentStatus
    
    var body: some View {
        StatusBadge(
            text: status.rawValue,
            color: status.color,
            icon: status.icon,
            size: .medium
        )
    }
}

// MARK: - Severity Badge
struct SeverityBadge: View {
    let severity: IncidentSeverity
    
    var body: some View {
        StatusBadge(
            text: severity.rawValue,
            color: severity.color,
            icon: severity == .high ? "exclamationmark.triangle.fill" : nil,
            size: .small
        )
    }
}

// MARK: - Allergen Badge
struct AllergenBadge: View {
    let allergen: Allergen
    
    var body: some View {
        StatusBadge(
            text: "\(allergen.name) (\(allergen.severity.rawValue))",
            color: allergen.severity.color,
            icon: "allergens.fill",
            size: .small
        )
    }
}

#Preview {
    VStack(spacing: 12) {
        ForEach(IncidentStatus.allCases) { status in
            IncidentStatusBadge(status: status)
        }
        
        Divider()
        
        SeverityBadge(severity: .low)
        SeverityBadge(severity: .medium)
        SeverityBadge(severity: .high)
    }
    .padding()
}
