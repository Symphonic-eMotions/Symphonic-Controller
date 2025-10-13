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

            // 1) Knoppen per part (horizontaal) + "Stil" links
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {

                    // 🔴 Stil-knop
                    MuteButton(setInfoModel: setInfoModel) {
                        if setInfoModel.isMuted {
                            setInfoModel.unmuteStreams()
                        } else {
                            setInfoModel.muteAllStreams()
                            withAnimation { active = nil }
                        }
                    }

                    // 🟢 Parts
                    ForEach(tracks.elements, id: \.key) { trackElement in
                        let trackId: String = trackElement.key
                        let track: TrackSettings = trackElement.value

                        HStack(spacing: 8) {
                            ForEach(track.parts.elements, id: \.key) { partElement in
                                let partId: String = partElement.key
                                let part = partElement.value
                                let selected: Bool = (active?.partId == partId && active?.trackId == trackId && !setInfoModel.isMuted)

                                PartButton(
                                    title: part.partName,
                                    color: track.instrumentColor,
                                    isSelected: selected
                                ) {
                                    if setInfoModel.isMuted { setInfoModel.unmuteStreams() }

                                    // selecteer + init sliders
                                    let sel = PartSelection(trackId: trackId, partId: partId)
                                    active = sel

                                    let curr = setInfoModel.currentRamps(for: trackId, partId: partId)
                                    suppressSliderWrites = true
                                    rampUp = curr.up
                                    rampDown = curr.down
                                    DispatchQueue.main.async { suppressSliderWrites = false }

                                    DebugLog.d("UI SELECT \(trackId)#\(partId) set sliders up=\(curr.up) down=\(curr.down)")
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }

            // 2) Inline editor + feedback (alleen tonen als er een selectie is en NIET gemute)
            if let selection = active, !setInfoModel.isMuted {
                editorCard(selection: selection)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .onAppear {
            guard active == nil else { return }
            guard let firstTrack = tracks.elements.first,
                  let firstPart  = firstTrack.value.parts.elements.first else { return }

            let sel = PartSelection(trackId: firstTrack.key, partId: firstPart.key)
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

private struct MuteButton: View {
    @ObservedObject var setInfoModel: SetInfoModel
    let action: () -> Void

    private var bgStyle: AnyShapeStyle {
        setInfoModel.isMuted ? AnyShapeStyle(Color.red) : AnyShapeStyle(.ultraThinMaterial)
    }

    var body: some View {
        Button(action: action) {
            Text("Stil")
                .font(.callout.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(minHeight: 36)
                .background(bgStyle, in: Capsule())
                .foregroundStyle(setInfoModel.isMuted ? Color.white : Color.primary)
                .overlay(
                    Capsule()
                        .strokeBorder(setInfoModel.isMuted ? Color.red.opacity(0.7) : Color.secondary.opacity(0.2), lineWidth: 1)
                )
        }
        .accessibilityIdentifier("muteAllButton")
        .buttonStyle(.plain)
    }
}

private struct PartButton: View {
    let title: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    private var bgStyle: AnyShapeStyle {
        isSelected ? AnyShapeStyle(Color.green) : AnyShapeStyle(.ultraThinMaterial)
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 14, height: 14)
                Text(title)
                    .font(.callout.weight(.semibold))
                    .lineLimit(1)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(minHeight: 36)
            .background(bgStyle, in: Capsule())
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? Color.green.opacity(0.7) : Color.secondary.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
