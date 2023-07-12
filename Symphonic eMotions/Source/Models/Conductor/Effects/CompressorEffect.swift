//
//  CompressorEffect.swift
//  eMotion
//
//  Created by Frans-Jan Wind on 10/10/2021.
//

import Foundation
import AudioKit
import SoundpipeAudioKit

class CompressorEffect: AudioProcessingEffect {
    
    let threshold: ValueAndRange
    let headRoom: ValueAndRange
    let attackTime: ValueAndRange
    let releaseTime: ValueAndRange
    let masterGain: ValueAndRange
    
    weak var node: Node?
    
    init(threshold: ValueAndRange, headRoom: ValueAndRange, attackTime: ValueAndRange, releaseTime: ValueAndRange, masterGain: ValueAndRange) {
        self.threshold = threshold
        self.headRoom = headRoom
        self.attackTime = attackTime
        self.releaseTime = releaseTime
        self.masterGain = masterGain
    }
    
    func chain(to input: Node) -> Node {
        let newNode = Compressor(input, threshold: threshold.value, headRoom: headRoom.value, attackTime: attackTime.value, releaseTime: releaseTime.value, masterGain: masterGain.value )
        node = newNode
        return newNode
    }
    
    func apply(value: Double, with damperTarget: InstrumentsSet.Track.Part.DamperTarget) {
        switch damperTarget.parameter {
        case "threshold":
            let th = RangeConverter.valueToRange(range: threshold.range, value: value)
            (node as? Compressor)?.threshold = AUValue( th )
        case "headRoom":
            let hr =  RangeConverter.valueToRange(range: headRoom.range, value: value)
            (node as? Compressor)?.headRoom = AUValue( hr )
        case "attackTime":
            let at = RangeConverter.valueToRange(range: attackTime.range, value: value)
            (node as? Compressor)?.attackTime = AUValue( at )
        case "releaseTime":
            let rt = RangeConverter.valueToRange(range: releaseTime.range, value: value)
            (node as? Compressor)?.releaseTime = AUValue( rt )
        case "masterGain":
            let mg = RangeConverter.valueToRange(range: masterGain.range, value: value)
            (node as? Compressor)?.masterGain = AUValue( mg )
        default: break
        }
    }
    
    func valueAndRange(parameter: String) -> ValueAndRange? {
        switch parameter {
        case "threshold":
            return threshold
        case "headRoom":
            return headRoom
        case "attackTime":
            return attackTime
        case "releaseTime":
            return releaseTime
        case "masterGain":
            return masterGain
        default: return nil
        }
    }
}
