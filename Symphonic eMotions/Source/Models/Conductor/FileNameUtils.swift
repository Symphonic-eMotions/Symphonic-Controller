//
//  FileNameUtils.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 30/06/2023.
//

import Foundation

extension Conductor {
    
    public func midiNoteNumberFromFileName(_ fileName: String, separators: [Character] = ["_", "-", "/"]) -> Int? {
        
//        print("fileName: \(fileName)")
        
        let noteNameToMidi: [String: Int] = [
            "C": 0, "C#": 1, "Db": 1, "D": 2, "D#": 3, "Eb": 3, "E": 4, "F": 5,
            "F#": 6, "Gb": 6, "G": 7, "G#": 8, "Ab": 8, "A": 9, "A#": 10, "Bb": 10, "B": 11
        ]
        let baseMidiNoteNumberForC0 = 12
        
        // Split the string into components using "_" as the separator
        let components = fileName.split{ separators.contains($0) }
        guard let lastComponent = components.last else { return nil }
        
//        print("lastComponent: \(lastComponent)")
        
        // Get the note and octave parts
        var note = ""
        var octave = ""
        for char in lastComponent {
            if char.isLetter || char == "#" {
                note.append(char)
            } else if char.isNumber {
                octave.append(char)
            }
        }
        
//        print("Note: \(note) - Octave: \(octave)")
        
        guard let noteValue = noteNameToMidi[note] else { return nil }
        guard let octaveValue = Int(octave) else { return nil }
        
        return baseMidiNoteNumberForC0 + (octaveValue * 12) + noteValue
    }
    
    public func lengthInBeatsFromFileName(fileName: String, separators: [Character] = ["_", "-", "/"]) -> Double? {
        
        let components = fileName.split { separators.contains($0) }
        
        guard components.count >= 2 else {
            print("Unable to find length in beats in filename \(fileName).")
            return nil
        }
        
        // Assuming the length in beats is the second component from the end
        let lengthInBeatsString = components[components.count - 2]
        
        if let lengthInBeats = Double(lengthInBeatsString) {
            return lengthInBeats
        } else {
//            print("The file name \(fileName) has no length in beats info returning nil")
            return nil
        }
    }
}
