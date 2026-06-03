// NurseryConnect | BodyMapMarkerDetailSheet.swift
// Full-screen sheet for viewing a single body map marker in detail.
// Shows large body diagram with highlighted zone and pulsing marker dot.
// Read-only — RIDDOR 2013 and EYFS 2024 compliant.

import SwiftUI

// MARK: - BodyMapMarkerDetailSheet
struct BodyMapMarkerDetailSheet: View {
    let marker: BodyMapMarker
    let markerIndex: Int
    let incidentId: UUID
    let incidentDate: Date

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: Large Body Diagram
                    largeDiagramSection

                    // MARK: Marker Detail Card
                    markerInfoCard

                    // MARK: Compliance Note
                    complianceNote

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(Color.ncBackground)
            .navigationTitle("Injury Location")
            
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.ncPrimary)
                    .accessibilityLabel("Dismiss marker detail")
                }
            }
        }
    }

    // MARK: - Large Diagram Section
    private var largeDiagramSection: some View {
        VStack(spacing: 8) {
            Text(marker.side.rawValue.uppercased() + " VIEW")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ncTextSec)
                .tracking(1.5)

            GeometryReader { geo in
                let size = geo.size

                ZStack {
                    // Body fill
                    HumanBodyShape()
                        .fill(Color.white.opacity(0.05))

                    // Body outline
                    HumanBodyShape()
                        .stroke(Color.white.opacity(0.25), lineWidth: 1.5)

                    // Zone highlight
                    if let zone = findZone() {
                        let actualRect = BodyRegionZone.zoneRect(zone.rect, in: size)
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "FB7185").opacity(0.35))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(hex: "FB7185"), lineWidth: 2)
                            )
                            .frame(width: actualRect.width, height: actualRect.height)
                            .position(x: actualRect.midX, y: actualRect.midY)
                    }

                    // Pulsing marker dot
                    MarkerDotView(
                        number: markerIndex + 1,
                        color: Color(hex: "FB7185")
                    )
                    .scaleEffect(1.3)
                    .position(
                        x: marker.xPercent * size.width,
                        y: marker.yPercent * size.height
                    )
                }
            }
            .frame(height: 380)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "1E2235"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
    }

    // MARK: - Marker Info Card
    private var markerInfoCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 14) {
                // Numbered coral circle
                ZStack {
                    Circle()
                        .fill(Color(hex: "FB7185"))
                        .frame(width: 36, height: 36)
                    Text("\(markerIndex + 1)")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(regionName)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.ncText)
                    Text("\(marker.side.rawValue) view")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.ncTextSec)
                }

                Spacer()

                StatusBadge(
                    text: marker.side.rawValue,
                    color: Color(hex: "FB7185"),
                    size: .small
                )
            }

            if !marker.label.isEmpty {
                Divider().opacity(0.2)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Notes")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.ncTextSec)

                    Text(marker.label)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.ncText)
                        .italic()
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.ncCard)
                .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    // MARK: - Compliance Note
    private var complianceNote: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.ncPrimary)
                Text("RIDDOR Compliance Record")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.ncPrimary)
            }

            Text("Recorded at \(incidentDate.fullDateTimeString). Part of RIDDOR incident report \(incidentId.uuidString.prefix(8)).")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(Color.ncTextSec)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.ncPrimary.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.ncPrimary.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Helpers
    private var regionName: String {
        let zones = marker.side == .front
            ? BodyRegionZone.frontZones
            : BodyRegionZone.backZones

        if let zone = zones.first(where: { z in
            z.rect.contains(CGPoint(x: marker.xPercent, y: marker.yPercent))
        }) {
            return zone.region.displayName
        }
        return "Body Region"
    }

    private func findZone() -> BodyRegionZone? {
        let zones = marker.side == .front
            ? BodyRegionZone.frontZones
            : BodyRegionZone.backZones

        return zones.first { z in
            z.rect.contains(CGPoint(x: marker.xPercent, y: marker.yPercent))
        }
    }
}

// MARK: - Preview
#Preview {
    BodyMapMarkerDetailSheet(
        marker: BodyMapMarker(
            side: .front,
            xPercent: 0.40,
            yPercent: 0.78,
            label: "Grazed left knee — minor abrasion"
        ),
        markerIndex: 0,
        incidentId: UUID(),
        incidentDate: Date()
    )
}
