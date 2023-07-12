//
//  HighPassFilterEffect.swift
//  Symphonic eMotions Intern
//
//  Created by Frans-Jan Wind on 06/10/2022.
//

import Foundation
import AudioKit

class HighPassFiltereffect: AudioProcessingEffect {
    
    var hpfCutoffFrequency: ValueAndRange
    var hpfResonance: ValueAndRange
    
    weak var node: Node?
    
    init(
        hpfCutoffFrequency: ValueAndRange,
        hpfResonance: ValueAndRange
    ) {
        self.hpfCutoffFrequency = hpfCutoffFrequency
        self.hpfResonance = hpfResonance
    }
    
    func chain(to input: Node) -> Node {
        let newNode = HighPassFilter(input, cutoffFrequency: hpfCutoffFrequency.value, resonance: hpfResonance.value)
        node = newNode
        return newNode
    }
    
    func apply(value: Double, with damperTarget: InstrumentsSet.Track.Part.DamperTarget) {
        
        switch damperTarget.parameter {
        case "hpfCutoffFrequency":
            let cf = RangeConverter.valueToRange(range: hpfCutoffFrequency.range, value: value, exponent: 2)
            (node as? HighPassFilter)?.cutoffFrequency = AUValue( cf )
        case "hpfCutoffFrequencyInverted":
            let cfi = RangeConverter.valueToRange(range: hpfCutoffFrequency.range, value: value, exponent: 0, inverted: true)
            (node as? HighPassFilter)?.cutoffFrequency = AUValue( cfi )
        case "hpfResonance":
            let r = RangeConverter.valueToRange(range: hpfResonance.range, value: value, exponent: 1)
            (node as? HighPassFilter)?.resonance = AUValue( r )
        default: break
        }
    }
    
    func apply<V>(keyPath: WritableKeyPath<HighPassFilter, V>, value: V) {
        var hpf = node as? HighPassFilter
        hpf?[keyPath: keyPath] = value
    }
    
    func valueAndRange(parameter: String) -> ValueAndRange?{
        switch parameter {
        case "hpfCutoffFrequency":
            return hpfCutoffFrequency
        case "hpfResonance":
            return hpfResonance
        default: return nil
        }
    }
}
