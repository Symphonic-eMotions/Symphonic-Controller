//
//  MidiFiles.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 10/04/2023.
//

import Foundation

extension InstrumentsSet.Track {
    
    struct MidiFile: Decodable {
        
        private enum MidiKeys: String, CodingKey {
            case fileName = "midiFileName"
            case fileExtension = "midiFileExt"
            case loopLength
            case loopsToLevel
            case loopsToGrid
            //case scoreParts
        }
        
        let fileName: String
        let fileExtension: String
        var loopLength: [Double]
        var loopsToLevel: [Int]
        var loopsToGrid: LoopsToGrid
        //let scoreParts: Int
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: MidiKeys.self)
            fileName = try container.decode(String.self, forKey: .fileName)
            fileExtension = try container.decode(String.self, forKey: .fileExtension)
            loopLength = try container.decode([Double].self, forKey: .loopLength)
            //If empty fill with empty, overwrite with correct dimenstion for editor
            loopsToLevel = try container.decodeIfPresent([Int].self, forKey: .loopsToLevel) ?? []
            loopsToGrid = try container.decodeIfPresent(LoopsToGrid.self, forKey: .loopsToGrid) ?? LoopsToGrid.init(grids: .empty)
        }
        
        init(
            fileName: String,
            fileExtension: String,
            loopLength: [Double],
            loopsToLevel: [Int],
            loopsToGrid: LoopsToGrid
        ) {
            self.fileName = fileName
            self.fileExtension = fileExtension
            self.loopLength = loopLength
            self.loopsToLevel = loopsToLevel
            self.loopsToGrid = loopsToGrid
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
        try container.encode(loopsToLevel, forKey: .loopsToLevel)
        try container.encode(loopsToGrid, forKey: .loopsToGrid)
    }
}

extension InstrumentsSet.Track.MidiFile {
    
    //LoopsToGrid an array where the index corresponds with a cell location
    //The value corresponds with the midiClip index
    //Loop = MidiClip == location in MIDI file
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
        
        //Init with all fields filled with zero, just one midi section in the Midi File
        //Also have correct amount of cells for itiration
        init(grids: Grids) {
            self.mapper = grids.oneClip
        }
    }
}

extension InstrumentsSet.Track.MidiFile.LoopsToGrid: Encodable {
    func encoder(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: LoopsToGridKeys.self)
        try container.encode(mapper, forKey: .mapper)
    }
}
