//
//  InstrumentsSet.swift
//  InstrumentsSet
//
//  Created by Mihai Fratu on 31.07.2021.
//

import SwiftUI

struct InstrumentsSet: Identifiable, Decodable {
    
    enum FileSource: String, Codable {
        case bundle
        case user
    }
    
    //Load Instrument set json file
    static func withJSON(_ fileName: String) -> InstrumentsSet? {
        guard let url = Bundle.main.url(
            forResource: fileName,
            withExtension: nil,
            subdirectory: "Sets"
        ) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        do {
            let decoded = try JSONDecoder().decode(InstrumentsSet.self, from: data)
            
//            print("withJSON Loaded: \(fileName)")
            
            return decoded
        }
        catch{
            print("Unexpected error InstrumentsSet withJSON: \(error).")
            print("In file \(fileName)")
        }
        return nil
    }

    //Reload json from server
    static func withOnlineJSON(_ url: URL) -> InstrumentsSet? {
        
        guard let data = try? Data(contentsOf: url) else { return nil }
        do {
            let decoded = try JSONDecoder().decode(InstrumentsSet.self, from: data)
            
//            print("withOnlineJSON Loaded: \(url.absoluteString)")
            
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
            
//            print("withFileManagerJSON Loaded: \(fileName)")
            
            return decoded
        }
        catch{
            print("Unexpected error InstrumentsSet withFileManagerJSON: \(error).")
            print("In file \(fileName)")
        }
        return nil
    }
    
    //This is the write file to documents folder
    static func writeLoadedSet(setName: String, instrumentSet: InstrumentsSet){

        let directoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let documentURL = (directoryURL.appendingPathComponent(setName).appendingPathExtension("json"))
        
        print("writeLoadedSet \(String(describing: directoryURL))")
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.sortedKeys,.prettyPrinted]
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
        case published
        case semVersion
        case fileGroup
        case filesPath = "setPath"
        case imagePrefix
        case userViews
        case bpm = "setBPM"
        case hasTempo
        case skin
        case timeSignature = "setTimeSignature"
        case masterTrackEffects
        case rows = "gridRows"
        case columns = "gridColumns"
        case levels = "levelDurations"
        case tracks = "instrumentsConfig"
        case setEffects
    }
    
    var id: String { name }
    let name: String
    let customName: String
    let published: Bool?
    let semVersion: String?
    var fileGroup: FileGroup?
    let filesPath: String
    let imagePrefix: String
    var userViews: [UserView]
    //Sequencer objects variables
    var bpm: Double
    let hasTempo: Bool
    let timeSignature: Int
    //Master effect rack group
    let masterTrackEffects: [Track.Effect]
    //The row and colums used in imageDifference
    internal let rows: Int
    internal let columns: Int
    //Level duration keeps the amount of levels with an int
    //Duration could be refectored to aditional level speed per level
    let levels: [Int]
    let setEffects: [SetEffect]?
    //Tracks
    var tracks: [Track]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SetKeys.self)
        name = try container.decode(String.self, forKey: .name)
        customName = try container.decodeIfPresent(String.self, forKey: .customName) ?? ""
        published = try container.decodeIfPresent(Bool.self, forKey: .published)
        semVersion = try container.decodeIfPresent(String.self, forKey: .semVersion) ?? "1.0.0"
        fileGroup = try container.decodeIfPresent(FileGroup.self, forKey: .fileGroup)
        filesPath = try container.decode(String.self, forKey: .filesPath)
        imagePrefix = try container.decodeIfPresent(String.self, forKey: .imagePrefix) ?? "Introductie"
        userViews = try container.decodeIfPresent([UserView].self, forKey: .userViews) ?? [.playView]
        bpm = try container.decode(Double.self, forKey: .bpm)
        hasTempo = try container.decode(Bool.self, forKey: .hasTempo)
        timeSignature = try container.decode(Int.self, forKey: .timeSignature)
        let masterTrackEffectsRaw = try container.decode([Track.Effect].self, forKey: .masterTrackEffects)
        masterTrackEffects = masterTrackEffectsRaw
        rows = try container.decode(Int.self, forKey: .rows)
        columns = try container.decode(Int.self, forKey: .columns)
        levels = try container.decode([Int].self, forKey: .levels)
        setEffects = try container.decodeIfPresent([SetEffect].self, forKey: .setEffects)
        tracks = try container.decode([Track].self, forKey: .tracks)
    }
    
    //Init for writing a copy with live values
    init(
        name: String,
        customName: String,
        published: Bool,
        semVersion: String,
        fileGroup: FileGroup,
        filesPath: String,
        imagePrefix: String,
        userViews: [UserView],
        bpm: Double,
        hasTempo: Bool,
        timeSignature: Int,
        masterTrackEffects: [Track.Effect],
        rows: Int,
        columns: Int,
        levels: [Int],
        setEffects: [SetEffect],
        tracks: [Track]
    ) {
        self.name = name
        self.customName = customName
        self.published = published
        self.semVersion = semVersion
        self.fileGroup = fileGroup
        self.filesPath = filesPath
        self.imagePrefix = imagePrefix
        self.userViews = userViews
        self.bpm = bpm
        self.hasTempo = hasTempo
        self.timeSignature = timeSignature
        //TODO: new values from state object
        self.masterTrackEffects = masterTrackEffects
        
        self.rows = rows
        self.columns = columns
        self.levels = levels
        self.setEffects = setEffects
        self.tracks = tracks
    }
    
    func title() -> String {
        if self.customName != "" {
            return self.customName
        }
        else{
            return self.name
        }
    }
    
    //For master track effetcs
    func effect(for effectType: Track.Effect.EffectType) -> Track.Effect? {
        masterTrackEffects.first { $0.effectType == effectType }
    }
    
    func track(for id: String) -> Track? {
        tracks.first { $0.id == id }
    }
    
    //For global index
    struct Index {
        let row: Int
        let column: Int
    }
}

extension InstrumentsSet: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SetKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(customName, forKey: .customName)
        try container.encode(published, forKey: .published)
        try container.encode(semVersion, forKey: .semVersion)
        try container.encode(fileGroup, forKey: .fileGroup)
        try container.encode(filesPath, forKey: .filesPath)
        try container.encode(imagePrefix, forKey: .imagePrefix)
        try container.encode(userViews, forKey: .userViews)
        try container.encode(bpm, forKey: .bpm)
        try container.encode(hasTempo, forKey: .hasTempo)
        try container.encode(timeSignature, forKey: .timeSignature)
        try container.encode(masterTrackEffects, forKey: .masterTrackEffects)
        try container.encode(rows, forKey: .rows)
        try container.encode(columns, forKey: .columns)
        try container.encode(levels, forKey: .levels)
        try container.encode(setEffects, forKey: .setEffects)
        try container.encode(tracks, forKey: .tracks)
    }
}
