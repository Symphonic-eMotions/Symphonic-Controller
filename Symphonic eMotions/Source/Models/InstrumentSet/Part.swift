//
//  Part.swift
//  eMotion
//
//  Created by Mihai Fratu on 30.09.2021.
//

import AudioKit
import Foundation

extension InstrumentsSet.Track {
    struct Part: Identifiable, Decodable, Equatable {
        private enum PartKeys: String, CodingKey {
            case id
            case instrumentPartName
            case areaOfInterest
            case dontDrawVisual
            case damperTarget
        }

        let id: String
        var instrumentPartName: String

        // All movement calculations are done on update of areaOfInterest
        var areaOfInterest: [Int]

        // Do not draw this instrument part within the grid interface
        var dontDrawVisual: Bool?

        var damperTarget: DamperTarget
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: PartKeys.self)
            instrumentPartName = try container.decode(String.self, forKey: .instrumentPartName)
            areaOfInterest = try container.decode([Int].self, forKey: .areaOfInterest)
            dontDrawVisual = try container.decodeIfPresent(Bool.self, forKey: .dontDrawVisual) ?? false
            damperTarget = try container.decode(DamperTarget.self, forKey: .damperTarget)
            
            // 1) JSON id als die bestaat
            if let jsonId = try container.decodeIfPresent(String.self, forKey: .id), !jsonId.isEmpty {
                id = jsonId
            } else {
                // 2) anders: deterministische key uit damperTarget
                id = Part.makeStableId(from: instrumentPartName, damperTarget: damperTarget)
            }
        }

        init(
            id: String,
            instrumentPartName: String,
            areaOfInterest: [Int],
            dontDrawVisual: Bool?,
            damperTarget: DamperTarget,
            
        ) {
            self.id = id
            self.instrumentPartName = instrumentPartName
            self.areaOfInterest = areaOfInterest
            self.dontDrawVisual = dontDrawVisual
            self.damperTarget = damperTarget
        }
        
        // Handige helper voor deterministische sleutel
        static func makeStableId(from name: String, damperTarget: DamperTarget) -> String {
            // Neem zaken die in jouw domain uniek blijven:
            let node = [
                damperTarget.nodeType.rawValue,
                damperTarget.nodeName,
                damperTarget.parameter,
                String(damperTarget.parameterInversed)
            ].joined(separator: "|")
            
            // MIDI groep (als relevant voor uniekheid)
            let midi = damperTarget.midiData?.group.map(String.init).joined(separator: ",") ?? "_"
            
            // part-naam kan spaties hebben → normaliseer (spaties zijn op zich oké in UserDefaults keys,
            // maar normaliseren voorkomt edge cases)
            let normName = name.lowercased().replacingOccurrences(of: "\\s+", with: "_", options: .regularExpression)
            
            // Eindkey: deterministisch en leesbaar
            let raw = "\(normName)#\(node)#\(midi)"
            // Eventueel extra cleanup
            return raw.replacingOccurrences(of: "[^a-zA-Z0-9_#|,.-]", with: "_", options: .regularExpression)
        }

        func indexes(for set: InstrumentsSet) -> [Index] {
            var indexes: [Index] = []
            for row in 0 ..< set.rows {
                for column in 0 ..< set.columns {
                    if areaOfInterest[row * set.columns + column] == 1 {
                        indexes.append(Index(row: row, column: column))
                    }
                }
            }
            return indexes
        }

        private mutating func set(indexes: [Index], for set: InstrumentsSet) {
            var newAreaOfInterest: [Int] = Array(repeating: 0, count: set.rows * set.columns)
            for index in indexes {
                newAreaOfInterest[index.row * set.columns + index.column] = 1
            }
            areaOfInterest = newAreaOfInterest
        }
    }
}

extension InstrumentsSet.Track.Part: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PartKeys.self)
        try container.encode(id, forKey: .id)
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
            group = try container.decode([Int].self, forKey: .group)
            ranges = try container.decodeIfPresent([Double].self, forKey: .ranges)
        }

        init(group: [Int], ranges: [Double]) {
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
