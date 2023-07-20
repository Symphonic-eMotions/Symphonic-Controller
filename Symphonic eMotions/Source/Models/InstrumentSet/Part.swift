//
//  Part.swift
//  eMotion
//
//  Created by Mihai Fratu on 30.09.2021.
//

import Foundation
import AudioKit

extension InstrumentsSet.Track {
    
    struct Part: Identifiable, Decodable, Equatable {
        
        private enum PartKeys: String, CodingKey {
            case instrumentPartName
            case areaOfInterest
            case dontDrawVisual
            case damperTarget
        }
        
        let id: String = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        var instrumentPartName: String
        
        //All movement calculations are done on update of areaOfInterest
        var areaOfInterest: [Int]
        
        //Do not draw this instrument part within the grid interface
        var dontDrawVisual: Bool?
        
        var damperTarget: DamperTarget
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: PartKeys.self)
            instrumentPartName = try container.decode(String.self, forKey: .instrumentPartName)
            areaOfInterest = try container.decode([Int].self, forKey: .areaOfInterest)
            dontDrawVisual = try container.decodeIfPresent(Bool.self, forKey: .dontDrawVisual) ?? false
            damperTarget = try container.decode(DamperTarget.self, forKey: .damperTarget)
        }
        
        init(
            instrumentPartName: String,
            areaOfInterest: [Int],
            dontDrawVisual: Bool?,
            damperTarget: DamperTarget
        ) {
            self.instrumentPartName = instrumentPartName
            self.areaOfInterest = areaOfInterest
            self.dontDrawVisual = dontDrawVisual
            self.damperTarget = damperTarget
        }
        
        func indexes(for set: InstrumentsSet) -> [Index] {
            var indexes: [Index] = []
            for row in 0..<set.rows {
                for column in 0..<set.columns {
                    if areaOfInterest[row * set.columns + column] == 1 {
                        indexes.append(Index(row: row, column: column))
                    }
                }
            }
            return indexes
        }
    
        mutating private func set(indexes: [Index], for set: InstrumentsSet) {
            var newAreaOfInterest: [Int] = Array(repeating: 0, count: set.rows * set.columns)
            indexes.forEach {
                newAreaOfInterest[$0.row * set.columns + $0.column] = 1
            }
            areaOfInterest = newAreaOfInterest
        }
        
        mutating func toggleIndex(index: Index, in set: InstrumentsSet) {
            var newIndexes = indexes(for: set)
            if let index = newIndexes.firstIndex(where: { $0.column == index.column && $0.row == index.row }) {
                newIndexes.remove(at: index)
            }
            else {
                newIndexes.append(index)
            }
            self.set(indexes: newIndexes, for: set)
        }
    }
    
}

extension InstrumentsSet.Track.Part: Encodable{
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PartKeys.self)
        try container.encode(instrumentPartName, forKey: .instrumentPartName)
        try container.encode(areaOfInterest, forKey: .areaOfInterest)
        try container.encode(dontDrawVisual, forKey: .dontDrawVisual)
        try container.encode(damperTarget, forKey: .damperTarget)
    }
}

extension InstrumentsSet.Track.Part {
    struct Index {
        let row: Int
        let column: Int
    }
}

//struct FullIndex{
//    let row: Int
//    let column: Int
//}

extension InstrumentsSet.Track.Part.DamperTarget {
    
    struct MidiData: Decodable, Equatable {
        
        private enum MidiDataKeys: String, CodingKey {
            case group
            case ranges
        }
        
        var group: [Int]
        var ranges: [Double]?
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: MidiDataKeys.self)
            self.group = try container.decode([Int].self, forKey: .group)
            self.ranges = try container.decodeIfPresent([Double].self, forKey: .ranges)
        }
        
        init(group: [Int], ranges: [Double]){
            self.group = group
            self.ranges = ranges
        }
    }
}

extension InstrumentsSet.Track.Part.DamperTarget.MidiData: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: MidiDataKeys.self)
        try container.encode(group, forKey: .group)
        try container.encode(ranges, forKey: .ranges)
    }
}
