//
//  Track.swift
//  Track
//
//  Created by Mihai Fratu on 31.07.2021.
//

import SwiftUI
import Accelerate
import AudioToolbox

extension InstrumentsSet {
    
    struct Track: Identifiable, Decodable {
        
        static func withJSON(_ fileName: String) -> InstrumentsSet.Track? {
            guard let url = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: "Sets") else { return nil }
            guard let data = try? Data(contentsOf: url) else { return nil }
            return try! JSONDecoder().decode(InstrumentsSet.Track.self, from: data)
        }
        
        private enum TrackKeys: String, CodingKey {
            case id
            case trackId
            case muted
            case instrumentType
            case noteSource
            case startType
            case variationType = "trackType"
            case instrumentName
            case instrumentColor
            case volume = "instrumentVolume"
            case midiFiles
            case midiGroup
            case notesToGrid
            case notesToLevel
            case noteNumbersClips
            case notesSequenceType
            case exsFiles
            case audioFiles
            case effects
            case parts = "instrumentParts"
            case levels
        }
        
        var id: String
        var trackId: String
        var muted: Bool? = true
        //Sound source / generator
        let instrumentType: InstrumentType
        
        //Midi file or note numbers
        var noteSource: NoteSource?
        //How do notes start playing
        var startType: StartType
        //To be refeactored to NoteVariation
        //How can we change the note material
        var variationType: VariationType?
        
        var firstMinimalLevel: Double?
        
        var instrumentName: String
        let instrumentColor: Color
        var volume: Float
        
        var midiFiles: [MidiFile]?
        
        var midiGroup: [Int]?
        var notesToGrid: [Int]?
        var notesToLevel: [Int]?
        var noteNumbersClips: [Int]?
        var notesSequenceType: NotesSequenceType?
        
        let exsFiles: [ExsFile]?
        let audioFiles: [AudioFile]?
        var effects: [Effect]?
//        var effectRanges: [EffectRanges]?
        var parts: [Part]
        let levels: [Int]
        
        init(from decoder: Decoder) throws {
            
            let container = try decoder.container(keyedBy: TrackKeys.self)
            id = try container.decode(String.self, forKey: .trackId)
            trackId = try container.decode(String.self, forKey: .trackId)
            instrumentType = try container.decode(InstrumentType.self, forKey: .instrumentType)
            
            noteSource = try container.decodeIfPresent(NoteSource.self, forKey: .noteSource)
            startType = try container.decode(StartType.self, forKey: .startType)
            variationType = try container.decodeIfPresent(VariationType.self, forKey: .variationType)
            
            muted = try container.decodeIfPresent(Bool.self, forKey: .muted)
            instrumentName = try container.decode(String.self, forKey: .instrumentName)
            
            let instrumentColorString = try container.decodeIfPresent(String.self, forKey: .instrumentColor)
            instrumentColor = Color(instrumentColorString ?? "InstrumentColor000")
            
            volume = try container.decode(Float.self, forKey: .volume)
            midiFiles = try container.decodeIfPresent([MidiFile].self, forKey: .midiFiles)
            
            midiGroup = try container.decodeIfPresent([Int].self, forKey: .midiGroup)
            notesToGrid = try container.decodeIfPresent([Int].self, forKey: .notesToGrid)
            notesToLevel = try container.decodeIfPresent([Int].self, forKey: .notesToLevel)
            noteNumbersClips = try container.decodeIfPresent([Int].self, forKey: .noteNumbersClips)
            notesSequenceType = try container.decodeIfPresent(NotesSequenceType.self, forKey: .notesSequenceType)
            
            exsFiles = try container.decodeIfPresent([ExsFile].self, forKey: .exsFiles)
            audioFiles = try container.decodeIfPresent([AudioFile].self, forKey: .audioFiles)
            
            //Have effectsRaw raw present to use as data struct
            let effectsRaw = try container.decodeIfPresent([Effect].self, forKey: .effects)
            effects = effectsRaw
            
            //Loop through parts to get ranges and overwrite decoded parts
            let partsRaw = try container.decodeIfPresent([Part].self, forKey: .parts) ?? []
            var partWithRange: [Part] = []
            var parIndex = 0
            for var partRaw in partsRaw {
                
                effectsRaw?.forEach { effectRaw in
                    //Next find the correct parameter
                    let parameter = partRaw.damperTarget.parameter
                    let valueAndRange = effectRaw.valueAndRanges(parameter: parameter)
                    if valueAndRange?.range != nil {
                        partRaw.damperTarget.parameterRange = valueAndRange!.range
                    }
                }
                partWithRange.append(partRaw)
                if parIndex == 0 {
                    firstMinimalLevel = partRaw.damperTarget.nodeSettings?.minimalLevel ?? 0.1
                }
                parIndex += 1
            }
            parts = partWithRange
            
            if firstMinimalLevel == nil {
                firstMinimalLevel = 0.1
            }
            
            levels = try container.decode([Int].self, forKey: .levels)
        }
        
        init(
            id: String,
            trackId: String,
            muted: Bool?,
            instrumentType: InstrumentType,
            noteSource: NoteSource,
            startType: StartType,
            variationType: VariationType,
            instrumentName: String,
            instrumentColor: Color,
            volume: Float,
            midiFiles: [MidiFile]?,
            midiGroup: [Int]?,
            notesToGrid: [Int]?,
            notesToLevel: [Int]?,
            noteNumbersClips: [Int]?,
            notesSequenceType: NotesSequenceType,
            exsFiles: [ExsFile]?,
            audioFiles: [AudioFile]?,
            effects: [Effect]?,
            parts: [Part],
            levels: [Int]
        ) {
            self.id = id
            self.trackId = trackId
            self.muted = muted
            self.instrumentType = instrumentType
            self.noteSource = noteSource
            self.startType = startType
            self.variationType = variationType
            self.instrumentName = instrumentName
            self.instrumentColor = instrumentColor
            self.volume = volume
            self.midiFiles = midiFiles
            self.midiGroup = midiGroup
            self.notesToGrid = notesToGrid
            self.notesToLevel = notesToLevel
            self.noteNumbersClips = noteNumbersClips
            self.notesSequenceType = notesSequenceType
            self.exsFiles = exsFiles
            self.audioFiles = audioFiles
            self.effects = effects
            self.parts = parts
            self.levels = levels
            self.firstMinimalLevel = 0.1 //first part minimal level
        }
        
        func effect(for effectType: Effect.EffectType) -> Effect? {
            effects?.first { $0.effectType == effectType }
        }
    }
}

extension InstrumentsSet.Track: Encodable {
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TrackKeys.self)
        try container.encode(trackId, forKey: .trackId)
        try container.encode(muted, forKey: .muted)
        try container.encode(instrumentType, forKey: .instrumentType)
        
        try container.encode(noteSource, forKey: .noteSource)
        try container.encode(startType, forKey: .startType)
        try container.encode(variationType, forKey: .variationType)
        try container.encode(instrumentName, forKey: .instrumentName)
        let instrumentColors = InstrumentColors()
        try container.encode(instrumentColors.name(color: instrumentColor), forKey: .instrumentColor)
        try container.encode(volume, forKey: .volume)
        try container.encode(midiFiles, forKey: .midiFiles)
        try container.encode(midiGroup, forKey: .midiGroup)
        try container.encode(notesToGrid, forKey: .notesToGrid)
        try container.encode(notesToLevel, forKey: .notesToLevel)
        try container.encode(noteNumbersClips, forKey: .noteNumbersClips)
        try container.encode(notesSequenceType, forKey: .notesSequenceType)
        try container.encode(exsFiles, forKey: .exsFiles)
        try container.encode(audioFiles, forKey: .audioFiles)
        try container.encode(effects, forKey: .effects)
        try container.encode(parts, forKey: .parts)
        try container.encode(levels, forKey: .levels)
    }
}

extension InstrumentsSet.Track {
    
    enum InstrumentType: String, Codable, CaseIterable {
        case exsSampler
        case audioBuffer
        case audioBufferTimed
        case SemOne
        case pulseWidthSynth
        case phaseSynth
        
        var description: String {
            switch self{
            case .exsSampler:
                return "EXS sampler"
            case .audioBuffer:
                return "Buffer sampler"
            case .audioBufferTimed:
                return "Stretched buffer sampler"
            case .SemOne:
                return "SeMOne Synth"
            case .pulseWidthSynth:
                return "Pulse Width Modulation Synth"
            case .phaseSynth:
                return "Phase Synth"
            }
        }
    }
}

extension InstrumentsSet.Track {
    
    struct ExsFile: Decodable {
        
        private enum ExsKeys: String, CodingKey {
            case fileName = "exsFileName"
            case fileExtension = "exsFileExt"
        }
        
        let fileName: String
        let fileExtension: String
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: ExsKeys.self)
            fileName = try container.decode(String.self, forKey: .fileName)
            fileExtension = try container.decode(String.self, forKey: .fileExtension)
        }
        
        init(fileName: String){
            self.fileName = fileName
            self.fileExtension = "exs"
        }
    }
}

extension InstrumentsSet.Track.ExsFile: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ExsKeys.self)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(fileExtension, forKey: .fileExtension)
    }
}

extension InstrumentsSet.Track {

    struct AudioFile: Decodable, Identifiable {
        private enum AudioFileKeys: String, CodingKey {
            case id
            case fileName
            case fileExtension
            case lengthInBeats
            case source
        }
        
        let id: UUID
        let fileName: String
        let fileExtension: String
        var lengthInBeats: Double
        let source: InstrumentsSet.FileSource

        init(from decoder: Decoder) throws {
            self.id = UUID()
            let container = try decoder.container(keyedBy: AudioFileKeys.self)
            fileName = try container.decode(String.self, forKey: .fileName)
            fileExtension = try container.decode(String.self, forKey: .fileExtension)
            lengthInBeats = try container.decode(Double.self, forKey: .lengthInBeats)
            source = try container.decodeIfPresent(InstrumentsSet.FileSource.self, forKey: .source) ?? .user
        }

        init(
            fileName: String,
            fileExtension: String,
            lengthInBeats: Double,
            source: InstrumentsSet.FileSource
        ){
            self.id = UUID()
            self.fileName = fileName
            self.fileExtension = fileExtension
            self.lengthInBeats = lengthInBeats
            self.source = source
        }
    }
}

extension InstrumentsSet.Track.AudioFile: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AudioFileKeys.self)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(fileExtension, forKey: .fileExtension)
        try container.encode(lengthInBeats, forKey: .lengthInBeats)
        try container.encode(source, forKey: .source)
    }
}

