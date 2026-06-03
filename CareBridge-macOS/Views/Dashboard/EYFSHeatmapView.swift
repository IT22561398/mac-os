// EYFSHeatmapView.swift
// NurseryConnect — Setting Manager (macOS)
// EYFS Coverage Heatmap using Swift Charts RectangleMark

import SwiftUI
import Charts

struct EYFSHeatmapView: View {
    @Environment(SettingManagerDashboardViewModel.self) private var viewModel
    
    struct HeatmapCell: Identifiable {
        let id = UUID()
        let childName: String
        let area: String
        let count: Int
    }
    
    var body: some View {
        let heatmap = viewModel.eyfsHeatmapData()
        let cells = generateCells(from: heatmap)
        
        VStack(alignment: .leading, spacing: 8) {
            Chart(cells) { cell in
                RectangleMark(
                    x: .value(ManagerText.Charts.eyfsAreaAxisLabel, cell.area),
                    y: .value(ManagerText.Charts.childAxisLabel, cell.childName)
                )
                .foregroundStyle(cellColor(count: cell.count))
                .cornerRadius(4)
                .annotation(position: .overlay) {
                    if cell.count > 0 {
                        Text("\(cell.count)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white)
                    } else {
                        Image(systemName: "exclamationmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.ncSecondary)
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .font(.caption2)
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .font(.caption)
                }
            }
            .frame(height: CGFloat(heatmap.children.count) * 40 + 40)
            
            // Legend
            HStack(spacing: 16) {
                legendItem(color: .ncSecondary.opacity(0.3), label: ManagerText.Heatmap.zeroGap)
                legendItem(color: .ncWarning, label: ManagerText.Heatmap.oneTwo)
                legendItem(color: .ncPrimary, label: ManagerText.Heatmap.threeFour)
                legendItem(color: .ncSuccess, label: ManagerText.Heatmap.fivePlus)
            }
            .font(.caption2)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: ManagerConstants.cardCornerRadius)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        )
    }
    
    private func generateCells(from heatmap: (children: [ChildProfile], areas: [EYFSArea], data: [[Int]])) -> [HeatmapCell] {
        var cells: [HeatmapCell] = []
        
        for (childIndex, child) in heatmap.children.enumerated() {
            for (areaIndex, area) in heatmap.areas.enumerated() {
                let count = childIndex < heatmap.data.count && areaIndex < heatmap.data[childIndex].count
                    ? heatmap.data[childIndex][areaIndex]
                    : 0
                
                cells.append(HeatmapCell(
                    childName: child.firstName,
                    area: area.shortName,
                    count: count
                ))
            }
        }
        
        return cells
    }
    
    private func cellColor(count: Int) -> Color {
        switch count {
        case 0: return .ncSecondary.opacity(0.3)
        case 1...2: return .ncWarning
        case 3...4: return .ncPrimary
        default: return .ncSuccess
        }
    }
    
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 14, height: 14)
            Text(label)
                .foregroundStyle(.secondary)
        }
    }
}
