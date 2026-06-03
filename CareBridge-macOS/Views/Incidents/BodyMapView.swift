// NurseryConnect | BodyMapView.swift
// Interactive body map with SwiftUI Path-drawn silhouette, zone highlights,
// and front/back toggle. Used in IncidentFormView for marking injury locations.
// Compliant with RIDDOR 2013, EYFS 2024, and Apple HIG.

import SwiftUI

// MARK: - Body Region Zone Data
/// Normalized CGRect zones (0.0–1.0) for each BodyRegion.
/// Used to translate region names into pixel-level highlights on the body diagram.
struct BodyRegionZone {
    let region: BodyRegion
    let rect: CGRect
    let view: BodyMapSide

    /// All front-facing zone definitions
    static let frontZones: [BodyRegionZone] = [
        BodyRegionZone(region: .head,      rect: CGRect(x: 0.35, y: 0.00, width: 0.30, height: 0.13), view: .front),
        BodyRegionZone(region: .face,      rect: CGRect(x: 0.35, y: 0.08, width: 0.30, height: 0.09), view: .front),
        BodyRegionZone(region: .neck,      rect: CGRect(x: 0.38, y: 0.13, width: 0.24, height: 0.06), view: .front),
        BodyRegionZone(region: .chest,     rect: CGRect(x: 0.22, y: 0.19, width: 0.56, height: 0.15), view: .front),
        BodyRegionZone(region: .abdomen,   rect: CGRect(x: 0.25, y: 0.34, width: 0.50, height: 0.13), view: .front),
        BodyRegionZone(region: .leftArm,   rect: CGRect(x: 0.02, y: 0.19, width: 0.20, height: 0.28), view: .front),
        BodyRegionZone(region: .rightArm,  rect: CGRect(x: 0.78, y: 0.19, width: 0.20, height: 0.28), view: .front),
        BodyRegionZone(region: .leftHand,  rect: CGRect(x: 0.02, y: 0.47, width: 0.18, height: 0.09), view: .front),
        BodyRegionZone(region: .rightHand, rect: CGRect(x: 0.80, y: 0.47, width: 0.18, height: 0.09), view: .front),
        BodyRegionZone(region: .leftLeg,   rect: CGRect(x: 0.25, y: 0.50, width: 0.22, height: 0.36), view: .front),
        BodyRegionZone(region: .rightLeg,  rect: CGRect(x: 0.53, y: 0.50, width: 0.22, height: 0.36), view: .front),
        BodyRegionZone(region: .leftFoot,  rect: CGRect(x: 0.23, y: 0.86, width: 0.22, height: 0.09), view: .front),
        BodyRegionZone(region: .rightFoot, rect: CGRect(x: 0.52, y: 0.86, width: 0.22, height: 0.09), view: .front),
    ]

    /// All back-facing zone definitions
    static let backZones: [BodyRegionZone] = [
        BodyRegionZone(region: .head,      rect: CGRect(x: 0.35, y: 0.00, width: 0.30, height: 0.13), view: .back),
        BodyRegionZone(region: .neck,      rect: CGRect(x: 0.38, y: 0.13, width: 0.24, height: 0.06), view: .back),
        BodyRegionZone(region: .back,      rect: CGRect(x: 0.22, y: 0.19, width: 0.56, height: 0.30), view: .back),
        BodyRegionZone(region: .leftArm,   rect: CGRect(x: 0.02, y: 0.19, width: 0.20, height: 0.28), view: .back),
        BodyRegionZone(region: .rightArm,  rect: CGRect(x: 0.78, y: 0.19, width: 0.20, height: 0.28), view: .back),
        BodyRegionZone(region: .leftHand,  rect: CGRect(x: 0.02, y: 0.47, width: 0.18, height: 0.09), view: .back),
        BodyRegionZone(region: .rightHand, rect: CGRect(x: 0.80, y: 0.47, width: 0.18, height: 0.09), view: .back),
        BodyRegionZone(region: .leftLeg,   rect: CGRect(x: 0.25, y: 0.50, width: 0.22, height: 0.36), view: .back),
        BodyRegionZone(region: .rightLeg,  rect: CGRect(x: 0.53, y: 0.50, width: 0.22, height: 0.36), view: .back),
        BodyRegionZone(region: .leftFoot,  rect: CGRect(x: 0.23, y: 0.86, width: 0.22, height: 0.09), view: .back),
        BodyRegionZone(region: .rightFoot, rect: CGRect(x: 0.52, y: 0.86, width: 0.22, height: 0.09), view: .back),
    ]

    /// Convert normalized rect to actual pixel rect within a panel size
    static func zoneRect(_ zone: CGRect, in size: CGSize) -> CGRect {
        CGRect(
            x: zone.origin.x * size.width,
            y: zone.origin.y * size.height,
            width: zone.size.width * size.width,
            height: zone.size.height * size.height
        )
    }
}

// MARK: - BodyRegion Enum
/// All body regions that can be marked in RIDDOR incident reports.
enum BodyRegion: String, CaseIterable, Codable, Identifiable {
    case head, face, neck
    case leftArm, rightArm, leftHand, rightHand
    case chest, abdomen, back
    case leftLeg, rightLeg, leftFoot, rightFoot

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .head: return "Head"
        case .face: return "Face"
        case .neck: return "Neck"
        case .leftArm: return "Left Arm"
        case .rightArm: return "Right Arm"
        case .leftHand: return "Left Hand"
        case .rightHand: return "Right Hand"
        case .chest: return "Chest"
        case .abdomen: return "Abdomen"
        case .back: return "Back"
        case .leftLeg: return "Left Leg"
        case .rightLeg: return "Right Leg"
        case .leftFoot: return "Left Foot"
        case .rightFoot: return "Right Foot"
        }
    }

    /// Which body view (front/back) this region naturally belongs to
    var defaultView: BodyMapSide {
        self == .back ? .back : .front
    }
}

// MARK: - Human Body Shape (SwiftUI Path)
/// Draws a recognizable human body silhouette using SwiftUI Path commands.
/// No external images, UIKit, or SF Symbols used for the body outline.
struct HumanBodyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Head — ellipse at top center
        let headW = w * 0.26
        let headH = h * 0.12
        let headX = (w - headW) / 2
        let headY = h * 0.01
        path.addEllipse(in: CGRect(x: headX, y: headY, width: headW, height: headH))

        // Neck — rectangle below head
        let neckW = w * 0.12
        let neckH = h * 0.04
        let neckX = (w - neckW) / 2
        let neckY = headY + headH - h * 0.01
        path.addRect(CGRect(x: neckX, y: neckY, width: neckW, height: neckH))

        // Torso — rounded rectangle
        let torsoW = w * 0.42
        let torsoH = h * 0.30
        let torsoX = (w - torsoW) / 2
        let torsoY = neckY + neckH - h * 0.005
        path.addRoundedRect(
            in: CGRect(x: torsoX, y: torsoY, width: torsoW, height: torsoH),
            cornerSize: CGSize(width: 8, height: 8)
        )

        // Left Arm — rectangle on left side
        let armW = w * 0.12
        let armH = h * 0.30
        let leftArmX = torsoX - armW + w * 0.02
        let armY = torsoY + h * 0.02
        path.addRoundedRect(
            in: CGRect(x: leftArmX, y: armY, width: armW, height: armH),
            cornerSize: CGSize(width: 5, height: 5)
        )

        // Right Arm — rectangle on right side
        let rightArmX = torsoX + torsoW - w * 0.02
        path.addRoundedRect(
            in: CGRect(x: rightArmX, y: armY, width: armW, height: armH),
            cornerSize: CGSize(width: 5, height: 5)
        )

        // Left Leg — rectangle below torso
        let legW = w * 0.16
        let legH = h * 0.34
        let legGap = w * 0.02
        let leftLegX = (w / 2) - legW - (legGap / 2)
        let legY = torsoY + torsoH - h * 0.01
        path.addRoundedRect(
            in: CGRect(x: leftLegX, y: legY, width: legW, height: legH),
            cornerSize: CGSize(width: 6, height: 6)
        )

        // Right Leg
        let rightLegX = (w / 2) + (legGap / 2)
        path.addRoundedRect(
            in: CGRect(x: rightLegX, y: legY, width: legW, height: legH),
            cornerSize: CGSize(width: 6, height: 6)
        )

        // Left Foot
        let footW = w * 0.17
        let footH = h * 0.05
        let leftFootX = leftLegX - w * 0.01
        let footY = legY + legH - h * 0.005
        path.addRoundedRect(
            in: CGRect(x: leftFootX, y: footY, width: footW, height: footH),
            cornerSize: CGSize(width: 4, height: 4)
        )

        // Right Foot
        let rightFootX = rightLegX
        path.addRoundedRect(
            in: CGRect(x: rightFootX, y: footY, width: footW, height: footH),
            cornerSize: CGSize(width: 4, height: 4)
        )

        return path
    }
}

// MARK: - Pulsing Marker Dot
/// A coral circle with numbered label, pulsing animation, and white border.
/// Used to indicate exact injury locations on the body map diagram.
struct MarkerDotView: View {
    let number: Int
    let color: Color

    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: 16, height: 16)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 1.5)
                )
                .shadow(color: color.opacity(0.5), radius: 5)

            Text("\(number)")
                .font(.system(size: 8, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                scale = 1.2
            }
        }
        .accessibilityLabel("Injury marker \(number)")
    }
}

// MARK: - Body Diagram Panel (Read-Only)
/// Renders the body silhouette with zone highlights and marker dots.
/// Used in IncidentDetailView to show recorded injury locations.
struct BodyDiagramPanel: View {
    let side: BodyMapSide
    let markers: [BodyMapMarker]
    let panelHeight: CGFloat

    var filteredMarkers: [BodyMapMarker] {
        markers.filter { $0.side == side }
    }

    var zones: [BodyRegionZone] {
        side == .front ? BodyRegionZone.frontZones : BodyRegionZone.backZones
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(side.rawValue.uppercased())
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.5))
                .tracking(1.2)

            GeometryReader { geo in
                let size = geo.size

                ZStack {
                    // Body silhouette fill
                    HumanBodyShape()
                        .fill(Color.white.opacity(0.05))

                    // Body silhouette outline
                    HumanBodyShape()
                        .stroke(Color.white.opacity(0.25), lineWidth: 1.5)

                    // Zone highlights for markers present on this side
                    ForEach(filteredMarkers) { marker in
                        if let zone = zoneForMarker(marker) {
                            let actualRect = BodyRegionZone.zoneRect(zone.rect, in: size)
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(hex: "FB7185").opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color(hex: "FB7185"), lineWidth: 1.5)
                                )
                                .frame(width: actualRect.width, height: actualRect.height)
                                .position(
                                    x: actualRect.midX,
                                    y: actualRect.midY
                                )
                        }
                    }

                    // Marker dots
                    ForEach(Array(filteredMarkers.enumerated()), id: \.element.id) { index, marker in
                        let globalIndex = markers.firstIndex(where: { $0.id == marker.id }) ?? index
                        MarkerDotView(number: globalIndex + 1, color: Color(hex: "FB7185"))
                            .position(
                                x: marker.xPercent * size.width,
                                y: marker.yPercent * size.height
                            )
                    }
                }
            }
            .frame(height: panelHeight)
        }
    }

    private func zoneForMarker(_ marker: BodyMapMarker) -> BodyRegionZone? {
        let allZones = side == .front ? BodyRegionZone.frontZones : BodyRegionZone.backZones
        // Find the zone that contains the marker position
        return allZones.first { zone in
            zone.rect.contains(CGPoint(x: marker.xPercent, y: marker.yPercent))
        }
    }
}

// MARK: - Interactive Body Map View
/// Used in IncidentFormView for marking injury locations.
/// Supports front/back toggle and tap-to-place markers.
struct BodyMapView: View {
    @Binding var markers: [BodyMapMarker]
    @Binding var currentSide: BodyMapSide

    @State private var markerNotes: String = ""
    @State private var showNotesSheet: Bool = false
    @State private var pendingMarker: BodyMapMarker?

    // Current zones for the selected side, accessible across the view body
    private var currentZones: [BodyRegionZone] {
        currentSide == .front ? BodyRegionZone.frontZones : BodyRegionZone.backZones
    }

    var body: some View {
        VStack(spacing: 16) {
            // MARK: Side Toggle
            HStack(spacing: 0) {
                ForEach(BodyMapSide.allCases) { side in
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentSide = side
                        }
                        HapticManager.selection()
                    } label: {
                        Text(side.rawValue)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(currentSide == side ? .white : Color.ncTextSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(
                                currentSide == side
                                    ? Color.ncPrimary
                                    : Color.clear
                            )
                    }
                    .accessibilityLabel("\(side.rawValue) view")
                    .accessibilityAddTraits(currentSide == side ? .isSelected : [])
                }
            }
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 4)

            // MARK: Body Diagram (Interactive)
            GeometryReader { geo in
                let size = geo.size

                ZStack {
                    // Body fill
                    HumanBodyShape()
                        .fill(Color.white.opacity(0.05))

                    // Body outline
                    HumanBodyShape()
                        .stroke(Color.white.opacity(0.25), lineWidth: 1.5)

                    ForEach(currentZones, id: \.region) { zone in
                        let actualRect = BodyRegionZone.zoneRect(zone.rect, in: size)
                        let isSelected = markers.contains { m in
                            m.side == currentSide && zone.rect.contains(CGPoint(x: m.xPercent, y: m.yPercent))
                        }

                        RoundedRectangle(cornerRadius: 6)
                            .fill(isSelected ? Color(hex: "FB7185").opacity(0.2) : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(
                                        isSelected
                                            ? Color(hex: "FB7185")
                                            : Color.white.opacity(0.08),
                                        lineWidth: isSelected ? 1.5 : 0.5
                                    )
                            )
                            .frame(width: actualRect.width, height: actualRect.height)
                            .position(x: actualRect.midX, y: actualRect.midY)
                    }

                    // Existing markers
                    let sideMarkers = markers.filter { $0.side == currentSide }
                    ForEach(Array(sideMarkers.enumerated()), id: \.element.id) { index, marker in
                        let globalIdx = markers.firstIndex(where: { $0.id == marker.id }) ?? index
                        MarkerDotView(number: globalIdx + 1, color: Color(hex: "FB7185"))
                            .position(
                                x: marker.xPercent * size.width,
                                y: marker.yPercent * size.height
                            )
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { location in
                    let xPct = location.x / size.width
                    let yPct = location.y / size.height

                    // Find the zone tapped
                    let tappedZone = currentZones.first { zone in
                        zone.rect.contains(CGPoint(x: xPct, y: yPct))
                    }

                    if let zone = tappedZone {
                        // Check if already marked
                        if let existingIndex = markers.firstIndex(where: { m in
                            m.side == currentSide && zone.rect.contains(CGPoint(x: m.xPercent, y: m.yPercent))
                        }) {
                            markers.remove(at: existingIndex)
                            HapticManager.lightTap()
                        } else {
                            let marker = BodyMapMarker(
                                side: currentSide,
                                xPercent: xPct,
                                yPercent: yPct,
                                label: ""
                            )
                            pendingMarker = marker
                            markerNotes = ""
                            showNotesSheet = true
                            HapticManager.mediumTap()
                        }
                    }
                }
                .accessibilityLabel("Body map diagram showing \(currentSide.rawValue) view. Tap on a body region to mark an injury.")
            }
            .frame(height: 280)

            // MARK: Selected Regions Chip List
            if !markers.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Marked Regions")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.ncTextSec)

                    FlowLayoutChips(markers: markers, onRemove: { marker in
                        markers.removeAll { $0.id == marker.id }
                        HapticManager.lightTap()
                    })
                }
                .padding(.horizontal, 4)
            }
        }
        .sheet(isPresented: $showNotesSheet) {
            MarkerNotesSheet(
                notes: $markerNotes,
                onSave: {
                    if var marker = pendingMarker {
                        marker.label = markerNotes
                        markers.append(marker)
                        pendingMarker = nil
                    }
                    showNotesSheet = false
                },
                onCancel: {
                    pendingMarker = nil
                    showNotesSheet = false
                }
            )
            .presentationDetents([.height(280)])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Marker Notes Sheet
/// Presented when a user taps a body region to add notes about the injury.
struct MarkerNotesSheet: View {
    @Binding var notes: String
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Describe the injury at this location")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.ncText)
                    .multilineTextAlignment(.center)

                TextEditor(text: $notes)
                    .font(.system(size: 14))
                    .frame(height: 100)
                    .padding(8)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )

                Button {
                    onSave()
                } label: {
                    Text("Add Marker")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.ncPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .accessibilityLabel("Add injury marker")
            }
            .padding(20)
            .navigationTitle("Injury Notes")
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                        .accessibilityLabel("Cancel adding marker")
                }
            }
        }
    }
}

// MARK: - Flow Layout Chips
/// Displays body map markers as removable chips in a wrapping flow layout.
struct FlowLayoutChips: View {
    let markers: [BodyMapMarker]
    let onRemove: (BodyMapMarker) -> Void

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 8) {
            ForEach(Array(markers.enumerated()), id: \.element.id) { index, marker in
                HStack(spacing: 8) {
                    // Numbered circle
                    ZStack {
                        Circle()
                            .fill(Color(hex: "FB7185"))
                            .frame(width: 22, height: 22)
                        Text("\(index + 1)")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }

                    // Region name + side
                    Text(regionNameForMarker(marker) + " · " + marker.side.rawValue)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.ncText)

                    if !marker.label.isEmpty {
                        Text("— \(marker.label)")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(Color.ncTextSec)
                            .italic()
                            .lineLimit(1)
                    }

                    Spacer()

                    // Remove button
                    Button {
                        onRemove(marker)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.ncTextSecondary.opacity(0.6))
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Remove marker \(index + 1)")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private func regionNameForMarker(_ marker: BodyMapMarker) -> String {
        let zones = marker.side == .front
            ? BodyRegionZone.frontZones
            : BodyRegionZone.backZones

        if let zone = zones.first(where: { z in
            z.rect.contains(CGPoint(x: marker.xPercent, y: marker.yPercent))
        }) {
            return zone.region.displayName
        }
        return "Unknown Region"
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color(hex: "12131A").ignoresSafeArea()
        BodyMapView(
            markers: .constant([
                BodyMapMarker(side: .front, xPercent: 0.40, yPercent: 0.78, label: "Grazed left knee")
            ]),
            currentSide: .constant(.front)
        )
        .padding()
    }
}

