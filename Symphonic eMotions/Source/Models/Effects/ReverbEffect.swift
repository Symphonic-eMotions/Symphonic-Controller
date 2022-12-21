//
//  ReverbEffect.swift
//  Symphonic eMotions Intern
//
//  Created by Frans-Jan Wind on 06/10/2022.
//

import Foundation
import AudioKit
import AVFAudio

class Reverbeffect: EffectProtocol {
    
    let reverbDryWetMix: ValueAndRange
    let reverbPreset: ValueAndRange
    
    weak var node: Node?
    
    init(
        reverbDryWetMix: ValueAndRange,
        reverbPreset: ValueAndRange
    ) {
        self.reverbDryWetMix = reverbDryWetMix
        self.reverbPreset = reverbPreset
    }
    
    func chain(to input: Node) -> Node {
        let newNode = Reverb(input)
        node = newNode
        return newNode
    }
    
    func intToAVAudioUnitReverbPreset(preset: Int) -> AVAudioUnitReverbPreset {
        
        switch preset {
            case 0: return .smallRoom
            case 1: return .mediumRoom
            case 2: return .largeRoom
            case 3: return .mediumHall
            case 4: return .largeHall
            case 5: return .plate
            case 6: return .mediumChamber
            case 7: return .largeChamber
            case 8: return .cathedral
            case 9: return .largeRoom2
            case 10: return .mediumHall2
            case 11: return .mediumHall3
            case 12: return .largeHall2
            default: return .smallRoom
        }
    }
    
    func apply(value: Double, with damperTarget: InstrumentsSet.Track.Part.DamperTarget) {
        
        switch damperTarget.parameter {
            case "reverbDryWetMix":
                let reverbDryWetMix = RangeConverter.valueToRange(range: reverbDryWetMix.range, value: value)
                (node as? Reverb)?.dryWetMix = AUValue( reverbDryWetMix )
            case "reverbPreset":
                let reverbPreset = RangeConverter.valueToRange(range: reverbPreset.range, value: value)
                (node as? Reverb)?.loadFactoryPreset(intToAVAudioUnitReverbPreset(preset: Int(reverbPreset)))
            default: break
        }
    }
    
    func apply<V>(keyPath: WritableKeyPath<Reverb, V>, value: V) {
        var reverb = node as? Reverb
        reverb?[keyPath: keyPath] = value
    }
    
    func valueAndRange(parameter: String) -> ValueAndRange? {
        switch parameter {
        case "reverbDryWetMix":
            return reverbDryWetMix
        case "reverbPreset":
            return reverbPreset
        default: return nil
        }
    }
}
