//
//  CostelloReverbEffect.swift
//  eMotion
//
//  Created by Frans-Jan Wind on 07/10/2021.
//

import Foundation
import AudioKit
import SoundpipeAudioKit
import AudioKitEX

class CostelloReverbEffect: AudioProcessingEffect {
    
    let feedback: ValueAndRange
    let cutoffFrequency: ValueAndRange
    let dryWetMixer: ValueAndRange
    
    weak var nodeOne: Node?
    weak var node: Node?
    
    init(feedback: ValueAndRange, cutoffFrequency: ValueAndRange, dryWetMixer: ValueAndRange) {
        self.feedback = feedback
        self.cutoffFrequency = cutoffFrequency
        self.dryWetMixer = dryWetMixer
    }
    
    func chain(to input: Node) -> Node {
        let castelloReverb = CostelloReverb(input, feedback: feedback.value, cutoffFrequency: cutoffFrequency.value )
        let newNode = DryWetMixer(input, castelloReverb, balance: dryWetMixer.value)
        nodeOne = castelloReverb
        node = newNode
        return newNode
    }
    
    func apply(value: Double, with damperTarget: InstrumentsSet.Track.Part.DamperTarget) {
        switch damperTarget.parameter {
        case "feedbackCostello":
            let f = RangeConverter.valueToRange(range: feedback.range, value: value, exponent: 1)
            (nodeOne as? CostelloReverb)?.feedback = AUValue( f )
        case "cutoffFrequencyCostello":
            let c = RangeConverter.valueToRange(range: cutoffFrequency.range, value: value, exponent: 2)
            (nodeOne as? CostelloReverb)?.cutoffFrequency = AUValue( c )
        case "dryWetMixer":
            let d = RangeConverter.valueToRange(range: dryWetMixer.range, value: value)
            (node as? DryWetMixer)?.balance = AUValue( d )
        default: break
        }
    }
    
    func valueAndRange(parameter: String) -> ValueAndRange? {
        switch parameter {
        case "feedbackCostello":
            return feedback
        case "cutoffFrequencyCostello":
            return cutoffFrequency
        case "dryWetMixer":
            return dryWetMixer
        default: return nil
        }
    }
}
