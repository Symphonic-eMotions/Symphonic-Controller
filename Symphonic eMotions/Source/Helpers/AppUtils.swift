//
//  AppUtils.swift
//  AppUtils
//
//  Created by Mihai Fratu on 31.07.2021.
//

import Foundation
import SwiftUI
import AudioKit
import OrderedCollections

final class AppUtils {
    
    private static let appStorage = UserDefaults.standard
    static var setUrl: String  {
        appStorage.string(forKey: "currentUrl") ?? "AppUtils"
    }
    
    static func documentDirectory() -> URL {
      let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
      return documentsDirectory
    }
    
    static func copyOverwriteFile(from sourceURL: URL, to destinationURL: URL) throws {
        
        let fileManager = FileManager.default

        // Check if the source file exists
        guard fileManager.fileExists(atPath: sourceURL.path) else {
            throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Source file doesn't exist"])
        }

        // Check if the destination folder exists, if not create it
        let destinationFolderURL = destinationURL.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: destinationFolderURL.path) {
            try fileManager.createDirectory(at: destinationFolderURL, withIntermediateDirectories: true, attributes: nil)
        }

        // Check if the destination file already exists, if yes remove it
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }

        // Copy the file from source to destination
        try fileManager.copyItem(at: sourceURL, to: destinationURL)
    }
    
    //MARK: Instrument Set Loading
    static func loadInstrumentSet(json: String) -> InstrumentsSet {
        
        guard let instrumentSet = InstrumentsSet.withJSON(json) else {
            
            print("Error loading instrument set from JSON: \(json)")
            
            //The name "No Set" is used to prevent loading
            return InstrumentsSet(name: "No Set", customName: "", published: false, fileGroup: .none, filesPath: "", defaultSkin: .none, bpm: 120, hasTempo: true, skin: InstrumentsSet.Skin(name: "skin", instruments: []), timeSignature: 4, masterTrackEffects: [], rows: 1, columns: 1, levelSpeed: 0.5, levels: [0], tracks: [])
        }
        return instrumentSet
    }
    
    static func loadURLServerInstrumentSet(urlServer: String) -> InstrumentsSet? {
        
        let urlServerURL = URL(string: urlServer)
        
        let instrumentSet = InstrumentsSet.withOnlineJSON(urlServerURL!)
        
        return instrumentSet ?? nil
    }
    
    static func loadSavedInstrumentSet(fileName: String) -> InstrumentsSet? {
        
        guard let instrumentSet = InstrumentsSet.withFileManagerJSON(fileName) else {
            preconditionFailure()
        }
        return instrumentSet
    }
    
    //MARK: Playists
    static func createPlayListFolders() {
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let bundleURL = Bundle.main.bundleURL

        let lists = BuildSettings.Playlists.allCases
        let partOfList = lists.filter({$0 != .none})

        // Loop through all the enum cases and check if a folder with that name exists
        for playlist in partOfList {
            let playlistURL = documentsURL.appendingPathComponent(playlist.rawValue)
            let bundlePlaylistURL = bundleURL.appendingPathComponent(playlist.rawValue)

            if !fileManager.fileExists(atPath: playlistURL.path) {
                // Folder doesn't exist, create it
                try? fileManager.createDirectory(at: playlistURL, withIntermediateDirectories: true, attributes: nil)
            }

            do {
                // Get the content of the playlist folder in the bundle
                let playlistContent = try fileManager.contentsOfDirectory(at: bundlePlaylistURL, includingPropertiesForKeys: nil)

                // Copy each item in the playlist folder to the new playlist folder in the Documents directory
                for item in playlistContent {
                    let destinationURL = playlistURL.appendingPathComponent(item.lastPathComponent)
                    if !fileManager.fileExists(atPath: destinationURL.path) {
                        try fileManager.copyItem(at: item, to: destinationURL)
                    }
                }
            } catch {
                print("Error copying playlist files: \(error)")
            }
        }
    }

    
    //MARK: Set setSetings
    // - Structure to mutate and save as Instrument Set
    static func setSettings(
        instrumentSet: InstrumentsSet
    ) -> SetSettings {
        
        let masterEffects: OrderedDictionary<Int,MasterTrackEffectsSettings> = masterTrackSettings(instrumentSet: instrumentSet)
        
        let skin: InstrumentsSet.Skin = instrumentSet.skin
        var trackIndex: Int = 0
        var tracks: OrderedDictionary<String,TrackSettings> = [:]
        let tracksLoaded = instrumentSet.tracks
        //How big is this grid
        let cells = instrumentSet.columns * instrumentSet.rows
        //Keep track of partNumber for variations track/instrument Color...
        var partNumber: Int = 0
        //Loop trhough the loaded tracks
        for trackLoaded in tracksLoaded {
            
            //First set parts of this track
            partNumber = 0
            var parts: OrderedDictionary<String, PartSettings> = [:]
            let firstAreaOfInterest: [Int] = trackLoaded.parts.first!.areaOfInterest
            for partLoaded in trackLoaded.parts {
                
                let part = PartSettings(
                    partId: partLoaded.id,
                    partName: partLoaded.instrumentPartName,
                    partNumber: partNumber,
                    rampUp: partLoaded.damperTarget.nodeSettings!.rampSpeed!,
                    rampDown: partLoaded.damperTarget.nodeSettings!.rampSpeedDown!,
                    minimalLevel: partLoaded.damperTarget.nodeSettings!.minimalLevel ?? 0.1,
                    areaOfInterest: partLoaded.areaOfInterest,
                    areaOfInterestColor: self.getPartColors(
                        trackColor: trackLoaded.instrumentColor,
                        areaOfInterest: partLoaded.areaOfInterest
                    ),
                    damperTarget: partLoaded.damperTarget,
                    dontDrawVisual: partLoaded.dontDrawVisual ?? false
                )
                parts[partLoaded.id] = part
                partNumber += 1
            }
            //Midi clips from file mapping
            var loopsToLevel:[Int] = trackLoaded.midiFiles?.first!.loopsToLevel ?? []
            if loopsToLevel.count != instrumentSet.levels.count {
                //We've got another amount of levels, correct
                loopsToLevel = Array(repeating: 0, count: instrumentSet.levels.count)
            }
            
            var loopsToGrid:[Int] = trackLoaded.midiFiles?.first?.loopsToGrid ?? []
            if loopsToGrid.count != cells {
                //We have a another amount of cells, correct
                loopsToGrid = Array(repeating: 0, count: cells)
            }
            
            //Note numbers from interface mapping
            //Default to Midi note C2 -> 48
            let c2: Int = 48
            var midiGroup:[Int] = trackLoaded.midiGroup ?? [c2]
            //Cannot be empty for midi file source
            if midiGroup.count == 0 { midiGroup = [c2] }
            var notesToLevel:[Int] = trackLoaded.notesToLevel ?? []
            if notesToLevel.count != instrumentSet.levels.count {
                notesToLevel = Array(repeating: midiGroup.min()!, count: instrumentSet.levels.count)
            }
            
            var notesToGrid:[Int] = trackLoaded.notesToGrid ?? []
            if notesToGrid.count != cells {
                //We have a another amount of cells, reset
                notesToGrid = Array(repeating: midiGroup.min()!, count: cells)
            }
            
            let track = TrackSettings(
                trackId: trackLoaded.id,
                trackIndex: trackIndex,
                trackName: trackLoaded.instrumentName,
                noteSource: trackLoaded.noteSource ?? .midiFile,
                startType: trackLoaded.startType,
                trackType: trackLoaded.trackType ?? .variationByPosition,
                instrumentVolume: trackLoaded.volume,
                instrumentColor: trackLoaded.instrumentColor,
                midiFile: trackLoaded.midiFiles!.first!.fileName,
                
                midiGroup: midiGroup,
                notesToGrid: notesToGrid,
                notesToGridMapped: AppUtils.areaOfInterestGridMapped(
                    areaOfInterest: firstAreaOfInterest,
                    cellsToGrid: notesToGrid
                ),
                notesToLevel: notesToLevel,
                notesSequenceType:  trackLoaded.notesSequenceType ?? .firstNote,
                loopLength: (trackLoaded.midiFiles?.first!.loopLength)!,
                loopsToLevel: loopsToLevel,
                loopsToGrid: loopsToGrid,
                loopsToGridMapped: AppUtils.areaOfInterestGridMapped(
                    areaOfInterest: firstAreaOfInterest,
                    cellsToGrid: loopsToGrid
                ),
                levels: trackLoaded.levels,
                parts: parts)
            
            tracks[trackLoaded.id] = track
            trackIndex += 1
        }
        let setSettings = SetSettings(
            setName: instrumentSet.name,
            customName: instrumentSet.customName,
            published: instrumentSet.published ?? false,
            fileGroup: instrumentSet.fileGroup ?? .none,
            setURL: URL(setUrl),
            hasTempo: instrumentSet.hasTempo,
            defaultSkin: instrumentSet.defaultSkin ?? .swiftUI,
            rows: instrumentSet.rows,
            columns: instrumentSet.columns,
            levelSpeed: instrumentSet.levelSpeed,
            levels: instrumentSet.levels,
            bpm: instrumentSet.bpm,
            masterEffects: masterEffects,
            tracks: tracks,
            skins: skin
        )
        
        return setSettings
    }
    
    //MARK: Write Instrument Set
    //Write set settings to file structure and return used file name
    static func createWorkingFile(
        setSettings: SetSettings,
        instrumentSet: InstrumentsSet,
        duplicateLastTrack: Bool,
        asNewFile: Bool
    ) -> String {
        
        var fileName: String!
        
        //Write over last opened file.
        if !asNewFile {
            
            //Strip extension .json
            let noExtension = setSettings.setURL.deletingPathExtension()
            let parentDirectoryName = noExtension.deletingLastPathComponent().lastPathComponent
            //Save to playlist
            if BuildSettings.Playlists(rawValue: parentDirectoryName) != nil {
                fileName = "\(parentDirectoryName)/\(noExtension.lastPathComponent)"
            }
            else{
                fileName = noExtension.lastPathComponent
            }
        }
        //New file name
        else{
            let setName = instrumentSet.name
            let timestammp = NSDate().timeIntervalSince1970
            fileName = setName + "-timestamp-\(timestammp)"
        }
        
        let storeInstrumentSet: InstrumentsSet = createInstrumentSet(
            setSettings: setSettings,
            instrumentSet: instrumentSet,
            duplicateLastTrack: duplicateLastTrack
        )
        
        InstrumentsSet.writeLoadedSet(setName: fileName, instrumentSet: storeInstrumentSet)
        
        return fileName
    }
    
    //Instrument set from current state
    static func createInstrumentSet(
        setSettings: SetSettings,
        instrumentSet: InstrumentsSet,
        duplicateLastTrack: Bool
    ) -> InstrumentsSet {
        
        //Get modified master track effect settings and store them in encodable format
        //Modified data store in: setSettings.masterEffects
        let currentMasterEffects: [InstrumentsSet.Track.Effect] = instrumentSet.masterTrackEffects
        var modifiedMasterEffects: [InstrumentsSet.Track.Effect] = []
        for (effectIndex, currentMasterEffect) in currentMasterEffects.enumerated() {
            
            let effectType: InstrumentsSet.Track.Effect.EffectType = currentMasterEffect.effectType
            var parameters: [ValueAndRange] = []
            
            let parameterStrings: [String] = currentMasterEffect.effectVars(effectType: effectType)
            for (parameterIndex, parameterString) in parameterStrings.enumerated() {
                let loadedValueAndRange = currentMasterEffect.valueAndRanges(parameter: parameterString)!
                let loadedRange = loadedValueAndRange.range
                let storedValue = setSettings.masterEffects[effectIndex]?.parameters[parameterIndex]!.value
                parameters.append( ValueAndRange(value: AUValue( storedValue! ), range: loadedRange) )
            }
            
            let modifiedMasterEffect = InstrumentsSet.Track.Effect(effectType: effectType, parameters: parameters)
            modifiedMasterEffects.append(modifiedMasterEffect)
        }
        
        //Replace loaded data with modified data within tracks
        // - rampSpeed (InstrumentsSet.Track.Part.DamperTarget.NodeSettings.rampSpeed)
        // - rampSpeedDown (InstrumentsSet.Track.Part.DamperTarget.NodeSettings.rampSpeedDown)
        // - volume (InstrumentsSet.Track.volume)
        // - instrumentColor (InstrumentsSet.Track.instrumentColor)
        // - areaOfInterest (InstrumentsSet.Track.Part.areaOfInterest
        var storeTracks: [InstrumentsSet.Track] = []
        for track in instrumentSet.tracks {
            
            var storeParts: [InstrumentsSet.Track.Part] = []
            for part in track.parts {
                
                let storeNodeSettings = InstrumentsSet.Track.Part.DamperTarget.NodeSettings(
                    minimalLevel: setSettings.tracks[track.trackId]!.parts[part.id]!.minimalLevel,
                    levelPart: part.damperTarget.nodeSettings?.levelPart,
                    tempoLow: part.damperTarget.nodeSettings?.tempoLow,
                    tempoHigh: part.damperTarget.nodeSettings?.tempoHigh,
                    rampSpeed: setSettings.tracks[track.trackId]!.parts[part.id]!.rampUp,
                    rampSpeedDown: setSettings.tracks[track.trackId]!.parts[part.id]!.rampDown,
                    coolDownTime: part.damperTarget.nodeSettings?.coolDownTime
                )
                
                let storeDamperTarget = InstrumentsSet.Track.Part.DamperTarget(
                    trackId: part.damperTarget.trackId,
                    nodeType: part.damperTarget.nodeType,
                    nodeName: part.damperTarget.nodeName,
                    parameter: part.damperTarget.parameter,
                    parameterRange: part.damperTarget.parameterRange,
                    midiData: part.damperTarget.midiData,
                    nodeSettings: storeNodeSettings,
                    dampMode: part.damperTarget.dampMode
                )
                
                let storePart = InstrumentsSet.Track.Part(
                    instrumentPartName: part.instrumentPartName,
                    areaOfInterest: setSettings.tracks[track.trackId]!.parts[part.id]!.areaOfInterest,
                    dontDrawVisual: part.dontDrawVisual,
                    damperTarget: storeDamperTarget
                )
                storeParts.append(storePart)
            }
            
            let midiFiles = [InstrumentsSet.Track.MidiFile(
                fileName: setSettings.tracks[track.trackId]!.midiFile,
                fileExtension: track.midiFiles![0].fileExtension,
                loopLength: setSettings.tracks[track.trackId]!.loopLength,
                loopsToLevel: setSettings.tracks[track.trackId]!.loopsToLevel,
                loopsToGrid: setSettings.tracks[track.trackId]!.loopsToGrid
            )]
            
            var storeTrack = InstrumentsSet.Track(
                id: track.id,
                trackId: track.trackId,
                muted: track.muted,
                instrumentType: track.instrumentType,
                noteSource: setSettings.tracks[track.trackId]!.noteSource,
                startType: setSettings.tracks[track.trackId]!.startType,
                trackType: setSettings.tracks[track.trackId]!.trackType,
                instrumentName: track.instrumentName,
                instrumentColor: setSettings.tracks[track.trackId]!.instrumentColor,
                volume: setSettings.tracks[track.trackId]!.instrumentVolume,
                midiFiles: midiFiles,
                midiGroup: setSettings.tracks[track.trackId]!.midiGroup,
                notesToGrid: setSettings.tracks[track.trackId]!.notesToGrid,
                notesToLevel: setSettings.tracks[track.trackId]!.notesToLevel,
                notesSequenceType: setSettings.tracks[track.trackId]!.notesSequenceType,
                exsFiles: track.exsFiles,
                audioFiles: track.audioFiles,
                effects: track.effects,
                parts: storeParts,
                levels: setSettings.tracks[track.trackId]!.levels,
                scoreWalkDuration: track.scoreWalkDuration
            )
            storeTracks.append(storeTrack)
            
            //Duplicate last track
            if duplicateLastTrack && track.trackId == instrumentSet.tracks.last!.trackId {
                storeTrack.trackId = storeTrack.trackId+"2"
                storeTrack.id = storeTrack.id+"2"
                storeTrack.instrumentName = storeTrack.instrumentName+"(2)"
                let storePartsIndex = storeParts.enumerated()
                for (index, _) in storePartsIndex {
                    storeTrack.parts[index].damperTarget.trackId = storeTrack.id
                }
                let duplicateTrack = storeTrack
                storeTracks.append(duplicateTrack)
            }
        }
        
        let storeInstrumentSet = InstrumentsSet(
            name: instrumentSet.name,
            customName: setSettings.customName,
            published: setSettings.published,
            fileGroup: setSettings.fileGroup,
            filesPath: instrumentSet.filesPath,
            defaultSkin: setSettings.defaultSkin,
            bpm: setSettings.bpm,
            hasTempo: setSettings.hasTempo,
            skin: setSettings.skins,
            timeSignature: instrumentSet.timeSignature,
            masterTrackEffects: modifiedMasterEffects, //MasterTrack effects editor values
            rows: setSettings.gridRows,
            columns: setSettings.gridColumns,
            levelSpeed: setSettings.levelSpeed,
            levels: setSettings.levels,
            tracks: storeTracks
        )
            
        return storeInstrumentSet
    }
    
    //MARK: editor
    static func letterForNumber(_ number: Int) -> String? {
        guard let scalarValue = UnicodeScalar(number + 65) else {
            return nil
        }
        return String(scalarValue)
    }
    
    static func midiNoteName(for noteNumber: Int) -> String {
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let octave = (noteNumber / 12) - 1
        let noteIndex = noteNumber % 12
        let noteName = noteNames[noteIndex]
        return "\(noteName)\(octave)"
    }
    
    //Collect clip number from selected instrument cells
    static func areaOfInterestGridMapped(
        areaOfInterest: [Int],
        cellsToGrid: [Int]
    ) -> [Int] {
        var cellsToGridMapped: [Int] = []
        for (index, value) in areaOfInterest.enumerated() {
            if value == 1 {
                cellsToGridMapped.append(cellsToGrid[index])
            }
        }
        return cellsToGridMapped
    }
    
    //Part editor SwiftUI interface
    static func getPartColors( trackColor: Color, areaOfInterest: [Int]) -> [Color]{
        
        var areaOfInterestColor: [Color] = []
        for i in areaOfInterest {
            if i == 1 { areaOfInterestColor.append(trackColor) }
            else { areaOfInterestColor.append(.black.opacity(0.01)) }
        }
        return areaOfInterestColor
    }
    
    static func getIndexes(areaOfInterest: [Int]) -> [Int] {
        return areaOfInterest.enumerated().compactMap { $0.element == 1 ? $0.offset : nil }
    }
    
    //Create the "database" to store the changed values in the master track, these values will be written to disk
    static func masterTrackSettings(instrumentSet: InstrumentsSet) -> OrderedDictionary<Int,MasterTrackEffectsSettings> {
        
        var masterTrackSettings: OrderedDictionary<Int,MasterTrackEffectsSettings> = [:]
        let loadedEffects = instrumentSet.masterTrackEffects
        var effectIndex: Int = 0
        for loadedEffect in loadedEffects {
            
            //Store parameter setting in:
            var parameters: OrderedDictionary<Int,ParameterSettings> = [:]
            
            //Get array of vars for selected effect
            let parametersStrings = loadedEffect.effectVars(effectType: loadedEffect.effectType)
            var parameterIndex: Int = 0
            for parameterString in parametersStrings {
                
                let valueAndRanges = loadedEffect.valueAndRanges(parameter: parameterString)
                
                let parameterSetting = ParameterSettings(
                    index: parameterIndex,
                    name: parameterString,
                    value: Double(valueAndRanges!.value),
                    range: valueAndRanges!.range
                )
                
                parameters[parameterIndex] = parameterSetting
                parameterIndex += 1
            }
            
            let masterTrackSetting = MasterTrackEffectsSettings(
                index: effectIndex,
                name: loadedEffect.effectType.rawValue,
                parameters: parameters
            )
            masterTrackSettings[effectIndex] = masterTrackSetting
            effectIndex += 1
        }
        
        return masterTrackSettings
    }
    
    //Create the object to build the master track view. This cannot hold changed values due to View rebuild on change
    static func masterTrackViewObject(instrumentSet: InstrumentsSet, setSettings: SetSettings) -> [MasterTrackEffect] {
        
        let masterEffects = instrumentSet.masterTrackEffects
        
        var masterTrackViewObject: [MasterTrackEffect] = []
        
        for (effectIndex, effect) in masterEffects.enumerated() {
            
            var parameters: [Parameter] = []
            
            let parametersString = effect.effectVars(effectType: effect.effectType)
            
            for (parameterIndex, parameterString) in parametersString.enumerated() {
                
                //Here we need to get the value from the
                let value = setSettings.masterEffects[effectIndex]!.parameters[parameterIndex]!.value
                let range = setSettings.masterEffects[effectIndex]!.parameters[parameterIndex]!.range
                
                //Here are we getting the value from the effect?
                let parameter = Parameter(
                    name: parameterString,
                    value: value,
                    range: range
                )
                
                parameters.append(parameter)
            }
            let masterTrackEffect = MasterTrackEffect(
                effectName: effect.effectType.rawValue,
                parameters: parameters
            )
            masterTrackViewObject.append(masterTrackEffect)
        }
        return masterTrackViewObject
    }
    
    //This last object keeps track of the same master track values to hold localy in a @State var
    static func masterTrackStateObject(viewObject: [MasterTrackEffect]) -> [[Float]] {
        
        //   Replaces  @State var masterEffect: [[Float]] = [
        //        [0,0,0,0,0,0,0,0,0,0],
        //        [0,0,0,0,0,0,0,0,0,0],
        //        [0,0,0,0,0,0,0,0,0,0]
        
        var parametersPerEffect: [[Float]] {
            var array: [[Float]] = []
            if let max = viewObject.map(\.parameters!.count).max(by: { $0 < $1 }) {
                for _ in viewObject {
                    array.append(Array(repeating: 0.0, count: max))
                }
            }
            return array
        }
        
        return parametersPerEffect
    }
}
