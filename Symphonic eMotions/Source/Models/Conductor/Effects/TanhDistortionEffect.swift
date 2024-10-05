//
//  TanhDistortionEffect.swift
//  eMotion
//
//  Created by Frans-Jan Wind on 29/10/2021.
//

import Foundation
import AudioKit
import SoundpipeAudioKit
import AudioKitEX

class TanhDistortionEffect: AudioProcessingEffect {
    
    let pregain: ValueAndRange
    let postgain: ValueAndRange
    let positiveShapeParameter: ValueAndRange
    let negativeShapeParameter: ValueAndRange
    let dryWetTanh: ValueAndRange
    
    weak var nodeOne: Node?
    weak var node: Node?
    
    init(pregain: ValueAndRange, postgain: ValueAndRange, positiveShapeParameter: ValueAndRange, negativeShapeParameter: ValueAndRange, dryWetTanh: ValueAndRange) {
        self.pregain = pregain
        self.postgain = postgain
        self.positiveShapeParameter = positiveShapeParameter
        self.negativeShapeParameter = negativeShapeParameter
        self.dryWetTanh = dryWetTanh
    }
    
    func chain(to input: Node) -> Node {
        let tanhDistortion = TanhDistortion(input, pregain: pregain.value, postgain: postgain.value, positiveShapeParameter: positiveShapeParameter.value, negativeShapeParameter: negativeShapeParameter.value  )
        let newNode = DryWetMixer(input, tanhDistortion, balance: dryWetTanh.value)
        nodeOne = tanhDistortion
        node = newNode
        return newNode
    }
    
    func apply(value: Double, with damperTarget: InstrumentsSet.Track.Part.DamperTarget) {
        switch damperTarget.parameter {
        case "pregain":
            let pre = RangeConverter.valueToRange(range: pregain.range, value: value )
            (node as? TanhDistortion)?.pregain = AUValue( pre )
        case "postgain":
            let post = RangeConverter.valueToRange(range: postgain.range, value: value)
            (node as? TanhDistortion)?.postgain = AUValue( post )
        case "positiveShapeParameter":
            let posShape = RangeConverter.valueToRange(range: positiveShapeParameter.range, value: value)
            (node as? TanhDistortion)?.positiveShapeParameter = AUValue( posShape )
        case "negativeShapeParameter":
            let negShape = RangeConverter.valueToRange(range: negativeShapeParameter.range, value: value)
            (node as? TanhDistortion)?.negativeShapeParameter = AUValue( negShape )
        case "dryWetTanh":
            let d = RangeConverter.valueToRange(range: dryWetTanh.range, value: value )
            (node as? DryWetMixer)?.balance = AUValue( d )
        default: break
        }
    }
    
    func valueAndRange(parameter: String) -> ValueAndRange? {
        switch parameter {
        case "pregain":
            return pregain
        case "postgain":
            return postgain
        case "positiveShapeParameter":
            return positiveShapeParameter
        case "negativeShapeParameter":
            return negativeShapeParameter
        case "dryWetTanh":
            return dryWetTanh
        default: return nil
        }
    }
}
