//
//  DamperTarget.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 20/07/2023.
//

import Foundation

extension InstrumentsSet.Track.Part {
    
    struct DamperTarget: Decodable, Equatable {
        
        internal enum TargetKeys: String, CodingKey {
            case trackId
            case nodeType
            case nodeName
            case parameter
            //Copy effect range to DamperTarget if it conserns an effect
            case parameterRange
            case parameterInversed
            case midiData
            case nodeSettings
            case dampMode
        }
        
        var trackId: String
        var nodeType: NodeType
        var nodeName: String
        var parameter: String
        var parameterRange: [Double]
        var parameterInversed: Bool
        var midiData: MidiData?
        var nodeSettings: NodeSettings?
        var dampMode: DampMode?
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: TargetKeys.self)
            trackId = try container.decode(String.self, forKey: .trackId)
            nodeType = try container.decode(NodeType.self, forKey: .nodeType)
            nodeName = try container.decode(String.self, forKey: .nodeName)
            parameter = try container.decode(String.self, forKey: .parameter)
            parameterRange = [0,1]
            parameterInversed = try container.decodeIfPresent(Bool.self, forKey: .parameterInversed) ?? false
            midiData = try container.decodeIfPresent(MidiData.self, forKey: .midiData)
            nodeSettings = try container.decodeIfPresent(NodeSettings.self, forKey: .nodeSettings)
            dampMode = try container.decodeIfPresent(DampMode.self, forKey: .dampMode)
        }
        
        //Master track controller init
        init(
            trackIdString: String,
            nodeNameString: String,
            parameterString: String,
            parameterRangeArray: [Double],
            parameterInversedBool: Bool
        ) {
            trackId = trackIdString
            nodeName = nodeNameString
            parameter = parameterString
            parameterRange = parameterRangeArray
            nodeType = .master
            parameterInversed = parameterInversedBool
        }
        
        //Store to file init
        init(
            trackId: String,
            nodeType: NodeType,         //targetType
            nodeName: String,           //targetNameEffect
            parameter: String,          //parameter
            parameterRange: [Double],
            parameterInversed: Bool,
            midiData: MidiData?,
            nodeSettings: NodeSettings?,
            dampMode: DampMode?
        ) {
            self.trackId = trackId
            self.nodeType = nodeType
            self.nodeName = nodeName
            self.parameter = parameter
            self.parameterRange = parameterRange
            self.parameterInversed = parameterInversed
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
        try container.encode(nodeName, forKey: .nodeName)
        try container.encode(parameter, forKey: .parameter)
        try container.encode(parameterRange, forKey: .parameterRange)
        try container.encode(parameterInversed, forKey: .parameterInversed)
        try container.encode(midiData, forKey: .midiData)
        try container.encode(nodeSettings, forKey: .nodeSettings)
        try container.encode(dampMode, forKey: .dampMode)
    }
}

extension InstrumentsSet.Track.Part.DamperTarget {
    
    enum NodeType: String, Codable, CaseIterable {
        case sequencer
        case effect
        case instrument
        case master
        
        var description: String {
            switch self{
            case .sequencer:
                return "Sequencer"
            case .effect:
                return "Effect"
            case .instrument:
                return "Instrument"
            case .master:
                return "Master"
            }
        }
    }
}

extension InstrumentsSet.Track.Part.DamperTarget {
    
    struct NodeSettings: Decodable, Equatable {
        
        private enum NodeSettingKeys: String, CodingKey {
            case minimalLevel
            case rampSpeed
            case rampSpeedDown
            case coolDownTime
        }
        
        var minimalLevel: Double?
        //Ramp vars
        var rampSpeed: Double?
        var rampSpeedDown: Double?
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: NodeSettingKeys.self)
            self.minimalLevel = try container.decodeIfPresent(Double.self, forKey: .minimalLevel)
            self.rampSpeed = try container.decodeIfPresent(Double.self, forKey: .rampSpeed)
            self.rampSpeedDown = try container.decodeIfPresent(Double.self, forKey: .rampSpeedDown)
        }
        
        //Init for encoding to file
        init(
            minimalLevel: Double?,
            rampSpeed: Double?,
            rampSpeedDown: Double?
        ) {
            self.minimalLevel = minimalLevel
            self.rampSpeed = rampSpeed
            self.rampSpeedDown = rampSpeedDown
        }
    }
}

extension InstrumentsSet.Track.Part.DamperTarget.NodeSettings: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: NodeSettingKeys.self)
        try container.encode(minimalLevel, forKey: .minimalLevel)
        try container.encode(rampSpeed, forKey: .rampSpeed)
        try container.encode(rampSpeedDown, forKey: .rampSpeedDown)
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
