//
//  NoneEffect.swift
//  eMotion
//
//  Created by Frans-Jan Wind on 29/10/2021.
//

import AudioKit
import Foundation
import SoundpipeAudioKit

class NoneEffect: AudioProcessingEffect {
    weak var nodeOne: Node?
    weak var node: Node?

    func chain(to input: Node) -> Node {
        return input
    }

    func apply(value _: Double, with _: InstrumentsSet.Track.Part.DamperTarget) {}

    func valueAndRange(parameter _: String) -> ValueAndRange? {
        return ValueAndRange.zero
    }
}
