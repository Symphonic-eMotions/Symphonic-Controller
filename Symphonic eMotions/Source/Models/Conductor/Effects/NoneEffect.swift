//
//  NoneEffect.swift
//  eMotion
//
//  Created by Frans-Jan Wind on 29/10/2021.
//

import Foundation
import AudioKit
import SoundpipeAudioKit

class NoneEffect: AudioProcessingEffect {
    
    weak var nodeOne: Node?
    weak var node: Node?
    
    func chain(to input: Node) -> Node {
        return input
    }
    
    func apply(value: Double, with damperTarget: InstrumentsSet.Track.Part.DamperTarget) {
        
    }
    
    func valueAndRange(parameter: String) -> ValueAndRange? {
        return ValueAndRange.zero
    }
        
}
