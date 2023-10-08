//
//  LowPassFilterEffect.swift
//  eMotion
//
//  Created by Mihai Fratu on 01.10.2021.
//

import Foundation
import AudioKit

class LowPassFilterEffect: AudioProcessingEffect {
    
    var cutOffFrequency: ValueAndRange
    var resonance: ValueAndRange
    
    weak var node: Node?
    
    init(
        cutOffFrequency: ValueAndRange,
        resonance: ValueAndRange
    ) {
        self.cutOffFrequency = cutOffFrequency
        self.resonance = resonance
    }
    
    func chain(to input: Node) -> Node {
        let newNode = LowPassFilter(
            input,
            cutoffFrequency: cutOffFrequency.value,
            resonance: resonance.value
        )
        node = newNode
        return newNode
    }
    
    func apply(value: Double, with damperTarget: InstrumentsSet.Track.Part.DamperTarget) {
        
//        print("apply LowPassFilterEffect \(damperTarget.parameter) \(value) to tange: \(cutOffFrequency.range)")
        
        switch damperTarget.parameter {
        case "cutoffFrequency":
            let cf = RangeConverter.valueToRange(range: cutOffFrequency.range, value: value, exponent: 2)
            
//            print("Converted: \(cf)")
            
            (node as? LowPassFilter)?.cutoffFrequency = AUValue( cf )
            
        case "resonance":
            let r = RangeConverter.valueToRange(range: resonance.range, value: value, exponent: 1)
            (node as? LowPassFilter)?.resonance = AUValue( r )
        default: break
        }
    }
    
    func apply<V>(keyPath: WritableKeyPath<LowPassFilter, V>, value: V) {
        var lowPassFilter = node as? LowPassFilter
        lowPassFilter?[keyPath: keyPath] = value
    }
    
    func valueAndRange(parameter: String) -> ValueAndRange?{
        switch parameter {
        case "cutoffFrequency":
            return cutOffFrequency
        case "resonance":
            return resonance
        default: return nil
        }
    }
}
