//
//  ExpanderEffect.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 07/12/2022.
//

import Foundation
import AudioKit

class ExpanderEffect: AudioProcessingEffect {
    
    var expansionRatio: ValueAndRange
    var expansionThreshold: ValueAndRange
    var expanderAttackTime: ValueAndRange
    var expanderReleaseTime: ValueAndRange
    var expanderMasterGain: ValueAndRange
    
    weak var node: Node?
    
    init(
        expansionRatio: ValueAndRange,
        expansionThreshold: ValueAndRange,
        expanderAttackTime: ValueAndRange,
        expanderReleaseTime: ValueAndRange,
        expanderMasterGain: ValueAndRange
    ) {
        self.expansionRatio = expansionRatio
        self.expansionThreshold = expansionThreshold
        self.expanderAttackTime = expanderAttackTime
        self.expanderReleaseTime = expanderReleaseTime
        self.expanderMasterGain = expanderMasterGain
    }
    
    func chain(to input: Node) -> Node {
        let newNode = Expander(
            input,
            expansionRatio: expansionRatio.value,
            expansionThreshold: expansionThreshold.value,
            attackTime: expanderAttackTime.value,
            releaseTime: expanderReleaseTime.value,
            masterGain: expanderMasterGain.value
        )
        
        node = newNode
        return newNode
    }
    
    func apply(value: Double, with damperTarget: InstrumentsSet.Track.Part.DamperTarget) {
        switch damperTarget.parameter {
        case "expansionRatio":
            let a = RangeConverter.valueToRange(range: expansionRatio.range, value: value)
            (node as? Expander)?.expansionRatio = AUValue(a)
        case "expansionThreshold":
            let b = RangeConverter.valueToRange(range: expansionThreshold.range, value: value)
            (node as? Expander)?.expansionThreshold = AUValue(b)
        case "expanderAttackTime":
            let c = RangeConverter.valueToRange(range: expanderAttackTime.range, value: value)
            (node as? Expander)?.attackTime = AUValue(c)
        case "expanderReleaseTime":
            let d = RangeConverter.valueToRange(range: expanderReleaseTime.range, value: value)
            (node as? Expander)?.releaseTime = AUValue(d)
        case "expanderMasterGain":
            let e = RangeConverter.valueToRange(range: expanderMasterGain.range, value: value)
            (node as? Expander)?.masterGain = AUValue(e)
        default: break
        }
    }
    
    func apply<V>(keyPath: WritableKeyPath<Expander, V>, value: V){
        var expander = node as? Expander
        expander?[keyPath: keyPath] = value
    }
    
    func valueAndRange(parameter: String) -> ValueAndRange? {
        switch parameter {
        case "expansionRatio":
            return expansionRatio
        case "expansionThreshold":
            return expansionRatio
        case "expanderAttackTime":
            return expanderAttackTime
        case "expanderReleaseTime":
            return expanderReleaseTime
        case "expanderMasterGain":
            return expanderMasterGain
            default: return nil
        }
    }
}
