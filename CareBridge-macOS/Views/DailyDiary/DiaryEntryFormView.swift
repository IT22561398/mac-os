// NurseryConnect | DiaryEntryFormView.swift
// Full diary compliance: arrival/departure/milestone entry types,
// allergen confirmation for meals, child selector, auto-dismiss on save.
// EYFS 2024 Section 7.3 — all 9 diary log types.

import SwiftUI

// MARK: - Notification Name Extension
extension Notification.Name {
    static let entrySaved = Notification.Name("entrySaved")
}

// MARK: - DiaryEntryFormView
struct DiaryEntryFormView: View {
    @Bindable var viewModel: DiaryViewModel

    @Environment(DataManager.self) private var dataManager
    @Environment(\.dismiss) private var dismiss

    // Arrival/departure/milestone form fields live in DiaryViewModel

    // Allergen confirmation
    @State private var allergenConfirmed = false

    // Save animation
    @State private var showSaveSuccess = false
    @State private var saveScale: CGFloat = 1.0

    // Pre-selected child (locked when opened from child's diary)
    var preselectedChildId: UUID?
    var isChildLocked: Bool { preselectedChildId != nil }

    private var selectedChild: ChildProfile? {
        guard let id = viewModel.selectedChildId else { return nil }
        return dataManager.child(for: id)
    }

    private var isAllergenCheckRequired: Bool {
        guard let child = selectedChild else { return false }
        return viewModel.selectedEntryType == .meal && child.hasAllergies
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: Child Selector
                    childSelectorSection

                    // MARK: Entry Type Selector
                    entryTypeSelectorSection

                    // MARK: Type-Specific Form
                    typeSpecificForm

                    // MARK: Allergen Confirmation (Meals)
                    allergenConfirmationSection

                    // MARK: Save Button
                    saveButtonSection

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(Color.ncBackground)
            .navigationTitle(viewModel.selectedEntryType?.rawValue ?? "New Entry")
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                        viewModel.resetFormFields()
                    }
                    .accessibilityLabel("Cancel diary entry")
                }
            }
            .onAppear {
                viewModel.dataManager = dataManager
                if let pid = preselectedChildId {
                    viewModel.selectedChildId = pid
                }
            }
            .overlay {
                if showSaveSuccess {
                    saveSuccessOverlay
                }
            }
        }
    }

    // MARK: - Child Selector
    private var childSelectorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(icon: "person.fill", title: "Child", color: Color.ncPrimary)

            if isChildLocked, let child = selectedChild {
                // Locked child — static display
                HStack(spacing: 12) {
                    ChildAvatar(child: child, size: 44)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(child.displayName)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.ncText)
                        HStack(spacing: 4) {
                            Text(child.age)
                                .font(.system(size: 12))
                                .foregroundStyle(Color.ncTextSec)
                            if child.hasAllergies {
                                Circle()
                                    .fill(Color.ncSecondary)
                                    .frame(width: 6, height: 6)
                            }
                        }
                    }
                    Spacer()
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.ncTextSec)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.ncPrimary.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.ncPrimary.opacity(0.2), lineWidth: 1)
                )
            } else {
                // Scrollable avatar chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(dataManager.children.enumerated()), id: \.element.id) { index, child in
                            let isSelected = viewModel.selectedChildId == child.id
                            let hue = Double(index) / Double(max(dataManager.children.count, 1))

                            Button {
                                viewModel.selectedChildId = child.id
                                allergenConfirmed = false
                                HapticManager.selection()
                            } label: {
                                VStack(spacing: 5) {
                                    ZStack(alignment: .topTrailing) {
                                        AvatarView(
                                            initials: child.initials,
                                            color: Color(hue: hue, saturation: 0.5, brightness: 0.8),
                                            size: 44,
                                            hasAllergy: child.hasAllergies
                                        )

                                        if isSelected {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 13))
                                                .foregroundStyle(Color.ncPrimary)
                                                .background(Circle().fill(Color.ncCard).padding(-2))
                                                .offset(x: 4, y: -4)
                                        }
                                    }

                                    Text(child.displayName)
                                        .font(.system(size: 10, weight: .medium, design: .rounded))
                                        .foregroundStyle(isSelected ? Color.ncText : Color.ncTextSec)
                                        .lineLimit(1)

                                    Text(child.age)
                                        .font(.system(size: 9, weight: .regular))
                                        .foregroundStyle(Color.ncTextSec)
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(isSelected ? Color.ncPrimary.opacity(0.1) : Color.clear)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isSelected ? Color.ncPrimary : Color.clear, lineWidth: 2)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .frame(minWidth: 44, minHeight: 44)
                            .accessibilityLabel("Select \(child.displayName)")
                            .accessibilityAddTraits(isSelected ? .isSelected : [])
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }

    // MARK: - Entry Type Selector
    private var entryTypeSelectorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(icon: "square.grid.2x2.fill", title: "Entry Type", color: Color.ncWarning)

            let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(DiaryEntryType.allCases) { type in
                    let isSelected = viewModel.selectedEntryType == type
                    Button {
                        viewModel.selectedEntryType = type
                        allergenConfirmed = false
                        HapticManager.selection()
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: type.icon)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(isSelected ? .white : type.color)

                            Text(type.rawValue)
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundStyle(isSelected ? .white : Color.ncTextSec)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isSelected ? type.color : Color.white.opacity(0.04))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.clear : Color.white.opacity(0.08), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(minHeight: 44)
                    .accessibilityLabel("\(type.rawValue) entry type")
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
        }
    }

    // MARK: - Type-Specific Form
    @ViewBuilder
    private var typeSpecificForm: some View {
        switch viewModel.selectedEntryType {
        case .arrival:
            arrivalFormSection
        case .departure:
            departureFormSection
        case .activity:
            activityFormSection
        case .milestone:
            milestoneFormSection
        case .sleep:
            sleepFormSection
        case .nappy:
            nappyFormSection
        case .meal:
            mealFormSection
        case .wellbeing:
            wellbeingFormSection
        case .note:
            noteFormSection
        case nil:
            EmptyView()
        }
    }

    // MARK: - Arrival Form
    private var arrivalFormSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "arrow.down.circle.fill", title: "Arrival Details", color: Color.ncSuccess)

            DatePicker("Arrival Time", selection: $viewModel.arrivalTime, displayedComponents: .hourAndMinute)
                .font(.system(size: 14, weight: .medium))
                .padding(12)
                .frame(minHeight: 44)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.04)))
                .accessibilityLabel("Arrival time")

            formTextField(placeholder: "Dropped off by", text: $viewModel.droppedOffBy)

            moodSelectorView(selection: $viewModel.arrivalMood)

            formTextEditor(placeholder: "Parental notes (optional)", text: $viewModel.parentalNotes, height: 80)
        }
    }

    // MARK: - Departure Form
    private var departureFormSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "arrow.up.circle.fill", title: "Departure Details", color: Color.ncWarning)

            DatePicker("Departure Time", selection: $viewModel.departureTime, displayedComponents: .hourAndMinute)
                .font(.system(size: 14, weight: .medium))
                .padding(12)
                .frame(minHeight: 44)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.04)))
                .accessibilityLabel("Departure time")

            formTextField(placeholder: "Collected by", text: $viewModel.collectedBy)

            Toggle(isOn: $viewModel.authorisedCollector) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.ncWarning)
                    Text("Authorised Collector")
                        .font(.system(size: 14, weight: .medium))
                }
            }
            .padding(12)
            .frame(minHeight: 44)
            .tint(Color.ncPrimary)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.04)))
            .accessibilityLabel("Collector authorisation toggle")

            moodSelectorView(selection: $viewModel.departureMood)

            formTextEditor(placeholder: "Handover notes (optional)", text: $viewModel.handoverNotes, height: 80)
        }
    }

    // MARK: - Milestone Form
    private var milestoneFormSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "flag.fill", title: "Milestone", color: Color.ncAccent)

            DatePicker("Milestone Date", selection: $viewModel.milestoneDate, displayedComponents: .date)
                .font(.system(size: 14, weight: .medium))
                .padding(12)
                .frame(minHeight: 44)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.04)))
                .accessibilityLabel("Milestone date")

            eyfsAreaPicker(selection: $viewModel.milestoneEyfsArea)

            formTextEditor(placeholder: "Describe the milestone...", text: $viewModel.milestoneDescription, height: 110)
            formTextEditor(placeholder: "Next steps (optional)", text: $viewModel.milestoneNextSteps, height: 80)
        }
    }

    // MARK: - Activity Form
    private var activityFormSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "figure.play", title: "Activity Details", color: Color.ncPrimary)

            // Activity type
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ActivityType.allCases) { type in
                        let isSelected = viewModel.activityType == type
                        Button {
                            viewModel.activityType = type
                            HapticManager.selection()
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: type.icon)
                                    .font(.system(size: 12, weight: .bold))
                                Text(type.rawValue)
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(isSelected ? .white : type.color)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(minHeight: 44)
                            .background(
                                Capsule().fill(isSelected ? type.color : Color.white.opacity(0.06))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .accessibilityLabel(type.rawValue)
                    }
                }
            }

            // EYFS Area
            eyfsAreaPicker(selection: $viewModel.eyfsArea)

            // Duration
            HStack {
                Text("Duration")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.ncTextSec)
                Spacer()
                Stepper("\(viewModel.activityDuration) min", value: $viewModel.activityDuration, in: 5...120, step: 5)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.04)))

            // Notes
            formTextEditor(placeholder: "Describe the activity and any developmental observations...", text: $viewModel.activityNotes, height: 100)
        }
    }

    // MARK: - Sleep Form
    private var sleepFormSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "moon.zzz.fill", title: "Sleep Details", color: Color(hex: "A29BFE"))

            DatePicker("Start Time", selection: $viewModel.sleepStartTime, displayedComponents: .hourAndMinute)
                .font(.system(size: 14, weight: .medium))
                .padding(12)
                .frame(minHeight: 44)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.04)))
                .accessibilityLabel("Sleep start time")

            DatePicker("End Time", selection: $viewModel.sleepEndTime, displayedComponents: .hourAndMinute)
                .font(.system(size: 14, weight: .medium))
                .padding(12)
                .frame(minHeight: 44)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.04)))
                .accessibilityLabel("Sleep end time")

            // Sleep position
            VStack(alignment: .leading, spacing: 8) {
                Text("Position")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.ncTextSec)

                HStack(spacing: 10) {
                    ForEach(SleepPosition.allCases) { pos in
                        let isSelected = viewModel.sleepPosition == pos
                        Button {
                            viewModel.sleepPosition = pos
                            HapticManager.selection()
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: pos.icon)
                                    .font(.system(size: 16, weight: .bold))
                                Text(pos.rawValue)
                                    .font(.system(size: 10, weight: .semibold))
                            }
                            .foregroundStyle(isSelected ? .white : Color.ncTextSec)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(isSelected ? Color(hex: "A29BFE") : Color.white.opacity(0.04))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(minHeight: 44)
                        .accessibilityLabel("Sleep position: \(pos.rawValue)")
                    }
                }
            }

            formTextEditor(placeholder: "Any disturbances noted...", text: $viewModel.sleepNotes, height: 60)
        }
    }

    // MARK: - Nappy Form
    private var nappyFormSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "arrow.triangle.2.circlepath", title: "Nappy Change", color: Color.ncWarning)

            HStack(spacing: 10) {
                ForEach(NappyType.allCases) { type in
                    let isSelected = viewModel.nappyType == type
                    Button {
                        viewModel.nappyType = type
                        HapticManager.selection()
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: type.icon)
                                .font(.system(size: 16, weight: .bold))
                            Text(type.rawValue)
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundStyle(isSelected ? .white : type.color)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(isSelected ? type.color : Color.white.opacity(0.04))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(minHeight: 44)
                    .accessibilityLabel("Nappy type: \(type.rawValue)")
                }
            }

            Toggle(isOn: $viewModel.creamApplied) {
                HStack(spacing: 6) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.ncWarning)
                    Text("Cream Applied")
                        .font(.system(size: 14, weight: .medium))
                }
            }
            .padding(12)
            .frame(minHeight: 44)
            .tint(Color.ncPrimary)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.04)))
            .accessibilityLabel("Nappy cream applied toggle")

            formTextEditor(placeholder: "Any concerns noted...", text: $viewModel.nappyConcerns, height: 60)
        }
    }

    // MARK: - Meal Form
    private var mealFormSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "fork.knife", title: "Meal Details", color: Color(hex: "FF9F43"))

            // Meal type
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MealType.allCases) { type in
                        let isSelected = viewModel.mealType == type
                        Button {
                            viewModel.mealType = type
                            HapticManager.selection()
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: type.icon)
                                    .font(.system(size: 12, weight: .bold))
                                Text(type.rawValue)
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(isSelected ? .white : Color.ncText)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(minHeight: 44)
                            .background(
                                Capsule().fill(isSelected ? Color(hex: "FF9F43") : Color.white.opacity(0.06))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .accessibilityLabel(type.rawValue)
                    }
                }
            }

            // Food offered
            formTextField(placeholder: "Food offered", text: $viewModel.foodOffered)

            // Portion consumed
            VStack(alignment: .leading, spacing: 6) {
                Text("Amount Consumed")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.ncTextSec)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(PortionConsumed.allCases) { portion in
                            let isSelected = viewModel.portionConsumed == portion
                            Button {
                                viewModel.portionConsumed = portion
                                HapticManager.selection()
                            } label: {
                                VStack(spacing: 2) {
                                    Text(portion.emoji)
                                        .font(.system(size: 18))
                                    Text(portion.rawValue)
                                        .font(.system(size: 9, weight: .semibold))
                                        .foregroundStyle(isSelected ? .white : Color.ncTextSec)
                                }
                                .frame(width: 52, height: 52)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(isSelected ? portion.color : Color.white.opacity(0.04))
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .frame(minHeight: 44)
                            .accessibilityLabel("Amount consumed: \(portion.rawValue)")
                        }
                    }
                }
            }

            // Fluid intake
            HStack(spacing: 12) {
                Picker("Drink", selection: $viewModel.drinkType) {
                    ForEach(DrinkType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.menu)
                .frame(minHeight: 44)
                .accessibilityLabel("Drink type")

                Stepper("\(viewModel.drinkAmount) ml", value: $viewModel.drinkAmount, in: 0...500, step: 25)
                    .font(.system(size: 13, weight: .medium))
                    .frame(minHeight: 44)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.04)))
        }
    }

    // MARK: - Wellbeing Form
    private var wellbeingFormSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "heart.fill", title: "Wellbeing Check", color: Color.ncSecondary)

            // Period
            HStack(spacing: 10) {
                ForEach(WellbeingCheckTime.allCases) { time in
                    let isSelected = viewModel.wellbeingTime == time
                    Button {
                        viewModel.wellbeingTime = time
                        HapticManager.selection()
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: time.icon)
                                .font(.system(size: 16, weight: .bold))
                            Text(time.rawValue)
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundStyle(isSelected ? .white : Color.ncTextSec)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(isSelected ? Color.ncSecondary : Color.white.opacity(0.04))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(minHeight: 44)
                    .accessibilityLabel("Wellbeing period: \(time.rawValue)")
                }
            }

            // Mood
            moodSelectorView(selection: $viewModel.moodRating)

            formTextField(placeholder: "Physical appearance", text: $viewModel.physicalAppearance)
            formTextField(placeholder: "Social engagement observations", text: $viewModel.socialEngagement)
        }
    }

    // MARK: - Note Form
    private var noteFormSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "note.text", title: "General Note", color: Color.ncTextSecondary)
            formTextEditor(placeholder: "Write a note about this child...", text: $viewModel.generalNote, height: 120)
        }
    }

    // MARK: - Allergen Confirmation Section
    @ViewBuilder
    private var allergenConfirmationSection: some View {
        if isAllergenCheckRequired, let child = selectedChild {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color(hex: "E74C3C"))
                    Text("ALLERGEN ALERT — Please verify before saving")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: "E74C3C"))
                }

                // Allergen pills
                FlowLayout(spacing: 6) {
                    ForEach(child.allergies) { allergen in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(allergen.severity.color)
                                .frame(width: 8, height: 8)
                            Text(allergen.name)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                            Text("(\(allergen.severity.rawValue))")
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule().fill(allergen.severity.color.opacity(0.85))
                        )
                    }
                }

                // EpiPen warning
                if child.allergies.contains(where: { $0.severity == .anaphylactic }) {
                    HStack(spacing: 8) {
                        Text("🚨")
                            .font(.system(size: 16))
                        Text("EpiPen required — confirm it is accessible and not expired")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(hex: "E74C3C"))
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "E74C3C").opacity(0.15))
                    )
                }

                // Confirmation toggle
                Toggle(isOn: $allergenConfirmed) {
                    Text("I confirm this meal is safe for \(child.displayName) and contains none of the above allergens")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.ncText)
                }
                .tint(Color.ncPrimary)
                .padding(10)
                .frame(minHeight: 44)
                .accessibilityLabel("Confirm meal is allergen-safe for \(child.displayName)")
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: "E74C3C").opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(hex: "E74C3C").opacity(0.3), lineWidth: 1.5)
            )
        }
    }

    // MARK: - Save Button
    private var saveButtonSection: some View {
        let canSave = viewModel.selectedChildId != nil
            && viewModel.selectedEntryType != nil
            && (!isAllergenCheckRequired || allergenConfirmed)

        return Button {
            performSave()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 15, weight: .bold))
                Text("Save Entry")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        canSave
                            ? LinearGradient(colors: [Color.ncPrimary, Color(hex: "8B5CF6")], startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing)
                    )
            )
            .shadow(color: canSave ? Color.ncPrimary.opacity(0.4) : .clear, radius: 12, y: 4)
        }
        .disabled(!canSave)
        .accessibilityLabel("Save diary entry")
    }

    // MARK: - Save Logic with Auto-Dismiss
    private func performSave() {
        viewModel.dataManager = dataManager
        viewModel.saveEntry()

        // Check if save was successful (no toast warning)
        if viewModel.toast?.type == .success {
            HapticManager.success()

            showSaveSuccess = true
            saveScale = 0.5
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                saveScale = 1.2
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.2)) {
                    saveScale = 1.0
                }
            }

            // Post notification
            let childName = selectedChild?.displayName ?? "Child"
            let typeName = viewModel.selectedEntryType?.rawValue ?? "Entry"
            NotificationCenter.default.post(
                name: .entrySaved,
                object: "\(childName) · \(typeName)"
            )

            // Auto-dismiss after brief delay
            Task {
                try? await Task.sleep(nanoseconds: 600_000_000) // 0.6s
                await MainActor.run {
                    dismiss()
                }
            }
        }
    }

    // MARK: - Save Success Overlay
    private var saveSuccessOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(Color.ncSuccess)
                    .scaleEffect(saveScale)

                Text("Entry Saved")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
        .transition(.opacity)
    }

    // MARK: - Mood Selector
    private func moodSelectorView(selection: Binding<MoodRating?>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Mood")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.ncTextSec)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MoodRating.allCases) { mood in
                        let isSelected = selection.wrappedValue == mood
                        Button {
                            selection.wrappedValue = mood
                            HapticManager.selection()
                        } label: {
                            VStack(spacing: 3) {
                                Text(mood.emoji)
                                    .font(.system(size: 22))
                                Text(mood.rawValue)
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundStyle(isSelected ? .white : Color.ncTextSec)
                            }
                            .frame(width: 56, height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(isSelected ? mood.color : Color.white.opacity(0.04))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(minHeight: 44)
                        .accessibilityLabel("Mood: \(mood.rawValue)")
                    }
                }
            }
        }
    }

    // MARK: - EYFS Area Picker
    private func eyfsAreaPicker(selection: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("EYFS Area")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.ncTextSec)

            let areas = [
                ("C&L", "Communication & Language", Color.ncPrimary),
                ("PSED", "Personal, Social & Emotional", Color(hex: "A29BFE")),
                ("PD", "Physical Development", Color.ncSuccess),
                ("Lit", "Literacy", Color(hex: "74B9FF")),
                ("Maths", "Mathematics", Color.ncAccent),
                ("UTW", "Understanding the World", Color(hex: "6C5CE7")),
                ("EAD", "Expressive Arts & Design", Color(hex: "FD79A8"))
            ]

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(areas, id: \.0) { abbr, full, color in
                        let isSelected = selection.wrappedValue == full
                        Button {
                            selection.wrappedValue = full
                            HapticManager.selection()
                        } label: {
                            Text(abbr)
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(isSelected ? .white : color)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .frame(minHeight: 44)
                                .background(
                                    Capsule().fill(isSelected ? color : color.opacity(0.12))
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .accessibilityLabel("EYFS area: \(full)")
                    }
                }
            }
        }
    }

    // MARK: - Form Helpers
    private func sectionHeader(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(color)
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ncText)
        }
    }

    private func formTextField(placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .font(.system(size: 14))
            .padding(12)
            .frame(minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }

    private func formTextEditor(placeholder: String, text: Binding<String>, height: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            if text.wrappedValue.isEmpty {
                Text(placeholder)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.ncTextSec.opacity(0.5))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 14)
            }
            TextEditor(text: text)
                .font(.system(size: 14))
                .frame(height: height)
                .padding(6)
                .scrollContentBackground(.hidden)
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Flow Layout (for allergen pills)
struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let (size, _) = arrange(proposal: proposal, subviews: subviews)
        return size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let (_, positions) = arrange(proposal: proposal, subviews: subviews)

        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + positions[index].x, y: bounds.minY + positions[index].y), proposal: proposal)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}

// MARK: - Preview
#Preview {
    DiaryEntryFormView(viewModel: DiaryViewModel())
        .environment(DataManager.shared)
}
