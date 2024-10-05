//
//  PhaserEffect.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 06/07/2022.
//

import Foundation
import AudioKit
import SporthAudioKit
import SoundpipeAudioKit
import AudioKitEX

class PhaserEffect: AudioProcessingEffect {
    
    var phaserNotchMinimumFrequency: ValueAndRange
    var phaserNotchMaximumFrequency: ValueAndRange
    var phaserNotchWidth: ValueAndRange
    var phaserNotchFrequency: ValueAndRange
    var phaserVibratoMode: ValueAndRange
    var phaserDepth: ValueAndRange
    var phaserFeedback: ValueAndRange
    var phaserInverted: ValueAndRange
    var phaserLfoBPM: ValueAndRange
    let phaserDryWetMixer: ValueAndRange
    
    weak var nodeOne: Node?
    weak var node: Node?
    
    init(
        phaserNotchMinimumFrequency: ValueAndRange,
        phaserNotchMaximumFrequency: ValueAndRange,
        phaserNotchWidth: ValueAndRange,
        phaserNotchFrequency: ValueAndRange,
        phaserVibratoMode: ValueAndRange,
        phaserDepth: ValueAndRange,
        phaserFeedback: ValueAndRange,
        phaserInverted: ValueAndRange,
        phaserLfoBPM: ValueAndRange,
        phaserDryWetMixer: ValueAndRange
    ) {
        self.phaserNotchMinimumFrequency = phaserNotchMinimumFrequency
        self.phaserNotchMaximumFrequency = phaserNotchMaximumFrequency
        self.phaserNotchWidth = phaserNotchWidth
        self.phaserNotchFrequency = phaserNotchFrequency
        self.phaserVibratoMode = phaserVibratoMode
        self.phaserDepth = phaserDepth
        self.phaserFeedback = phaserFeedback
        self.phaserInverted = phaserInverted
        self.phaserLfoBPM = phaserLfoBPM
        self.phaserDryWetMixer = phaserDryWetMixer
    }
    
    func chain(to input: Node) -> Node {
        let phaser = Phaser(
            input,
            notchMinimumFrequency: phaserNotchMinimumFrequency.value,
            notchMaximumFrequency: phaserNotchMaximumFrequency.value,
            notchWidth: phaserNotchWidth.value,
            notchFrequency: phaserNotchFrequency.value,
            vibratoMode: phaserVibratoMode.value,
            depth: phaserDepth.value,
            feedback: phaserFeedback.value,
            inverted: phaserInverted.value,
            lfoBPM: phaserLfoBPM.value
        )
        let mix = DryWetMixer(input, phaser, balance: phaserDryWetMixer.value)
        nodeOne = phaser
        node = mix
        return mix
    }
    
    func apply(value: Double, with damperTarget: InstrumentsSet.Track.Part.DamperTarget) {
        switch damperTarget.parameter {
        case "phaserNotchMinimumFrequency":
            let mf = RangeConverter.valueToRange(range: phaserNotchMinimumFrequency.range, value: value, exponent: 1)
            (nodeOne as? Phaser)?.notchMinimumFrequency = AUValue( mf )
        case "phaserNotchMaximumFrequency":
            let nmf = RangeConverter.valueToRange(range: phaserNotchMaximumFrequency.range, value: value, exponent: 1)
            (nodeOne as? Phaser)?.notchMaximumFrequency = AUValue( nmf )
        case "phaserNotchWidth":
            let nw = RangeConverter.valueToRange(range: phaserNotchWidth.range, value: 1, exponent: 1)
            (nodeOne as? Phaser)?.notchWidth = AUValue( nw )
        case "phaserNotchFrequency":
            let freq = RangeConverter.valueToRange(range: phaserNotchFrequency.range, value: value, exponent: 1)
            (nodeOne as? Phaser)?.notchFrequency = AUValue( freq )
        case "phaserVibratoMode":
            let vm = RangeConverter.valueToRange(range: phaserVibratoMode.range, value: value, exponent: 1)
            (nodeOne as? Phaser)?.vibratoMode = AUValue( vm )
        case "phaserDepth":
            let d = RangeConverter.valueToRange(range: phaserDepth.range, value: value, exponent: 1)
            (nodeOne as? Phaser)?.depth = AUValue( d )
        case "phaserFeedback":
            let fb = RangeConverter.valueToRange(range: phaserFeedback.range, value: value, exponent: 1)
            (nodeOne as? Phaser)?.feedback = AUValue( fb )
        case "phaserInverted":
            let i = RangeConverter.valueToRange(range: phaserInverted.range, value: value, exponent: 1)
            (nodeOne as? Phaser)?.inverted = AUValue( i )
        case "phaserLfoBPM":
            let l = RangeConverter.valueToRange(range: phaserLfoBPM.range, value: value, exponent: 1)
            (nodeOne as? Phaser)?.lfoBPM = AUValue( l )
        case "phaserDryWetMixer":
            let m = RangeConverter.valueToRange(range: phaserDryWetMixer.range, value: value)
            (node as? DryWetMixer)?.balance = AUValue( m )
        default: break
        }
    }
    
    func apply<V>(keyPath: WritableKeyPath<Phaser, V>, value: V) {
        var phaser = nodeOne as? Phaser
        phaser?[keyPath: keyPath] = value
    }
    
    func valueAndRange(parameter: String) -> ValueAndRange? {
        switch parameter {
        case "phaserNotchMinimumFrequency":
            return phaserNotchMinimumFrequency
        case "phaserNotchMaximumFrequency":
            return phaserNotchMaximumFrequency
        case "phaserNotchWidth":
            return phaserNotchWidth
        case "phaserNotchFrequency":
            return phaserNotchFrequency
        case "phaserVibratoMode":
            return phaserVibratoMode
        case "phaserDepth":
            return phaserDepth
        case "phaserFeedback":
            return phaserFeedback
        case "phaserInverted":
            return phaserInverted
        case "phaserLfoBPM":
            return phaserLfoBPM
        case "phaserDryWetMixer":
            return phaserDryWetMixer
        default: return nil
        }
    }
}
