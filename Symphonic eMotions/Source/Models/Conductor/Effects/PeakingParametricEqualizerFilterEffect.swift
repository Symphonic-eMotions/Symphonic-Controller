//
//  PeakingParametricEqualizerFilterEffect.swift
//  Symphonic eMotions Intern
//
//  Created by Frans-Jan Wind on 06/10/2022.
//

import Foundation
import AudioKit
import SoundpipeAudioKit

class PeakingParametricEqualizerFilterEffect: AudioProcessingEffect {
        
    var ppefCenterFrequency: ValueAndRange
    var ppefGain: ValueAndRange
    var ppefQ: ValueAndRange
    
    weak var node: Node?
    
    init(
        ppefCenterFrequency: ValueAndRange,
        ppefGain: ValueAndRange,
        ppefQ: ValueAndRange
    ) {
        self.ppefCenterFrequency = ppefCenterFrequency
        self.ppefGain = ppefGain
        self.ppefQ = ppefQ
    }
    
    func chain(to input: Node) -> Node {
        let newNode = PeakingParametricEqualizerFilter(
            input,
            centerFrequency: ppefCenterFrequency.value,
            gain: ppefGain.value,
            q: ppefQ.value
        )
        
        node = newNode
        return newNode
    }
    
    func apply(value: Double, with damperTarget: InstrumentsSet.Track.Part.DamperTarget) {
        switch damperTarget.parameter {
        case "ppefCenterFrequency":
            let cf = RangeConverter.valueToRange(range: ppefCenterFrequency.range, value: value)
            (node as? PeakingParametricEqualizerFilter)?.centerFrequency = AUValue( cf )
        case "ppefGain":
            let g = RangeConverter.valueToRange(range: ppefGain.range, value: value)
            (node as? PeakingParametricEqualizerFilter)?.gain = AUValue( g )
        case "ppefQ":
            let q = RangeConverter.valueToRange(range: ppefQ.range, value: value)
            (node as? PeakingParametricEqualizerFilter)?.q = AUValue( q )
        default: break
        }
    }
    
    func apply<V>(keyPath: WritableKeyPath<PeakingParametricEqualizerFilter, V>, value: V){
        var ppef = node as? PeakingParametricEqualizerFilter
        ppef?[keyPath: keyPath] = value
    }
    
    func valueAndRange(parameter: String) -> ValueAndRange? {
        switch parameter {
        case "ppefCenterFrequency":
            return ppefCenterFrequency
        case "ppefGain":
            return ppefGain
        case "ppefQ":
            return ppefQ
        default: return nil
        }
    }
}
