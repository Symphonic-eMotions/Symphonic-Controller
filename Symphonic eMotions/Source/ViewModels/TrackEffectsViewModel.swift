//
//  TrackEffectsViewModel.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 09/10/2023.
//

import Foundation

class TrackEffectsViewModel: ObservableObject {
    @Published var trackEffectViewObject: [TrackEffect] = []
    @Published var trackEffectState: [[Float]] = []

    func loadTrackEffectViewObject(trackSettings: TrackSettings) {
        var newTrackEffectViewObject: [TrackEffect] = []

        for (_, trackEffectSetting) in trackSettings.effects {
            var parameters: [Parameter] = []

            for (_, parameterSetting) in trackEffectSetting.parameters {
                let parameter = Parameter(
                    // FIXME: there's no type here
                    type: parameterSetting.name, // You'll need to decide how to map this
                    name: "Used as type: \(parameterSetting.name)",
                    value: parameterSetting.value,
                    range: parameterSetting.range
                )
                parameters.append(parameter)
            }

            let trackEffect = TrackEffect(
                effectType: trackEffectSetting.effectType.rawValue,
                effectName: trackEffectSetting.name,
                parameters: parameters
            )
            newTrackEffectViewObject.append(trackEffect)
        }

        trackEffectViewObject = newTrackEffectViewObject
    }

    func loadTrackEffectStateObject() {
        // your existing logic here, perhaps something like this
        var parametersPerEffect: [[Float]] = []
        if let max = trackEffectViewObject.map(\.parameters!.count).max() {
            for _ in trackEffectViewObject {
                parametersPerEffect.append(Array(repeating: 0.0, count: max))
            }
        }
        trackEffectState = parametersPerEffect
    }
}
