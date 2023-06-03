//
//  NotesSequenceType.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 01/06/2023.
//

import Foundation

enum NotesSequenceType: String, Codable, CaseIterable {
    
    case firstNote
    case nextForward
    case nextBackward
    case randomNote
    case increaseWithValue
    
    var description: String {
        switch self{
        case .firstNote:
            return "Only first note"
        case .nextForward:
            return "Next forward"
        case .nextBackward:
            return "Next backward"
        case .randomNote:
            return "Random note"
        case .increaseWithValue:
            return "Map notes to value"
        }
    }
}

extension Conductor {
    
    internal func getNextSequenceNote(
        _ currentNote: Int,
        _ notesSequeneType: NotesSequenceType,
        _ midiGroup: [Int],
        _ value: Double ) -> Int {
     
        if notesSequeneType == .firstNote {
            return midiGroup.first!
        }
        else if notesSequeneType == .nextForward {
            if let index = midiGroup.firstIndex(of: currentNote) {
                let nextIndex = (index + 1) % midiGroup.count
                return midiGroup[nextIndex]
            }
        }
        else if notesSequeneType == .nextBackward {
            if let index = midiGroup.firstIndex(of: currentNote) {
                let nextIndex = (index - 1) % midiGroup.count
                return midiGroup[nextIndex]
            }
            else{
                let lastIndex = midiGroup.count - 1
                return midiGroup[lastIndex]
            }
        }
        else if notesSequeneType == .randomNote {
            if let randomElement = midiGroup.randomElement() {
                return randomElement
            }
        }
        else if notesSequeneType == .increaseWithValue {
            let index = Int(value * Double(midiGroup.count))
            if index < midiGroup.count {
                return midiGroup[index]
            }
        }
        
        return midiGroup.first!
        
    }
}
