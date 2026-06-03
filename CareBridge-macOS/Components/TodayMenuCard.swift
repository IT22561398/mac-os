// NurseryConnect | TodayMenuCard.swift
// Collapsible allergen-aware menu card for the dashboard.
// Displays today's meal schedule and flags allergens for assigned children.
// Compliant with Section 10.3 (14 major allergens) and EYFS dietary tracking.
//
// DESIGN: Collapsible via chevron toggle, Von Restorff red border for allergen meals.

import SwiftUI

// MARK: - Menu Item Data
struct MenuItemData: Identifiable {
    let id = UUID()
    let mealType: MealType
    let timeRange: String
    let mainCourse: String
    let sideDish: String
    let allergenFlags: [String]  // e.g. ["Dairy", "Gluten"]
}

// MARK: - TodayMenuCard

struct TodayMenuCard: View {
    @Environment(DataManager.self) private var dataManager

    @State private var isExpanded: Bool = false

    /// Static sample menu — in production, would come from a MenuManager.
    private var todayMenu: [MenuItemData] {
        [
            MenuItemData(
                mealType: .breakfast,
                timeRange: "8:00–8:30",
                mainCourse: "Porridge with berries",
                sideDish: "Toast fingers",
                allergenFlags: ["Gluten", "Dairy"]
            ),
            MenuItemData(
                mealType: .morningSnack,
                timeRange: "10:00–10:15",
                mainCourse: "Fruit slices & rice cakes",
                sideDish: "Water",
                allergenFlags: []
            ),
            MenuItemData(
                mealType: .lunch,
                timeRange: "12:00–12:45",
                mainCourse: "Chicken casserole with vegetables",
                sideDish: "Mashed potato, peas",
                allergenFlags: ["Celery"]
            ),
            MenuItemData(
                mealType: .afternoonSnack,
                timeRange: "3:00–3:15",
                mainCourse: "Crumpets with cream cheese",
                sideDish: "Cucumber sticks",
                allergenFlags: ["Gluten", "Dairy"]
            )
        ]
    }

    /// Children with allergen overlaps against today's menu.
    private var childrenWithAllergenRisks: [(child: ChildProfile, matchingAllergens: [String])] {
        dataManager.children.compactMap { child in
            let childAllergenNames = child.allergies.map { $0.name.lowercased() }
            let menuAllergens = Set(todayMenu.flatMap { $0.allergenFlags.map { $0.lowercased() } })
            let overlaps = childAllergenNames.filter { menuAllergens.contains($0) }
            if overlaps.isEmpty { return nil }
            return (child: child, matchingAllergens: overlaps.map { $0.capitalized })
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // MARK: Header
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
                HapticManager.selection()
            } label: {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "FF9F43").opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: "fork.knife")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color(hex: "FF9F43"))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Today's Menu")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.ncText)
                        Text("4 meals · \(childrenWithAllergenRisks.count) allergen alert\(childrenWithAllergenRisks.count == 1 ? "" : "s")")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.ncTextSec)
                    }

                    Spacer()

                    if !childrenWithAllergenRisks.isEmpty {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Color(hex: "FB7185"))
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.ncTextSec)
                }
                .frame(minHeight: 44)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Today's menu, 4 meals. \(childrenWithAllergenRisks.count) allergen alerts.")

            // MARK: Content
            if isExpanded {
                // Allergen warnings
                if !childrenWithAllergenRisks.isEmpty {
                    allergenWarningSection
                }

                // Menu items
                VStack(spacing: 10) {
                    ForEach(todayMenu) { item in
                        menuItemRow(item)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.ncCard)
                .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    childrenWithAllergenRisks.isEmpty
                        ? Color.white.opacity(0.06)
                        : Color(hex: "FB7185").opacity(0.2),
                    lineWidth: 1
                )
        )
    }

    // MARK: - Allergen Warning Section
    private var allergenWarningSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(childrenWithAllergenRisks, id: \.child.id) { item in
                HStack(spacing: 8) {
                    ChildAvatar(child: item.child, size: 28, showAllergyBadge: true)

                    Text(item.child.displayName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.ncText)

                    Text("—")
                        .foregroundStyle(Color.ncTextSec)

                    Text(item.matchingAllergens.joined(separator: ", "))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(hex: "FB7185"))
                        .lineLimit(1)

                    Spacer()
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: "FB7185").opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: "FB7185").opacity(0.15), lineWidth: 1)
                )
        )
    }

    // MARK: - Menu Item Row
    private func menuItemRow(_ item: MenuItemData) -> some View {
        HStack(spacing: 12) {
            // Meal type icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(mealColor(item.mealType).opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: item.mealType.icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(mealColor(item.mealType))
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(item.mealType.rawValue)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.ncText)

                    Text(item.timeRange)
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color.ncTextSec)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.white.opacity(0.06)))
                }

                Text("\(item.mainCourse) · \(item.sideDish)")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(Color.ncTextSec)
                    .lineLimit(1)
            }

            Spacer()

            // Allergen flags
            if !item.allergenFlags.isEmpty {
                HStack(spacing: 3) {
                    ForEach(item.allergenFlags.prefix(2), id: \.self) { allergen in
                        Text(allergen)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(Color(hex: "FB7185"))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(
                                Capsule().fill(Color(hex: "FB7185").opacity(0.1))
                            )
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .accessibilityLabel("\(item.mealType.rawValue) at \(item.timeRange): \(item.mainCourse)")
    }

    private func mealColor(_ type: MealType) -> Color {
        switch type {
        case .breakfast: return Color(hex: "FF9F43")
        case .morningSnack: return Color.ncPrimary
        case .lunch: return Color(hex: "E17055")
        case .afternoonSnack: return Color(hex: "FDCB6E")
        }
    }
}

// MARK: - Preview
#Preview {
    TodayMenuCard()
        .environment(DataManager.shared)
        .padding()
        .background(Color.ncBackground)
}
