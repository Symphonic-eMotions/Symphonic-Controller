//
//  SetEffetc.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 23/03/2024.
//

import Foundation

enum EffectType: String, Codable {
    
    case rewind
    case applause
}

struct ADSREnvelope: Codable {
    
    var attack: Double
    var decay: Double
    var sustain: Double
    var release: Double
        
    init(
        attack: Double = 0.1,
        decay: Double = 0.2,
        sustain: Double = 0.9,
        release: Double = 0.3)
    {
        self.attack = attack
        self.decay = decay
        self.sustain = sustain
        self.release = release
    }
}

struct AudioFileInfo: Codable {
    
    var fileName: String
    var fileExtension: String
    var lengthInBeats: [Double]
    
    init(
        fileName: String,
        fileExtension: String,
        lengthInBeats: [Double]
    ) {
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.lengthInBeats = lengthInBeats
    }
}


extension InstrumentsSet {
    
    struct SetEffect: Codable {
        
        private enum SetEffetcKeys: String, CodingKey {
            case id
            case effectType
            case fileSource
            case audioFiles
            case adsrEnvelope = "adsr"
        }
        
        var id: UUID
        var effectType: EffectType
        var fileSource: FileSource
        var audioFiles: [AudioFileInfo]
        var adsrEnvelope: ADSREnvelope
        
        init(
            id: UUID = UUID(),
            effectType: EffectType = .applause,
            fileSource: FileSource = .bundle,
            audioFiles: [AudioFileInfo] = [AudioFileInfo(
                fileName: "Applause01",
                fileExtension: "wav",
                lengthInBeats: [64]
            )],
            adsrEnvelope: ADSREnvelope = ADSREnvelope()
        ) {
            self.id = id
            self.effectType = effectType
            self.fileSource = fileSource
            self.audioFiles = audioFiles
            self.adsrEnvelope = adsrEnvelope
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: SetEffetcKeys.self)
            id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
            effectType = try container.decode(EffectType.self, forKey: .effectType)
            fileSource = try container.decode(FileSource.self, forKey: .fileSource)
            audioFiles = try container.decode([AudioFileInfo].self, forKey: .audioFiles)
            adsrEnvelope = try container.decode(ADSREnvelope.self, forKey: .adsrEnvelope)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: SetEffetcKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(effectType, forKey: .effectType)
            try container.encode(fileSource, forKey: .fileSource)
            try container.encode(audioFiles, forKey: .audioFiles)
            try container.encode(adsrEnvelope, forKey: .adsrEnvelope)
        }
    }
}
