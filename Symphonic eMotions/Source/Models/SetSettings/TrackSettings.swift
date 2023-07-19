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
    var exsFile: ExsFiles
    var audioFiles: [InstrumentsSet.Track.AudioFile]
    
    var instrumentVolume: Float
    var instrumentColor: Color
    
    var midiGroup: [Int]
    var notesToGrid: [Int]
    var notesToGridMapped: [Int]
    var notesToLevel: [Int]
    var noteNumbersClips: [Int]
    var notesSequenceType: NotesSequenceType
    
    var midiFile: String
    var loopLength: [Double]
    var loopsToLevel: [Int]
    var loopsToGrid: [Int]
    var loopsToGridMapped: [Int]
    
    var levels: [Int]
    
    @Published var parts: OrderedDictionary<String, PartSettings> = OrderedDictionary<String, PartSettings>() {
        didSet {
            objectWillChange.send()
        }
    }
    
    //Start point track effects
    @Published var effects: OrderedDictionary<Int, TrackEffectsSettings> = OrderedDictionary<Int, TrackEffectsSettings>() {
        didSet {
            objectWillChange.send()
        }
    }
    
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
        exsFile: ExsFiles,
        audioFiles: [InstrumentsSet.Track.AudioFile],
        instrumentVolume: Float,
        instrumentColor: Color,
        midiFile: String,
        midiGroup: [Int],
        notesToGrid: [Int],
        notesToGridMapped: [Int],
        notesToLevel: [Int],
        noteNumbersClips: [Int],
        notesSequenceType: NotesSequenceType,
        loopLength: [Double],
        loopsToLevel: [Int],
        loopsToGrid: [Int],
        loopsToGridMapped: [Int],
        levels: [Int],
        parts: OrderedDictionary<String, PartSettings>,
        effects: OrderedDictionary<Int, TrackEffectsSettings>
    ){
        self.trackId = trackId
        self.trackIndex = trackIndex
        self.trackName = trackName
        self.noteSource = noteSource
        self.startType = startType
        self.variationType = variationType
        self.instrumentType = instrumentType
        self.exsFile = exsFile
        self.audioFiles = audioFiles
        self.instrumentVolume = instrumentVolume
        self.instrumentColor = instrumentColor
        self.midiFile = midiFile
        self.midiGroup = midiGroup
        self.notesToGrid = notesToGrid
        self.notesToGridMapped = notesToGridMapped
        self.notesToLevel = notesToLevel
        self.noteNumbersClips = noteNumbersClips
        self.notesSequenceType = notesSequenceType
        self.loopLength = loopLength
        self.loopsToLevel = loopsToLevel
        self.loopsToGrid = loopsToGrid
        self.loopsToGridMapped = loopsToGridMapped
        self.levels = levels
        self.parts = parts
        self.effects = effects
    }
    
    func changeAreaOfInterestColor(newColor: Color){
        for partId in self.parts.keys {
            self.parts[partId]?.areaOfInterestColor = AppUtils.getPartColors(trackColor: newColor, areaOfInterest: self.parts[partId]!.areaOfInterest)
        }
    }
    
    func reaplceNote(oldNote:Int) -> Void {
        
    }
}
