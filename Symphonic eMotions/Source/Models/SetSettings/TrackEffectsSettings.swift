//
//  TrackEffectsSettings.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 18/07/2023.
//

import Foundation
import OrderedCollections

class TrackEffectsSettings: Identifiable {
    var id: Int { index }
    var index: Int
    var name: String
    var effectType: InstrumentsSet.Track.Effect.EffectType
    var parameters: OrderedDictionary<Int, ParameterSettings>

    init(
        index: Int,
        name: String,
        effectType: InstrumentsSet.Track.Effect.EffectType,
        parameters: OrderedDictionary<Int, ParameterSettings>
    ) {
        self.index = index
        self.name = name
        self.effectType = effectType
        self.parameters = parameters
    }

    static func effectValueRanges(effectType: InstrumentsSet.Track.Effect.EffectType) -> [ValueAndRange] {
        let ite = InstrumentsSet.Track.Effect()
        let valueAndRange = ite.effectParameterValues(effectType: effectType)

        return valueAndRange
    }
}
