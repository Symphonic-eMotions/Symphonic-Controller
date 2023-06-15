//
//  TrackSettings.swift
//  Symphonic eMotions Intern
//
//  Created by Frans-Jan Wind on 16/02/2023.
//

import OrderedCollections
import SwiftUI
import AudioKit

class TrackSettings: Identifiable, ObservableObject {
    
    var trackId: String
    var trackIndex: Int
    var trackName: String
    var noteSource: NoteSource
    var startType: StartType
    var variationType: VariationType
    var instrumentType: InstrumentsSet.Track.InstrumentType
    var instrumentVolume: Float
    var instrumentColor: Color
    
    var midiGroup: [Int]
    var notesToGrid: [Int]
    var notesToGridMapped: [Int]
    var notesToLevel: [Int]
    var notesSequenceType: NotesSequenceType
    
    var midiFile: String
    var loopLength: [Double]
    var loopsToLevel: [Int]
    var loopsToGrid: [Int]
    var loopsToGridMapped: [Int]
    
    var levels: [Int]
    var parts: OrderedDictionary<String, PartSettings>
    
    //PlayStatus vars
    var playThisNote: Int = 0
    var notesArePlaying: [Int] = []
    var currentMaxIndex: Int = 0
    var currentPartMaxIndex: Int = 0
    var currentLoopIndex: Int = 0
    var currentLevel: Int = -1
    
    init(
        trackId: String,
        trackIndex: Int,
        trackName: String,
        noteSource: NoteSource,
        startType: StartType,
        variationType: VariationType,
        instrumentType: InstrumentsSet.Track.InstrumentType,
        instrumentVolume: Float,
        instrumentColor: Color,
        midiFile: String,
        midiGroup: [Int],
        notesToGrid: [Int],
        notesToGridMapped: [Int],
        notesToLevel: [Int],
        notesSequenceType: NotesSequenceType,
        loopLength: [Double],
        loopsToLevel: [Int],
        loopsToGrid: [Int],
        loopsToGridMapped: [Int],
        levels: [Int],
        parts: OrderedDictionary<String, PartSettings>
    ){
        self.trackId = trackId
        self.trackIndex = trackIndex
        self.trackName = trackName
        self.noteSource = noteSource
        self.startType = startType
        self.variationType = variationType
        self.instrumentType = instrumentType
        self.instrumentVolume = instrumentVolume
        self.instrumentColor = instrumentColor
        self.midiFile = midiFile
        self.midiGroup = midiGroup
        self.notesToGrid = notesToGrid
        self.notesToGridMapped = notesToGridMapped
        self.notesToLevel = notesToLevel
        self.notesSequenceType = notesSequenceType
        self.loopLength = loopLength
        self.loopsToLevel = loopsToLevel
        self.loopsToGrid = loopsToGrid
        self.loopsToGridMapped = loopsToGridMapped
        self.levels = levels
        self.parts = parts
    }
    
    func changeAreaOfInterestColor(newColor: Color){
        for partId in self.parts.keys {
            self.parts[partId]?.areaOfInterestColor = AppUtils.getPartColors(trackColor: newColor, areaOfInterest: self.parts[partId]!.areaOfInterest)
        }
    }
    
    func reaplceNote(oldNote:Int) -> Void {
        
    }
}
