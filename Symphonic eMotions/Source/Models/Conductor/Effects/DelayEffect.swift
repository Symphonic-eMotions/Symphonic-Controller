//
//  DelayEffect.swift
//  eMotion
//
//  Created by Mihai Fratu on 01.10.2021.
//

import Foundation
import AudioKit

class DelayEffect: AudioProcessingEffect {
    
    let time: ValueAndRange
    let feedback: ValueAndRange
    let lowPassCutoff: ValueAndRange
    let dryWetMix: ValueAndRange
    
    weak var node: Node?
    
    init(time: ValueAndRange, feedback: ValueAndRange, lowPassCutoff: ValueAndRange, dryWetMix: ValueAndRange) {
        self.time = time
        self.feedback = feedback
        self.lowPassCutoff = lowPassCutoff
        self.dryWetMix = dryWetMix
    }
    
    func chain(to input: Node) -> Node {
        let newNode = Delay(input, time: time.value, feedback: feedback.value, lowPassCutoff: lowPassCutoff.value, dryWetMix: dryWetMix.value)
        node = newNode
        return newNode
    }
    
    func apply(value: Double, with damperTarget: InstrumentsSet.Track.Part.DamperTarget) {
        switch damperTarget.parameter {
        case "time":
            let t = RangeConverter.valueToRange(range: time.range, value: value, exponent: 1)
            (node as? Delay)?.time = AUValue( t )
        case "feedback":
            let f = RangeConverter.valueToRange(range: feedback.range, value: value, exponent: 1)
            (node as? Delay)?.feedback = AUValue( f )
        case "lowPassCutoff":
            let l = RangeConverter.valueToRange(range: lowPassCutoff.range, value: value, exponent: 2)
            (node as? Delay)?.lowPassCutoff = AUValue( l )
        case "dryWetMix":
            let d = RangeConverter.valueToRange(range: dryWetMix.range, value: value)
            (node as? Delay)?.dryWetMix = AUValue( d )
        default: break
        }
    }
    
    func valueAndRange(parameter: String) -> ValueAndRange? {
        switch parameter {
        case "time":
            return time
        case "feedback":
            return feedback
        case "lowPassCutoff":
            return lowPassCutoff
        case "dryWetMix":
            return dryWetMix
        default: return nil
        }
    }
}
