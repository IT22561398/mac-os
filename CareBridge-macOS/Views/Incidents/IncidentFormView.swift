// NurseryConnect | IncidentFormView.swift
// Auto-stamped date/time, Ofsted escalation banner, same-day reminder,
// integrated body map, and RIDDOR compliance. EYFS 2024 Section 7.4.

import SwiftUI

// MARK: - IncidentFormView
struct IncidentFormView: View {
    @Bindable var viewModel: IncidentViewModel

    @Environment(DataManager.self) private var dataManager
    @Environment(\.dismiss) private var dismiss

    @State private var showSafeguardingAlert = false
    @State private var showSaveSuccess = false
    @State private var saveScale: CGFloat = 1.0

    private var incidentDateTime: Date {
        viewModel.editingIncident?.dateTime ?? Date()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: Auto-Stamped Date/Time (Non-Editable)
                    dateTimeSection

                    // MARK: Child Selector
                    childSelectorSection

                    // MARK: Category Selector
                    categorySelectorSection

                    // MARK: Ofsted Escalation Banner
                    ofstedBannerSection

                    // MARK: Location
                    locationSection

                    // MARK: Description
                    descriptionSection

                    // MARK: Immediate Action
                    actionTakenSection

                    // MARK: Body Map
                    bodyMapSection

                    // MARK: Witnesses
                    witnessesSection

                    // MARK: Same-Day Reminder
                    sameDayReminderCard

                    // MARK: Validation Errors
                    validationErrorsSection

                    // MARK: Save Button
                    saveButtonSection

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(Color.ncBackground)
            .navigationTitle(viewModel.editingIncident != nil ? "Edit Incident" : "New Incident")
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                        viewModel.resetForm()
                    }
                    .accessibilityLabel("Cancel incident form")
                }
            }
            .alert("EYFS Safeguarding Procedure", isPresented: $showSafeguardingAlert) {
                Button("Understood", role: .cancel) { }
            } message: {
                Text("Under the Children Act 1989 and EYFS 2024:\n\n1. Inform your Designated Safeguarding Lead (DSL) immediately\n2. Record all observations factually\n3. Do not investigate — this is the role of social services\n4. Notify Ofsted within 14 days if required\n5. Maintain strict confidentiality\n\nContact your DSL: Claire Johnson (Setting Manager)")
            }
            .overlay {
                if showSaveSuccess {
                    saveSuccessOverlay
                }
            }
        }
    }

    // MARK: - Date/Time Section (Non-Editable for consistency)
    private var dateTimeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(icon: "clock.fill", title: "Date & Time", color: Color.ncPrimary)

            HStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.ncTextSec)

                VStack(alignment: .leading, spacing: 2) {
                    Text(incidentDateTime.fullDateTimeString)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.ncText)
                    Text(viewModel.editingIncident == nil
                         ? "Auto-stamped (cannot be changed)"
                         : "Original incident time (locked)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.ncTextSec)
                        .italic()
                }

                Spacer()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .accessibilityLabel("Incident time auto-stamped, cannot be edited per EYFS requirements")
        }
    }

    // MARK: - Child Selector
    private var childSelectorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(icon: "person.fill", title: "Child", color: Color.ncPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(dataManager.children) { child in
                        let isSelected = viewModel.selectedChildId == child.id
                        Button {
                            viewModel.selectedChildId = child.id
                            HapticManager.selection()
                        } label: {
                            VStack(spacing: 6) {
                                ZStack(alignment: .topTrailing) {
                                    ChildAvatar(child: child, size: 48)

                                    if isSelected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 14))
                                            .foregroundStyle(Color.ncPrimary)
                                            .background(Circle().fill(Color.ncCard).frame(width: 16, height: 16))
                                            .offset(x: 4, y: -4)
                                    }
                                }

                                Text(child.displayName)
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundStyle(isSelected ? Color.ncText : Color.ncTextSec)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 10)
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

    // MARK: - Category Selector
    private var categorySelectorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(icon: "tag.fill", title: "Category", color: Color.ncWarning)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                ForEach(IncidentCategory.allCases) { cat in
                    let isSelected = viewModel.category == cat
                    Button {
                        viewModel.category = cat
                        HapticManager.selection()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: cat.icon)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(isSelected ? .white : cat.color)

                            Text(cat.rawValue)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(isSelected ? .white : Color.ncText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .frame(minHeight: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isSelected ? cat.color : Color.white.opacity(0.04))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.clear : Color.white.opacity(0.08), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel("\(cat.rawValue) category")
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
        }
    }

    // MARK: - Ofsted Escalation Banner
    @ViewBuilder
    private var ofstedBannerSection: some View {
        if viewModel.category == .safeguardingConcern || viewModel.category == .medicalIncident {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(hex: "E74C3C"))
                    Text("Safeguarding Alert")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: "E74C3C"))
                }

                Text("This incident may require Ofsted notification within 14 days. Contact your Designated Safeguarding Lead (DSL) immediately.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.ncText)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    showSafeguardingAlert = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 12))
                        Text("View EYFS Safeguarding Procedure")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(Color(hex: "E74C3C"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .frame(minHeight: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "E74C3C").opacity(0.5), lineWidth: 1)
                    )
                }
                .accessibilityLabel("View EYFS safeguarding procedure")
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: "E74C3C").opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(hex: "E74C3C").opacity(0.2), lineWidth: 1)
            )
        }
    }

    // MARK: - Location
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(icon: "mappin.circle.fill", title: "Location", color: Color.ncWarning)
            formTextField("Where did the incident occur?", text: $viewModel.location)
        }
    }

    // MARK: - Description
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(icon: "doc.text.fill", title: "Description (min 10 characters)", color: Color(hex: "A29BFE"))
            formTextEditor(text: $viewModel.description, height: 120)

            if !viewModel.description.isEmpty {
                Text("\(viewModel.description.count) characters")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(viewModel.description.count >= 10 ? Color.ncSuccess : Color.ncWarning)
            }
        }
    }

    // MARK: - Action Taken
    private var actionTakenSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(icon: "cross.case.fill", title: "Immediate Action Taken", color: Color.ncSecondary)
            formTextEditor(text: $viewModel.immediateActionTaken, height: 100)
        }
    }

    // MARK: - Body Map
    private var bodyMapSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(icon: "figure.stand", title: "Body Map (tap to mark injury)", color: Color(hex: "FB7185"))
            BodyMapView(
                markers: $viewModel.bodyMapMarkers,
                currentSide: $viewModel.bodyMapSide
            )
        }
    }

    // MARK: - Witnesses
    private var witnessesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                sectionHeader(icon: "person.2.fill", title: "Witnesses", color: Color(hex: "74B9FF"))
                Spacer()
                Button {
                    viewModel.addWitnessField()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.ncPrimary)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Add witness")
            }

            ForEach(viewModel.witnesses.indices, id: \.self) { index in
                HStack(spacing: 8) {
                    formTextField("Witness name", text: $viewModel.witnesses[index])

                    if viewModel.witnesses.count > 1 {
                        Button {
                            viewModel.removeWitness(at: index)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(Color.ncSecondary)
                                .frame(width: 44, height: 44)
                        }
                        .accessibilityLabel("Remove witness \(index + 1)")
                    }
                }
            }
        }
    }

    // MARK: - Same-Day Reminder
    private var sameDayReminderCard: some View {
        HStack(spacing: 10) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.ncPrimary)

            Text("Reminder: Under EYFS, parents must be notified of this incident today.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.ncText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.ncPrimary.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.ncPrimary.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Validation Errors
    @ViewBuilder
    private var validationErrorsSection: some View {
        let errors = viewModel.formErrors
        if !errors.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(errors, id: \.self) { error in
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.ncSecondary)
                        Text(error)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.ncSecondary)
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.ncSecondary.opacity(0.08))
            )
        }
    }

    // MARK: - Save Button
    private var saveButtonSection: some View {
        Button {
            viewModel.dataManager = dataManager
            viewModel.saveIncident()
            if viewModel.isFormValid {
                showSaveSuccess = true
                saveScale = 0.5
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    saveScale = 1.2
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.2)) {
                        saveScale = 1.0
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    dismiss()
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 15, weight: .bold))
                Text(viewModel.editingIncident != nil ? "Update Incident" : "Submit Incident Report")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        viewModel.isFormValid
                            ? LinearGradient(colors: [Color.ncPrimary, Color(hex: "8B5CF6")], startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing)
                    )
            )
            .shadow(color: viewModel.isFormValid ? Color.ncPrimary.opacity(0.4) : .clear, radius: 12, y: 4)
        }
        .disabled(!viewModel.isFormValid)
        .accessibilityLabel("Submit incident report")
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

                Text("Incident Submitted")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
        .transition(.opacity)
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

    private func formTextField(_ placeholder: String, text: Binding<String>) -> some View {
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

    private func formTextEditor(text: Binding<String>, height: CGFloat) -> some View {
        TextEditor(text: text)
            .font(.system(size: 14))
            .frame(height: height)
            .padding(8)
            .scrollContentBackground(.hidden)
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

// MARK: - Preview
#Preview {
    IncidentFormView(viewModel: IncidentViewModel())
        .environment(DataManager.shared)
}
