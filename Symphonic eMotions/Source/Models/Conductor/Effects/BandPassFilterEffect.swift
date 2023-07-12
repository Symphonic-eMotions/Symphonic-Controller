//
//  BandPassFilterEffect.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 27/05/2022.
//

import Foundation
import AudioKit

class BandPassFilterEffect: AudioProcessingEffect {
    
    var centerFrequency: ValueAndRange
    var bandwidth: ValueAndRange
    
    weak var node: Node?
    
    init(centerFrequency: ValueAndRange, bandwidth: ValueAndRange) {
        self.centerFrequency = centerFrequency
        self.bandwidth = bandwidth
    }
    
    func chain(to input: Node) -> Node {
        let newNode = BandPassFilter(input, centerFrequency: centerFrequency.value, bandwidth: bandwidth.value)
        node = newNode
        return newNode
    }
    
    func apply(value: Double, with damperTarget: InstrumentsSet.Track.Part.DamperTarget) {
        switch damperTarget.parameter {
        case "centerFrequency":
            let cf = RangeConverter.valueToRange(range: centerFrequency.range, value: value, exponent: 2)
            (node as? BandPassFilter)?.centerFrequency = AUValue( cf )
        case "bandwidth":
            let bw = RangeConverter.valueToRange(range: bandwidth.range, value: value, exponent: 1)
            (node as? BandPassFilter)?.bandwidth = AUValue( bw )
        default: break
        }
    }
    
    func apply<V>(keyPath: WritableKeyPath<BandPassFilter, V>, value: V) {
        var bandPassFilter = node as? BandPassFilter
        bandPassFilter?[keyPath: keyPath] = value
    }
    
    func valueAndRange(parameter: String) -> ValueAndRange?{
        switch parameter {
        case "centerFrequency":
            return centerFrequency
        case "bandwidth":
            return bandwidth
        default: return nil
        }
    }
}
