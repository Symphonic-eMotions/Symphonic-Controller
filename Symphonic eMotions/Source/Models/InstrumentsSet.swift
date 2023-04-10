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
        case customName
        case filesPath = "setPath"
        case bpm = "setBPM"
        case hasTempo
        case skin
        case timeSignature = "setTimeSignature"
        case masterTrackEffects
        case rows = "gridRows"
        case columns = "gridColumns"
        case levelSpeed
        case levels = "levelDurations"
        case playViewImages
        case tracks = "instrumentsConfig"
    }
    
    var id: String { name }
    let name: String
    //User editable name
    let customName: String
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
    let levelSpeed: Double
    //Level duration keeps the amount of levels with an int
    //Duration could be refectored to aditional level speed per level
    let levels: [Int]
    
    //Skins
    let playViewImages: PlayViewImages?
    
    //Tracks
    var tracks: [Track]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SetKeys.self)
        name = try container.decode(String.self, forKey: .name)
        customName = try container.decodeIfPresent(String.self, forKey: .customName) ?? ""
        filesPath = try container.decode(String.self, forKey: .filesPath)
        bpm = try container.decode(Double.self, forKey: .bpm)
        hasTempo = try container.decode(Bool.self, forKey: .hasTempo)
        timeSignature = try container.decode(Int.self, forKey: .timeSignature)
        let masterTrackEffectsRaw = try container.decode([Track.Effect].self, forKey: .masterTrackEffects)
        masterTrackEffects = masterTrackEffectsRaw
        rows = try container.decode(Int.self, forKey: .rows)
        columns = try container.decode(Int.self, forKey: .columns)
        levelSpeed = try container.decode(Double.self, forKey: .levelSpeed)
        levels = try container.decode([Int].self, forKey: .levels)
        playViewImages = try container.decodeIfPresent(PlayViewImages.self, forKey: .playViewImages)
        tracks = try container.decode([Track].self, forKey: .tracks)
        if let skinRaw = try container.decodeIfPresent(Skin.self, forKey: .skin){
            skin = skinRaw
        }
        else{
            
            //We go Skinning!
            let instruments = [InstrumentsSet.Skin.Instrument(
                shape: "circle",
                name: "AudioA",
                image: "AudioFile1",
                color: .white
                //UIColor(red: 151/255, green: 71/255, blue: 255/255, alpha: 1)
            ),InstrumentsSet.Skin.Instrument(
                shape: "circle",
                name: "AudioB",
                image: "AudioFile1",
                color: .white
                //UIColor(red: 124/255, green: 177/255, blue: 255/255, alpha: 1)
            ),InstrumentsSet.Skin.Instrument(
                shape: "circle",
                name: "AudioC",
                image: "AudioFile1",
                color: .white
                //UIColor(red: 0, green: 207/255, blue: 58/255, alpha: 1)
            ),InstrumentsSet.Skin.Instrument(
                shape: "circle",
                name: "AudioD",
                image: "AudioFile1",
                color: .white
                //UIColor(red: 0, green: 207/255, blue: 58/255, alpha: 1)
            )]
            
            //Here we need to load the initial Skset
            //default name switches SetInfoLocalState to SwiftUI
            skin = Skin(name: "default", instruments:instruments)
        }
    }
    
    //Init for writing a copy with live values
    init(
        name: String,
        customName: String,
        filesPath: String,
        bpm: Double,
        hasTempo: Bool,
        skin: Skin,
        timeSignature: Int,
        masterTrackEffects: [Track.Effect],
        rows: Int,
        columns: Int,
        levelSpeed: Double,
        levels: [Int],
        playViewImages: PlayViewImages?,
        tracks: [Track]
    ) {
        self.name = name
        self.customName = customName
        self.filesPath = filesPath
        self.bpm = bpm
        self.hasTempo = hasTempo
        self.skin = skin
        self.timeSignature = timeSignature
        //TODO: new values from state object
        self.masterTrackEffects = masterTrackEffects
        
        self.rows = rows
        self.columns = columns
        self.levelSpeed = levelSpeed
        self.levels = levels
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
    
//    func instrumentInLevel(_ level: Double, _ Instrument: String) -> Bool {
//        
//        let levelInt = Int(level)
//        let levelArray = levelInstruments[levelInt]
//        if levelArray.contains(Instrument){
//            return true
//        }
//        return false
//    }
}

extension InstrumentsSet: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SetKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(customName, forKey: .customName)
        try container.encode(filesPath, forKey: .filesPath)
        try container.encode(bpm, forKey: .bpm)
        try container.encode(hasTempo, forKey: .hasTempo)
        try container.encode(timeSignature, forKey: .timeSignature)
        try container.encode(masterTrackEffects, forKey: .masterTrackEffects)
        try container.encode(rows, forKey: .rows)
        try container.encode(columns, forKey: .columns)
        try container.encode(levelSpeed, forKey: .levelSpeed)
        try container.encode(levels, forKey: .levels)
        try container.encode(tracks, forKey: .tracks)
        try container.encode(skin, forKey: .skin)
    }
}
