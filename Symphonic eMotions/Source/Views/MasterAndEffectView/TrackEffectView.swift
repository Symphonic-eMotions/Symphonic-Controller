//
//  TrackEffectView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 18/07/2023.
//

import OrderedCollections
import SwiftUI

struct TrackEffectView: View {
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings

    var trackId: String
    var trackEffectViewObject: [TrackEffect]
    @State var trackEffectState: [[Float]]

    @Binding var showTrackEffect: Bool

    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        showTrackEffect: Binding<Bool>

    ) {
        self.setInfoModel = setInfoModel
        self.trackId = trackId
        self.currentTrack = currentTrack
        _showTrackEffect = showTrackEffect
        trackEffectViewObject = TrackEffectsHelper.trackEffectViewObject(trackSettings: currentTrack)
        trackEffectState = TrackEffectsHelper.trackEffectsStateObject(viewObject: trackEffectViewObject)
    }

    var body: some View {
        return GeometryReader { geometry in
            VStack {
                ScrollView(.vertical) {
                    if trackEffectViewObject.isEmpty {
                        // Show something when trackEffectViewObject is empty
                        Text("No effects available")
                            .padding()
                    } else {
                        ForEach(Array(trackEffectViewObject.enumerated()), id: \.element) { index, effect in
                            // Stack per effect
                            ZStack {
                                // Background color effect
                                RoundedRectangle(cornerRadius: 7)
                                    .fill(Color(UIColor.darkGray))

                                VStack(alignment: .leading) {
                                    Text(effect.effectName)
                                        .font(.headline)
                                        .padding(.vertical)

                                    ForEach(Array(effect.parameters!.enumerated()), id: \.element) { i, parameter in
                                        HStack {
                                            Text("\(parameter.name)")

                                            Spacer()

                                            Text("\(parameter.range[0], specifier: parameter.range[0] >= 1000 ? "%.0f" : "%.2f") ")
                                                .frame(width: 100) // Set the width to fit 8 characters
                                                .padding(8) // Add some padding for the rounded corner background
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(Color.gray.opacity(0.2)) // You can adjust the color and opacity here
                                                )
                                            Text("\(parameter.range[1], specifier: "%.0f") ")
                                                .frame(width: 100) // Set the width to fit 8 characters
                                                .padding(8) // Add some padding for the rounded corner background
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(Color.gray.opacity(0.2)) // You can adjust the color and opacity here
                                                )
                                        }

                                        EffectSliderView(
                                            value: Binding(
                                                get: { self.trackEffectState[index][i] },
                                                set: { newVal in
                                                    // Set state for local binding
                                                    self.trackEffectState[index][i] = newVal

                                                    let dt = InstrumentsSet.Track.Part.DamperTarget(
                                                        trackId: currentTrack.trackId,
                                                        nodeType: .effect,
                                                        nodeName: effect.effectType,
                                                        parameter: parameter.type,
                                                        parameterRange: parameter.range,
                                                        parameterInversed: false,
                                                        midiData: nil,
                                                        nodeSettings: nil,
                                                        dampMode: nil
                                                    )

                                                    // Send to conductor for real time modification
                                                    setInfoModel.conductor.forwardEffect(
                                                        value: Double(newVal),
                                                        for: dt
                                                    )

                                                    // Store to disk in currentTrack
                                                    if let effect = currentTrack.effects[index],
                                                       let parameter = effect.parameters[i] {
                                                        let convertedValue = RangeConverter.valueToRange(
                                                            range: parameter.range,
                                                            value: Double(newVal)
                                                        )

                                                        // Store in object to disk
                                                        parameter.value = Double(convertedValue)
                                                    }
                                                }
                                            ),
                                            range: parameter.range
                                        )
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                }
                .padding()

                // Continue
                EMButton(action: {
                    showTrackEffect = false
                }, color: .green, isSolid: true) {
                    Text(NSLocalizedString("Close", comment: ""))
                }
                .frame(width: geometry.size.width * 0.333)
            }
            .onAppear {

                // Set damper target parameters to the state value
                // This overrides frame extractor 0 values

                // Loop through each PartSettings in currentTrack
                for part in currentTrack.parts.values {
                    // Extract nodeName and parameter from the current part
                    let nodeName = part.damperTarget.nodeName
                    let parameterType = part.damperTarget.parameter

                    // Search trackEffectViewObject for the matching effect
                    if let effect = trackEffectViewObject.first(where: { $0.effectType == nodeName }) {
                        // Find the matching parameter within the effect's parameters
                        if let parameter = effect.parameters?.first(where: { $0.type == parameterType }) {
                            // Now you have access to the matching parameter's value, name, and range
                            let value = parameter.value
                            let range = parameter.range

//                            print("Found matching value: \(value) for nodeName: \(nodeName) and parameterType: \(parameterType)")

                            let dt = InstrumentsSet.Track.Part.DamperTarget(
                                trackId: currentTrack.trackId,
                                nodeType: .effect,
                                nodeName: nodeName,
                                parameter: parameterType,
                                parameterRange: range,
                                parameterInversed: false,
                                midiData: nil,
                                nodeSettings: nil,
                                dampMode: nil
                            )

                            setInfoModel.conductor.forwardEffect(
                                value: value,
                                for: dt
                            )
                        }
                    }
                }
            }
        }
    }
}

struct EffectSliderView: View {
    @Binding var value: Float
    var range: [Double]

    init(value: Binding<Float>, range: [Double]) {
        _value = value
        self.range = range
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack {
                    let valueInRange = RangeConverter.rangeToValue(range: range, value: Double(value))

                    Text("\(valueInRange, specifier: range[1] >= 1000 ? "%.0f" : "%.2f")")
                        .frame(width: geometry.size.width * 0.16)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                        )

                    Slider(value: $value, in: 0 ... 1)
                        .foregroundColor(.accentColor)
                        .frame(width: geometry.size.width * 0.80)
                }
            }
        }
        .frame(height: 40.0)
    }
}
