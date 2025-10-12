//
//  PartControlsPane.swift
//  eMotion
//
//  Created by Frans-Jan Wind on 12/10/2025.
//


import SwiftUI
import OrderedCollections

struct PartControlsPane: View {
    @ObservedObject var setInfoModel: SetInfoModel

    @State private var active: PartSelection? = nil
    @State private var rampUp: Double = 0.5
    @State private var rampDown: Double = 0.5
    
    @State private var suppressSliderWrites = false
    
    private var tracks: OrderedDictionary<String, TrackSettings> { setInfoModel.tracksValue }


    var body: some View {
        VStack(spacing: 10) {

            // 1) Knoppen per part (horizontaal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(tracks), id: \.key) { (trackId, track) in
                        let parts = Array(track.parts)
                        HStack(spacing: 6) {
                            ForEach(parts, id: \.key) { (partId, part) in
                                Button {
                                    // selecteer + init sliders
                                    active = PartSelection(trackId: trackId, partId: partId)

                                    let curr = setInfoModel.currentRamps(for: trackId, partId: partId)
                                    
                                    suppressSliderWrites = true
                                    
                                    rampUp = curr.up
                                    rampDown = curr.down
                                    
                                    // kleine defer om programmatic set af te ronden
                                    DispatchQueue.main.async { suppressSliderWrites = false }
                                    
                                    DebugLog.d("UI SELECT \(trackId)#\(partId) set sliders up=\(curr.up) down=\(curr.down)")

                                    
                                } label: {
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(track.instrumentColor)
                                            .frame(width: 10, height: 10)
                                        Text(part.partName)
                                            .font(.footnote.weight(.medium))
                                            .lineLimit(1)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .background(active?.partId == partId ? .thinMaterial : .ultraThinMaterial)
                                    .clipShape(Capsule())
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }

            // 2) Inline editor + feedback (toon alleen wanneer er een selectie is)
            if let selection = active {
                editorCard(selection: selection)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .onAppear {
            guard active == nil else { return }
            guard let (firstTrackId, firstTrack) = tracks.elements.first,
                  let (firstPartId, _) = firstTrack.parts.elements.first else { return }

            let sel = PartSelection(trackId: firstTrackId, partId: firstPartId)
            active = sel

            let curr = setInfoModel.currentRamps(for: sel.trackId, partId: sel.partId)

            suppressSliderWrites = true
            rampUp = curr.up
            rampDown = curr.down
            DispatchQueue.main.async { suppressSliderWrites = false }
        }
    }

    @ViewBuilder
    private func editorCard(selection: PartSelection) -> some View {
        let trackId = selection.trackId
        let partId = selection.partId
        let partName = setInfoModel.tracksValue[trackId]?.parts[partId]?.partName ?? partId

        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(partName).font(.headline)
                Spacer()
                Button {
                    withAnimation { active = nil }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }

            // ✅ Live grafische feedback voor déze part
            ValueFeedback(
                value: .init(
                    get: { Float(setInfoModel.conductor.latestPartValues[partId] ?? 0) },
                    set: { _ in }
                ),
                title: "Beweging"
            )
            .frame(height: 24)

            // Sliders (Up/Down) met directe persist + conductor update
            sliderRow("Ramp Up", value: $rampUp) { new in
                setInfoModel.updateRamp(for: trackId, partId: partId, up: new)
            }
            sliderRow("Ramp Down", value: $rampDown) { new in
                setInfoModel.updateRamp(for: trackId, partId: partId, down: new)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    @ViewBuilder
    private func sliderRow(_ title: String, value: Binding<Double>, onChange: @escaping (Double)->Void) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title).font(.subheadline.weight(.medium))
                Spacer()
                Text(String(format: "%.2f", value.wrappedValue))
                    .font(.footnote.monospacedDigit())
                    .foregroundColor(.secondary)
            }
            Slider(value: value, in: 0...1, step: 0.01)
                .onChange(of: value.wrappedValue) { new in
                    // alleen schrijven bij user input
                    if !suppressSliderWrites {
                        DebugLog.d("UI WRITE \(title) \(active?.trackId ?? "?")#\(active?.partId ?? "?") = \(new)")
                        onChange(new)
                    }
                }
        }
    }
}

private struct PartSelection: Identifiable, Equatable {
    let trackId: String
    let partId: String
    var id: String { "\(trackId)#\(partId)" }
}
