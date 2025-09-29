//
//  ChordEntry.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 22/05/2024.
//

import Foundation

struct ChordEntry: Hashable, Identifiable, Codable {
    var id: UUID
    let chord: Chord
    let octave: Int
    let length: Length
    var strum: Double
    var durationFactor: Double
    var option: ChordOption

    // Custom initializer with default values
    init(
        id: UUID = UUID(),
        chord: Chord = .C,
        octave: Int = 4,
        length: Length = .whole,
        strum: Double = 1.0,
        durationFactor: Double = 1.0,
        option: ChordOption = .none
    ) {
        self.id = id
        self.chord = chord
        self.octave = octave
        self.length = length
        self.strum = strum
        self.durationFactor = durationFactor
        self.option = option
    }
}
