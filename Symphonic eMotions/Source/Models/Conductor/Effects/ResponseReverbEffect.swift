//
//  ResponseReverbEffect.swift
//  eMotion
//
//  Created by Frans-Jan Wind on 09.06.2022.
//

import AudioKit

import AVFoundation
import SoundpipeAudioKit
import SwiftUI
import AudioKitEX
import CSoundpipeAudioKit

class ResponseReverbEffect: AudioProcessingEffect {
    
    var respReverbDuration: ValueAndRange
    let respDryWetMixer: ValueAndRange
    
    weak var nodeOne: Node?
    weak var node: Node?
    
    init(respReverbDuration: ValueAndRange,
         respDryWetMixer: ValueAndRange
    ) {
        self.respReverbDuration = respReverbDuration
        self.respDryWetMixer = respDryWetMixer
    }
    
    func chain(to input: Node) -> Node {
        let verb = FlatFrequencyResponseReverb(
            input,
            reverbDuration: respReverbDuration.value
        )
        let mix = DryWetMixer(input, verb, balance: respDryWetMixer.value)
        nodeOne = verb
        node = mix
        return mix
    }
    
    func apply(value: Double, with damperTarget: InstrumentsSet.Track.Part.DamperTarget) {
        switch damperTarget.parameter {
        case "reverbDuration":
            let rd = RangeConverter.valueToRange(range: respReverbDuration.range, value: value, exponent: 1)
            (nodeOne as? FlatFrequencyResponseReverb)?.reverbDuration = AUValue( rd )
        case "dryWetMixer":
            let b = RangeConverter.valueToRange(range: respDryWetMixer.range, value: value)
            (node as? DryWetMixer)?.balance = AUValue( b )
        default: break
        }
    }
    
    func apply<V>(keyPath: WritableKeyPath<FlatFrequencyResponseReverb, V>, value: V) {
        var lowPassFilter = node as? FlatFrequencyResponseReverb
        lowPassFilter?[keyPath: keyPath] = value
    }
    
    func valueAndRange(parameter: String) -> ValueAndRange? {
        switch parameter {
        case "reverbDuration":
            return respReverbDuration
        case "dryWetMixer":
            return respDryWetMixer
        default: return nil
        }
    }
}

