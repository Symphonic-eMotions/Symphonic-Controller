//
//  InstrumentsSet.swift
//  InstrumentsSet
//
//  Created by Mihai Fratu on 31.07.2021.
//

import SwiftUI

struct InstrumentsSet: Identifiable, Decodable {
    
    //Load Instrument set json file
    static func withJSON(_ fileName: String) -> InstrumentsSet? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: "Sets") else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        do {
            let decoded = try JSONDecoder().decode(InstrumentsSet.self, from: data)
            
            return decoded
        }
        catch{
            print("Unexpected error InstrumentsSet withJSON: \(error).")
        }
        return nil
    }

    //Reload json from server
    static func withOnlineJSON(_ url: URL) -> InstrumentsSet? {
        
        guard let data = try? Data(contentsOf: url) else { return nil }
        do {
            let decoded = try JSONDecoder().decode(InstrumentsSet.self, from: data)
            return decoded
        }
        catch{
            print("Unexpected error InstrumentsSet withJSON: \(error).")
        }
        return nil
    }
    
    //Reload json file from documentsfolder
    static func withFileManagerJSON(_ fileName: String) -> InstrumentsSet? {
        
        //Users/fjw/Library/Containers/nl.symphonic-emotions.seproBUILD/Data/Documents/
        let pathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = pathURL[0]
        let jsonFilePath = documentsDirectory.appendingPathComponent(fileName)
        
        guard let data = try? Data(contentsOf: jsonFilePath) else { return nil }
        do {
            let decoded = try JSONDecoder().decode(InstrumentsSet.self, from: data)
            return decoded
        }
        catch{
            print("Unexpected error InstrumentsSet withJSON: \(error).")
        }
        return nil
    }
    
    //This is the write file to documents folder
    static func writeLoadedSet(setName: String, instrumentSet: InstrumentsSet){

        let directoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let documentURL = (directoryURL.appendingPathComponent(setName).appendingPathExtension("json"))
        
        print("\(String(describing: directoryURL))")
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.sortedKeys]
        let data = try? jsonEncoder.encode(instrumentSet)
        do {
            try data?.write(to: documentURL, options: .noFileProtection)
        } catch {
            print("Error...Cannot save data!!!See error:(error.localizedDescription)")
        }
    }
    
    private enum SetKeys: String, CodingKey {
        case name = "setName"
        case filesPath = "setPath"
        case bpm = "setBPM"
        case hasTempo
        case skin
        case timeSignature = "setTimeSignature"
        case masterTrackEffects
        case rows = "gridRows"
        case columns = "gridColumns"
        case levelDurations
        case levelInstruments
        case levelClipControl
        case levelClipControlStartLevel
        case playViewImages
        case tracks = "instrumentsConfig"
    }
    
    var id: String { name }
    let name: String
    //Depricate filesPath, it's not used?
    let filesPath: String
    //Sequencer objects variables
    var bpm: Double
    let hasTempo: Bool
    var skin: Skin
    let timeSignature: Int
    //Master effect rack group
    let masterTrackEffects: [Track.Effect]
    //The row and colums used in imageDifference
    let rows: Int
    let columns: Int
    //Level variables
    let levelDurations: [Int]
    let levelInstruments: [[String]]
    //Level controls location within midi file
    //TODO: this needs to be rewritten
    let levelClipControl: Bool?
    let levelClipControlStartLevel: Int?
    //Skins
    let playViewImages: PlayViewImages?
    
    //Tracks
    var tracks: [Track]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SetKeys.self)
        name = try container.decode(String.self, forKey: .name)
        filesPath = try container.decode(String.self, forKey: .filesPath)
        bpm = try container.decode(Double.self, forKey: .bpm)
        hasTempo = try container.decode(Bool.self, forKey: .hasTempo)
        
        if let skinRaw = try container.decodeIfPresent(Skin.self, forKey: .skin){
            skin = skinRaw
        }
        else{
            skin = Skin(name: .swiftUI, instruments: [])
        }
        
        timeSignature = try container.decode(Int.self, forKey: .timeSignature)
        let masterTrackEffectsRaw = try container.decode([Track.Effect].self, forKey: .masterTrackEffects)
        masterTrackEffects = masterTrackEffectsRaw
        rows = try container.decode(Int.self, forKey: .rows)
        columns = try container.decode(Int.self, forKey: .columns)
        levelDurations = try container.decode([Int].self, forKey: .levelDurations)
        levelInstruments = try container.decode([[String]].self, forKey: .levelInstruments)
        levelClipControl = try container.decodeIfPresent(Bool.self, forKey: .levelClipControl)
        levelClipControlStartLevel = try container.decodeIfPresent(Int.self, forKey: .levelClipControlStartLevel)
        playViewImages = try container.decodeIfPresent(PlayViewImages.self, forKey: .playViewImages)
        tracks = try container.decode([Track].self, forKey: .tracks)
    }
    
    //Init for writing a copy with live values
    init(
        name: String,
        filesPath: String,
        bpm: Double,
        hasTempo: Bool,
        skin: Skin,
        timeSignature: Int,
        masterTrackEffects: [Track.Effect],
        rows: Int,
        columns: Int,
        levelDurations: [Int],
        levelInstruments: [[String]],
        levelClipControl: Bool?,
        levelClipControlStartLevel: Int?,
        playViewImages: PlayViewImages?,
        tracks: [Track]
    ) {
        self.name = name
        self.filesPath = filesPath
        self.bpm = bpm
        self.hasTempo = hasTempo
        self.skin = skin
        self.timeSignature = timeSignature
        //TODO: new values from state object
        self.masterTrackEffects = masterTrackEffects
        
        self.rows = rows
        self.columns = columns
        self.levelDurations = levelDurations
        self.levelInstruments = levelInstruments
        self.levelClipControl = levelClipControl
        self.levelClipControlStartLevel = levelClipControlStartLevel
        self.playViewImages = playViewImages
        self.tracks = tracks
    }
    
    //For master track effetcs
    func effect(for effectType: Track.Effect.EffectType) -> Track.Effect? {
        masterTrackEffects.first { $0.effectType == effectType }
    }
    
    func track(for id: String) -> Track? {
        tracks.first { $0.id == id }
    }
    
    func instrumentInLevel(_ level: Double, _ Instrument: String) -> Bool {
        
        let levelInt = Int(level)
        let levelArray = levelInstruments[levelInt]
        if levelArray.contains(Instrument){
            return true
        }
        return false
    }
}

extension InstrumentsSet: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SetKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(filesPath, forKey: .filesPath)
        try container.encode(bpm, forKey: .bpm)
        try container.encode(hasTempo, forKey: .hasTempo)
        try container.encode(timeSignature, forKey: .timeSignature)
        try container.encode(masterTrackEffects, forKey: .masterTrackEffects)
        try container.encode(rows, forKey: .rows)
        try container.encode(columns, forKey: .columns)
        try container.encode(levelDurations, forKey: .levelDurations)
        try container.encode(levelInstruments, forKey: .levelInstruments)
        try container.encode(levelClipControl, forKey: .levelClipControl)
        try container.encode(levelClipControlStartLevel, forKey: .levelClipControlStartLevel)
        try container.encode(tracks, forKey: .tracks)
    }
}
