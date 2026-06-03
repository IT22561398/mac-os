// ReportGeneratorView.swift
// NurseryConnect — Setting Manager (macOS)
// Report generation with date range picker, type selection, NL language compliance,
// and text export

import SwiftUI
import NaturalLanguage

struct ReportGeneratorView: View {
    @Environment(ReportViewModel.self) private var reportVM
    
    var body: some View {
        @Bindable var vm = reportVM
        VStack(spacing: 0) {
            // Controls
            reportControls
            
            Divider()
            
            // Report output
            if vm.generatedReport.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundStyle(.tertiary)
                    
                    Text(ManagerText.Reports.emptyPrompt)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Language compliance warning
                        if !vm.nonEnglishEntries.isEmpty {
                            complianceWarning
                        }
                        
                        // Success Card
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(.ncSuccess)
                            
                            Text("Report Generated Successfully")
                                .font(.title3.weight(.semibold))
                            
                            Text("A beautiful, paginated PDF has been created. You can preview it in the panel to the right, or download it immediately.")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            Button {
                                let filename = "\(vm.reportType.rawValue.replacingOccurrences(of: " ", with: "_"))_\(Date().shortDateString).pdf"
                                PDFGenerator.savePDF(from: vm.generatedReport, defaultFileName: filename)
                            } label: {
                                Label("Download PDF", systemImage: "arrow.down.doc.fill")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.ncPrimary)
                            .controlSize(.large)
                            .padding(.top, 10)
                        }
                        .padding(30)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(nsColor: .controlBackgroundColor))
                        )
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                        .padding(.top, 40)
                    }
                    .padding(20)
                }
            }
        }
        .navigationTitle(ManagerText.Reports.title)
    }
    
    // MARK: - Controls
    private var reportControls: some View {
        @Bindable var vm = reportVM
        return VStack(spacing: 12) {
            HStack(spacing: 16) {
                // Date range
                VStack(alignment: .leading, spacing: 4) {
                    Text(ManagerText.Reports.startDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    DatePicker("", selection: $vm.startDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .frame(width: 120)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(ManagerText.Reports.endDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    DatePicker("", selection: $vm.endDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .frame(width: 120)
                }
                
                // Report type
                VStack(alignment: .leading, spacing: 4) {
                    Text(ManagerText.Reports.reportType)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Picker(ManagerText.Reports.reportType, selection: $vm.reportType) {
                        ForEach(ReportType.allCases) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                }
                
                Spacer()
                
                // Generate button
                Button {
                    vm.generateReport()
                } label: {
                    Label(ManagerText.Reports.generateButton, systemImage: "doc.text.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(.ncPrimary)
                .controlSize(.large)
                .disabled(vm.isGenerating)
                
                // Note: PDF Download is now in the success card below
            }
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor))
    }
    
    // MARK: - Compliance Warning
    private var complianceWarning: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.ncWarning)
                Text(ManagerText.Reports.complianceTitle)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.ncWarning)
            }
            
            Text(ManagerText.Reports.complianceMessage(reportVM.nonEnglishEntries.count))
                .font(.caption)
                .foregroundStyle(.secondary)
            
            ForEach(reportVM.nonEnglishEntries.prefix(3), id: \.id) { entry in
                HStack(spacing: 4) {
                    Image(systemName: "doc.text")
                        .font(.caption2)
                        .foregroundStyle(.ncWarning)
                    Text(entry.notes.prefix(60) + "...")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ncWarning.opacity(0.08))
                .stroke(.ncWarning.opacity(0.3), lineWidth: 1)
        )
    }
}
