//
//  MixerEffect.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 20/07/2023.
//

import Foundation
import AudioKit

class MixerEffect: AudioProcessingEffect {
    
    var volume: ValueAndRange
    
    weak var node: Node?
    
    init(volume: ValueAndRange) {
        self.volume = volume
    }
    
    func chain(to input: Node) -> Node {
        let newNode = Mixer(input)
        newNode.volume = volume.value
        node = newNode
        return newNode
    }
    
    func apply(value: Double, with damperTarget: InstrumentsSet.Track.Part.DamperTarget) {
        switch damperTarget.parameter {
        case "volume":
            let vol = RangeConverter.valueToRange(range: volume.range, value: value, exponent: 2)
            (node as? Mixer)?.volume = AUValue(vol)
        default: break
        }
    }
    
    func apply<V>(keyPath: WritableKeyPath<Mixer, V>, value: V) {
        var mixer = node as? Mixer
        mixer?[keyPath: keyPath] = value
    }
    
    func valueAndRange(parameter: String) -> ValueAndRange?{
        switch parameter {
        case "volume":
            return volume
        default: return nil
        }
    }
}

