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
        var loopsToGrid: [Int]
        //let scoreParts: Int
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: MidiKeys.self)
            fileName = try container.decode(String.self, forKey: .fileName)
            fileExtension = try container.decode(String.self, forKey: .fileExtension)
            loopLength = try container.decode([Double].self, forKey: .loopLength)
            loopsToLevel = try container.decodeIfPresent([Int].self, forKey: .loopsToLevel) ?? []
            loopsToGrid = try container.decodeIfPresent([Int].self, forKey: .loopsToGrid) ?? []
        }
        
        init(
            fileName: String,
            fileExtension: String,
            loopLength: [Double],
            loopsToLevel: [Int],
            loopsToGrid: [Int]
        ) {
            self.fileName = fileName
            self.fileExtension = fileExtension
            self.loopLength = loopLength
            self.loopsToLevel = loopsToLevel
            self.loopsToGrid = loopsToGrid
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


