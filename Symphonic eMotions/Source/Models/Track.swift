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
            case midiTargetTrackId
            case startType
            case masterTrackId
            case midiClipGroup
            case excludeLevelClipControl
            case instrumentName
            case instrumentColor
            case volume = "instrumentVolume"
            case midiFiles
            case midiThreshold
            case exsFiles
            case audioFiles
            case effects
            case parts = "instrumentParts"
            case levels
            case scoreWalkDuration
        }
        
        var id: String
        var trackId: String
        var muted: Bool? = true
        let instrumentType: InstrumentType
        let midiTargetTrackId: String?
        let midiClipGroup: MidiClipGroup?
        let excludeLevelClipControl: Bool?
        let startType: StartType
        let masterTrackId: String?
        var instrumentName: String
        let instrumentColor: Color
        var volume: Float
        var midiFiles: [MidiFile]?
        
        var midiThreshold: Double
        let exsFiles: [ExsFile]?
        let audioFiles: [AudioFile]?
        var effects: [Effect]?
//        var effectRanges: [EffectRanges]?
        var parts: [Part]
        //TODO: reading from this array should be from setSettings
        let levels: [Int]
        //Amount of beats before increment to next MIDI start point
        let scoreWalkDuration: [Int]?
        
        init(from decoder: Decoder) throws {
            
            let container = try decoder.container(keyedBy: TrackKeys.self)
            id = try container.decode(String.self, forKey: .trackId)
            trackId = try container.decode(String.self, forKey: .trackId)
            instrumentType = try container.decode(InstrumentType.self, forKey: .instrumentType)
            midiTargetTrackId = try container.decodeIfPresent(String.self, forKey: .midiTargetTrackId)
            midiClipGroup = try container.decodeIfPresent(MidiClipGroup.self, forKey: .midiClipGroup)
            excludeLevelClipControl = try container.decodeIfPresent(Bool.self, forKey: .excludeLevelClipControl)
            muted = try container.decodeIfPresent(Bool.self, forKey: .muted)
            startType = try container.decode(StartType.self, forKey: .startType)
            masterTrackId = try container.decodeIfPresent(String.self, forKey: .masterTrackId)
            instrumentName = try container.decode(String.self, forKey: .instrumentName)
            let instrumentColorString = try container.decodeIfPresent(String.self, forKey: .instrumentColor)
            instrumentColor = Color(instrumentColorString ?? "InstrumentColor000")
            volume = try container.decode(Float.self, forKey: .volume)
            midiFiles = try container.decodeIfPresent([MidiFile].self, forKey: .midiFiles)
            let midiThresholdTmp = try container.decodeIfPresent(Double.self, forKey: .midiThreshold)
            if midiThresholdTmp != nil { midiThreshold = midiThresholdTmp! }
            else { midiThreshold = 1 }
            exsFiles = try container.decodeIfPresent([ExsFile].self, forKey: .exsFiles)
            audioFiles = try container.decodeIfPresent([AudioFile].self, forKey: .audioFiles)
            
            //Have effectsRaw raw present to use as data struct
            let effectsRaw = try container.decodeIfPresent([Effect].self, forKey: .effects)
            effects = effectsRaw
            
            //Loop through parts to get ranges and overwrite decoded parts
            let partsRaw = try container.decode([Part].self, forKey: .parts)
            var partWithRange: [Part] = []
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
            }
            parts = partWithRange
            
            levels = try container.decode([Int].self, forKey: .levels)
            scoreWalkDuration = try container.decodeIfPresent([Int].self, forKey: .scoreWalkDuration)
        }
        
        init(
            id: String,
            trackId: String,
            muted: Bool?,
            instrumentType: InstrumentType,
            midiTargetTrackId: String?,
            midiClipGroup: MidiClipGroup?,
            excludeLevelClipControl: Bool?,
            startType: StartType,
            masterTrackId: String?,
            instrumentName: String,
            instrumentColor: Color,
            volume: Float,
            midiFiles: [MidiFile]?,
            midiThreshold: Double,
            exsFiles: [ExsFile]?,
            audioFiles: [AudioFile]?,
            effects: [Effect]?,
            parts: [Part],
            levels: [Int],
            scoreWalkDuration: [Int]?
        ) {
            self.id = id
            self.trackId = trackId
            self.muted = muted
            self.instrumentType = instrumentType
            self.midiTargetTrackId = midiTargetTrackId
            self.midiClipGroup = midiClipGroup
            self.excludeLevelClipControl = excludeLevelClipControl
            self.startType = startType
            self.masterTrackId = masterTrackId
            self.instrumentName = instrumentName
            self.instrumentColor = instrumentColor
            self.volume = volume
            self.midiFiles = midiFiles
            self.midiThreshold = midiThreshold
            self.exsFiles = exsFiles
            self.audioFiles = audioFiles
            self.effects = effects
            self.parts = parts
            self.levels = levels
            self.scoreWalkDuration = scoreWalkDuration
        }
        
        func effect(for effectType: Effect.EffectType) -> Effect? {
            effects?.first { $0.effectType == effectType }
        }

//        mutating func update(part: Part) {
//            guard let partIndex = parts.firstIndex(where: { $0.id == part.id }) else { return }
//            parts.remove(at: partIndex)
//            parts.insert(part, at: partIndex)
//        }
//
//        mutating func update(effect: Effect) {
//            guard let effectIndex = effects?.firstIndex(where: { $0.effectType == effect.effectType }) else { return }
//            effects?.remove(at: effectIndex)
//            effects?.insert(effect, at: effectIndex)
//        }
        
    }
}

enum Grids: CaseIterable {
    case empty
    case oneByOne
    case twoByTwo
    case threeByThree
    case fourByFour
    case fiveByFive
    
    init?(rows: Int) {
        switch rows {
        case 0:
            self = .empty
        case 1:
            self = .oneByOne
        case 2:
            self = .twoByTwo
        case 3:
            self = .threeByThree
        case 4:
            self = .fourByFour
        case 5:
            self = .fiveByFive
        default:
            return nil
        }
    }
    
    //There's just one clip in the MIDI file zo all regions trigger 0
    var oneClip: [Int] {
        switch self {
        case .empty:
            return []
        case .oneByOne:
            return [0]
        case .twoByTwo:
            return [0,0,0,0]
        case .threeByThree:
            return [0,0,0,0,0,0,0,0,0]
        case .fourByFour:
            return [
                0,0,0,0,
                0,0,0,0,
                0,0,0,0,
                0,0,0,0
            ]
        case .fiveByFive:
            return [
                0,0,0,0,0,
                0,0,0,0,0,
                0,0,0,0,0,
                0,0,0,0,0
            ]
        }
    }
}

extension InstrumentsSet.Track {

    struct LoopsToGrid: Decodable, Equatable {

        private enum LoopsToGridKeys: String, CodingKey {
            case mapper
        }

        var mapper: [Int]?

        //Decoder init
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: LoopsToGridKeys.self)
            mapper = try container.decodeIfPresent([Int].self, forKey: .mapper) ?? []
        }

        //Store to file init
        init(mapper: [Int]?){
            self.mapper = mapper
        }
        
        //Init
        init(grids: Grids) {
            self.mapper = grids.oneClip
        }
    }
}

extension InstrumentsSet.Track.LoopsToGrid: Encodable {
    func encoder(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: LoopsToGridKeys.self)
        try container.encode(mapper, forKey: .mapper)
    }
}


extension InstrumentsSet.Track: Encodable {
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TrackKeys.self)
        try container.encode(trackId, forKey: .trackId)
        try container.encode(muted, forKey: .muted)
        try container.encode(instrumentType, forKey: .instrumentType)
        try container.encode(midiTargetTrackId, forKey: .midiTargetTrackId)
        try container.encode(excludeLevelClipControl, forKey: .excludeLevelClipControl)
        try container.encode(startType, forKey: .startType)
        try container.encode(masterTrackId, forKey: .masterTrackId)
        try container.encode(instrumentName, forKey: .instrumentName)
        let instrumentColors = InstrumentColors()
        try container.encode(instrumentColors.name(color: instrumentColor), forKey: .instrumentColor)
        try container.encode(volume, forKey: .volume)
        try container.encode(midiFiles, forKey: .midiFiles)
        try container.encode(midiThreshold, forKey: .midiThreshold)
        try container.encode(exsFiles, forKey: .exsFiles)
        try container.encode(audioFiles, forKey: .audioFiles)
        try container.encode(effects, forKey: .effects)
        try container.encode(parts, forKey: .parts)
        try container.encode(levels, forKey: .levels)
        try container.encode(scoreWalkDuration, forKey: .scoreWalkDuration)
    }
}

extension InstrumentsSet.Track {
    
    enum InstrumentType: String, Codable {
        case audioBuffer
        case exsSampler
        case exsSamplerMIDI
        case pulseWidthSynth
        case phaseSynth
        case allValues
    }
    
}

extension InstrumentsSet.Track {
    
    enum StartType: String, Codable {
        case global
        case none
        //Trigger start stop
        case trigger
        case triggerSlave
        case triggerSlaveMaxIndex
        //midiData with slaves
        case triggerMidiDataSlaves
        case midiDataSlave
        //midiData global
        case globalMidiData
    }
}

extension InstrumentsSet.Track {
    
    enum MidiClipGroup: String, Codable {
        
        case chords
        case seqs
    }
}

extension InstrumentsSet.Track {
    
    struct MidiFile: Decodable {
        
        private enum MidiKeys: String, CodingKey {
            case fileName = "midiFileName"
            case fileExtension = "midiFileExt"
            case loopLength
            case loopsToGrid
            //case scoreParts
        }
        
        let fileName: String
        let fileExtension: String
        var loopLength: [Double]
        var loopsToGrid: LoopsToGrid
        //let scoreParts: Int
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: MidiKeys.self)
            fileName = try container.decode(String.self, forKey: .fileName)
            fileExtension = try container.decode(String.self, forKey: .fileExtension)
            loopLength = try container.decode([Double].self, forKey: .loopLength)
            //If empty fill with empty, overwrite with correct dimenstion for editor
            loopsToGrid = try container.decodeIfPresent(LoopsToGrid.self, forKey: .loopsToGrid) ?? LoopsToGrid.init(grids: .empty)
        }
        
        mutating func updateLoopLength(setLoopLength: Double){
            loopLength = [setLoopLength]
        }
    }
}

extension InstrumentsSet.Track.MidiFile: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: MidiKeys.self)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(fileExtension, forKey: .fileExtension)
        try container.encode(loopLength, forKey: .loopLength)
        try container.encode(loopsToGrid, forKey: .loopsToGrid)
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
    
    struct AudioFile: Decodable {
        
        private enum AudioFileKeys: String, CodingKey {
            case fileName = "audioFileName"
            case fileExtension = "audioFileExt"
            case midiNote
        }
        
        let fileName: String
        let fileExtension: String
        let midiNote: UInt8
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: AudioFileKeys.self)
            fileName = try container.decode(String.self, forKey: .fileName)
            fileExtension = try container.decode(String.self, forKey: .fileExtension)
            midiNote = try container.decode(UInt8.self, forKey: .midiNote)
        }
    }
}

extension InstrumentsSet.Track.AudioFile: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AudioFileKeys.self)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(fileExtension, forKey: .fileExtension)
        try container.encode(midiNote, forKey: .midiNote)
    }
}
