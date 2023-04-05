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
            case mapMaxIndex
            case allValues
            case dontDrawVisual
            case damperTarget
        }
        
        let id: String = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        var instrumentPartName: String
        
        //All movement calculations are done on update of areaOfInterest
        var areaOfInterest: [Int]
        //Do not draw this instrument part within the grid interface
        var dontDrawVisual: Bool?
        
        //Map area of interest reletive indexes to custom order
        var mapMaxIndex: [Int]?
        
        var allValues: [Double]?
        var damperTarget: DamperTarget
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: PartKeys.self)
            instrumentPartName = try container.decode(String.self, forKey: .instrumentPartName)
            areaOfInterest = try container.decode([Int].self, forKey: .areaOfInterest)
            dontDrawVisual = try container.decodeIfPresent(Bool.self, forKey: .dontDrawVisual) ?? false
            mapMaxIndex = try container.decodeIfPresent([Int].self, forKey: .mapMaxIndex)
            allValues = try container.decodeIfPresent([Double].self, forKey: .allValues)
            damperTarget = try container.decode(DamperTarget.self, forKey: .damperTarget)
        }
        
        init(
            instrumentPartName: String,
            areaOfInterest: [Int],
            dontDrawVisual: Bool?,
            mapMaxIndex: [Int]?,
            allValues: [Double]?,
            damperTarget: DamperTarget
        ) {
            self.instrumentPartName = instrumentPartName
            self.areaOfInterest = areaOfInterest
            self.dontDrawVisual = dontDrawVisual
            self.mapMaxIndex = mapMaxIndex
            self.allValues = allValues
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
        
//        func indexes(for setSettings: SetSettings) -> [Index]{
//            var indexes: [Index] = []
//            for row in 0..<setSettings.rows {
//                for column in ..<setSettings.columns {
//                    if setSettings.
//                }
//            }
//            
//            
//            return indexes
//        }
        
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
        
        func isIndexSelected(index: Index, in set: InstrumentsSet) -> Bool {
            indexes(for: set).contains { $0.column == index.column && $0.row == index.row }
        }
        
    }
    
}

extension InstrumentsSet.Track.Part: Encodable{
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PartKeys.self)
        try container.encode(instrumentPartName, forKey: .instrumentPartName)
        try container.encode(areaOfInterest, forKey: .areaOfInterest)
        try container.encode(dontDrawVisual, forKey: .dontDrawVisual)
        try container.encode(mapMaxIndex, forKey: .mapMaxIndex)
        try container.encode(damperTarget, forKey: .damperTarget)
    }
}

extension InstrumentsSet.Track.Part.DamperTarget {
    
    enum DampMode: String, Codable, Equatable {
        
        case direct
        case timed
        
        case easeInCubic
        case easeOutCubic
        case easeInOutCubic
        
        case easeInCircular
        
        case timedNegative
    }
    
}


extension InstrumentsSet.Track.Part {
    
    struct DamperTarget: Decodable, Equatable {
        
        private enum TargetKeys: String, CodingKey {
            case trackId
            case nodeType
//            case scoreWandererType
            case nodeName
            case parameter
            //Copy effect range to DamperTarget if it conserns an effect
            case parameterRange
            case midiData
            case nodeSettings
            case dampMode
        }
        
        var trackId: String
        var nodeType: NodeType
//        var scoreWandererType: ScoreWandererType?
//        var midiClipVariation: MidiClipVariations?
        var nodeName: String
        var parameter: String
        var parameterRange: [Double]
        var midiData: MidiData?
        var nodeSettings: NodeSettings?
        var dampMode: DampMode?
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: TargetKeys.self)
            trackId = try container.decode(String.self, forKey: .trackId)
            nodeType = try container.decode(NodeType.self, forKey: .nodeType)
//            scoreWandererType = try container.decodeIfPresent(ScoreWandererType.self, forKey: .scoreWandererType)
            nodeName = try container.decode(String.self, forKey: .nodeName)
            parameter = try container.decode(String.self, forKey: .parameter)
            parameterRange = [0,1]
            midiData = try container.decodeIfPresent(MidiData.self, forKey: .midiData)
            nodeSettings = try container.decodeIfPresent(NodeSettings.self, forKey: .nodeSettings)
            dampMode = try container.decodeIfPresent(DampMode.self, forKey: .dampMode)
        }
        
        //Master track controller init
        init(trackIdString: String, nodeNameString: String, parameterString: String, parameterRangeArray: [Double]) {
            trackId = trackIdString
            nodeName = nodeNameString
            parameter = parameterString
            parameterRange = parameterRangeArray
            nodeType = .master
        }
        
        //Store to file init
        init(
            trackId: String,
            nodeType: NodeType,
//            scoreWandererType: ScoreWandererType?,
//            midiClipVariation: MidiClipVariations?,
            nodeName: String,
            parameter: String,
            parameterRange: [Double],
            midiData: MidiData?,
            nodeSettings: NodeSettings?,
            dampMode: DampMode?
        ) {
            self.trackId = trackId
            self.nodeType = nodeType
//            self.scoreWandererType = scoreWandererType
//            self.midiClipVariation = midiClipVariation
            self.nodeName = nodeName
            self.parameter = parameter
            self.parameterRange = parameterRange
            self.midiData = midiData
            self.nodeSettings = nodeSettings
            self.dampMode = dampMode
        }
        
        //Place holder for ranges from track effects towards controlling part effects
        func getParameterRange() -> [Double] {
            
            return [0,100]
        }
        
        func applyDamp(value: Double) -> Double {
            switch dampMode {
                case .direct: return value
                case .easeInCubic: return EaseInCubicDamper().damp(value: value)
                case .easeInCircular: return EaseInCircularDamper().damp(value: value)
                case .easeInOutCubic: return EaseInOutCubicDamper().damp(value: value)
                default: return value
            }
        }
    }
    
}

extension InstrumentsSet.Track.Part.DamperTarget: Encodable{
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TargetKeys.self)
        try container.encode(trackId, forKey: .trackId)
        try container.encode(nodeType, forKey: .nodeType)
//        try container.encode(scoreWandererType, forKey: .scoreWandererType)
        try container.encode(nodeName, forKey: .nodeName)
        try container.encode(parameter, forKey: .parameter)
        try container.encode(parameterRange, forKey: .parameterRange)
        try container.encode(midiData, forKey: .midiData)
        try container.encode(nodeSettings, forKey: .nodeSettings)
        try container.encode(dampMode, forKey: .dampMode)
    }
}

extension InstrumentsSet.Track.Part.DamperTarget {
    
    enum ScoreWandererType: String, Codable{
        case beatsToMIDIclip
        case valueToMIDIclip
        case rampToMIDIclip
    }
}

extension InstrumentsSet.Track.Part.DamperTarget {
    
    enum MidiClipVariations: String, Codable{
        case any
        case anyButFirst
        case nextLoop
        case nextLoopReverse
        case increaseWithValue
        case levelToMidiClip
        
        //Level increase is located at set -> levelClipControl
    }
}

extension InstrumentsSet.Track.Part.DamperTarget {
    
    enum NodeType: String, Codable {
        case sequencer
        case effect
        case instrument
        case master
    }
    
}

extension InstrumentsSet.Track.Part.DamperTarget {
    
    struct NodeSettings: Decodable, Equatable {
        
        private enum NodeSettingKeys: String, CodingKey {
            case minimalLevel
            case levelPart
            case tempoLow
            case tempoHigh
            case rampSpeed
            case rampSpeedDown
            case coolDownTime
        }
        
        var minimalLevel: Double?
        //Multiplier level, lower is less influence
        var levelPart: Double?
        //Tempo range
        var tempoLow: Double?
        var tempoHigh: Double?
        //Ramp vars
        var rampSpeed: Double?
        var rampSpeedDown: Double?
        //Trigger vars
        //coolDownTime in Duration.beats
        var coolDownTime: Double?
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: NodeSettingKeys.self)
            self.minimalLevel = try container.decodeIfPresent(Double.self, forKey: .minimalLevel)
            self.levelPart = try container.decodeIfPresent(Double.self, forKey: .levelPart)
            self.tempoLow = try container.decodeIfPresent(Double.self, forKey: .tempoLow)
            self.tempoHigh = try container.decodeIfPresent(Double.self, forKey: .tempoHigh)
            self.rampSpeed = try container.decodeIfPresent(Double.self, forKey: .rampSpeed)
            self.rampSpeedDown = try container.decodeIfPresent(Double.self, forKey: .rampSpeedDown)
            self.coolDownTime = try container.decodeIfPresent(Double.self, forKey: .coolDownTime)
        }
        
        //Init for encoding to file
        init(
            minimalLevel: Double?,
            levelPart: Double?,
            tempoLow: Double?,
            tempoHigh: Double?,
            rampSpeed: Double?,
            rampSpeedDown: Double?,
            coolDownTime: Double?
        ) {
            self.minimalLevel = minimalLevel
            self.levelPart = levelPart
            self.tempoLow = tempoLow
            self.tempoHigh = tempoHigh
            self.rampSpeed = rampSpeed
            self.rampSpeedDown = rampSpeedDown
            self.coolDownTime = coolDownTime
        }
    }
}

extension InstrumentsSet.Track.Part.DamperTarget.NodeSettings: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: NodeSettingKeys.self)
        try container.encode(minimalLevel, forKey: .minimalLevel)
        try container.encode(levelPart, forKey: .levelPart)
        try container.encode(tempoLow, forKey: .tempoLow)
        try container.encode(tempoHigh, forKey: .tempoHigh)
        try container.encode(rampSpeed, forKey: .rampSpeed)
        try container.encode(rampSpeedDown, forKey: .rampSpeedDown)
        try container.encode(coolDownTime, forKey: .coolDownTime)
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
