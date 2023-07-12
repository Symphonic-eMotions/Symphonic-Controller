//
//  DynamicRangeCompressorEffect.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 02/09/2022.
//

import Foundation
import AudioKit
import SoundpipeAudioKit

class DynamicRangeCompressorEffect: AudioProcessingEffect {
    
    var drcAttackDuration: ValueAndRange
    var drcReleaseDuration: ValueAndRange
    var drcRatio: ValueAndRange
    var drcTreshold: ValueAndRange
    
    weak var node: Node?
    
    init(
        drcAttackDuration: ValueAndRange,
        drcReleaseDuration: ValueAndRange,
        drcRatio: ValueAndRange,
        drcTreshold: ValueAndRange
    ) {
        self.drcAttackDuration =  drcAttackDuration
        self.drcReleaseDuration = drcReleaseDuration
        self.drcRatio = drcRatio
        self.drcTreshold = drcTreshold
    }
    
    func chain(to input: Node) -> Node {
        let newNode = DynamicRangeCompressor(
            input,
            ratio: drcRatio.value,
            threshold: drcTreshold.value,
            attackDuration: drcAttackDuration.value,
            releaseDuration: drcReleaseDuration.value
        )
        
        node = newNode
        return newNode
    }
    
    func apply(value: Double, with damperTarget: InstrumentsSet.Track.Part.DamperTarget) {
        switch damperTarget.parameter {
        case "drcAttackDuration":
            let ad = RangeConverter.valueToRange(range: drcAttackDuration.range, value: value)
            (node as? DynamicRangeCompressor)?.attackDuration = AUValue( ad )
        case "drcReleaseDuration":
            let dur = RangeConverter.valueToRange(range: drcReleaseDuration.range, value: value)
            (node as? DynamicRangeCompressor)?.releaseDuration = AUValue( dur )
        case "drcRatio":
            let r = RangeConverter.valueToRange(range: drcRatio.range, value: value)
            (node as? DynamicRangeCompressor)?.ratio = AUValue( r )
        case "drcTreshold":
            let t = RangeConverter.valueToRange(range: drcTreshold.range, value: value)
            (node as? DynamicRangeCompressor)?.threshold = AUValue( t)
        default: break
        }
    }
    
    func apply<V>(keyPath: WritableKeyPath<DynamicRangeCompressor, V>, value: V){
        var dynamicRangeCompressor = node as? DynamicRangeCompressor
        dynamicRangeCompressor?[keyPath: keyPath] = value
    }
    
    func valueAndRange(parameter: String) -> ValueAndRange? {
        switch parameter {
        case "drcAttackDuration":
            return drcAttackDuration
        case "drcReleaseDuration":
            return drcReleaseDuration
        case "drcRatio":
            return drcRatio
        case "drcTreshold":
            return drcTreshold
        default: return nil
        }
    }
}
