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
import AVFAudio

final class AppUtils {
    
    enum InstrumentError: Error {
        case loadFailed(String)
    }
    
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
            return InstrumentsSet(name: "No Set", customName: "", published: false, semVersion: "1.0.0", fileGroup: .none, filesPath: "", imagePrefix: "", userViews: [.playView], bpm: 120, hasTempo: true, timeSignature: 4, masterTrackEffects: [], rows: 1, columns: 1, levels: [0], setEffects: [], tracks: [])
        }
        return instrumentSet
    }
    
    static func loadURLServerInstrumentSet(urlServer: String) -> InstrumentsSet? {
        
        let urlServerURL = URL(string: urlServer)
        
        let instrumentSet = InstrumentsSet.withOnlineJSON(urlServerURL!)
        
        return instrumentSet ?? nil
    }
    
    static func loadSavedInstrumentSet(fileName: String) throws -> InstrumentsSet {
        guard let instrumentSet = InstrumentsSet.withFileManagerJSON(fileName) else {
            throw InstrumentError.loadFailed("Failed to load instrument set from \(fileName)")
        }
        return instrumentSet
    }
    
    //MARK: Playists
    static func createPlayListFolders(resetPlaylist: Bool) {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Document directory niet gevonden.")
            return
        }
        let bundleURL = Bundle.main.bundleURL

        let lists = SeMActive.Playlists.allCases
        let filteredPlaylists = lists.filter({ $0 != .none }) // Filtering out the 'none' case

        // Loop through filtered playlists
        for playlist in filteredPlaylists {
            let playlistURL = documentsURL.appendingPathComponent(playlist.rawValue)
            let bundlePlaylistURL = bundleURL.appendingPathComponent(playlist.rawValue)

            if !fileManager.fileExists(atPath: playlistURL.path) || resetPlaylist {
                do {
                    try fileManager.createDirectory(at: playlistURL, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Error creating directory: \(error)")
                    continue // Ga door naar de volgende playlist als het maken van de directory mislukt
                }

                do {
                    let playlistContent = try fileManager.contentsOfDirectory(at: bundlePlaylistURL, includingPropertiesForKeys: nil)

                    for item in playlistContent {
                        let destinationURL = playlistURL.appendingPathComponent(item.lastPathComponent)

                        if fileManager.fileExists(atPath: destinationURL.path) && resetPlaylist {
                            do {
                                try fileManager.removeItem(at: destinationURL)
                            } catch {
                                print("Error removing existing item: \(error)")
                                continue // Ga door naar het volgende item als het verwijderen mislukt
                            }
                        }

                        do {
                            try fileManager.copyItem(at: item, to: destinationURL)
                        } catch {
                            print("Error copying playlist files: \(error)")
                            continue // Maar ga toch door
                        }
                    }
                } catch {
                    print("Error copying playlist files: \(error)")
                }
            }
        }
    }

    
    static func semVersionString() -> String {
        var infoString = ""

        if let bundleID = Bundle.main.bundleIdentifier {
            let bundleIDComponents = bundleID.split(separator: ".")
            if let lastComponent = bundleIDComponents.last {
                infoString += "\(lastComponent) "
            }
        }

        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let versionNumber = appVersion.split(separator: " ").last {
            infoString += "\(versionNumber) "
        }

        if let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
           let buildNumberValue = buildNumber.split(separator: " ").last {
            infoString += "(\(buildNumberValue))"
        }

        return infoString
    }

    static func compareVersions(version1: String, version2: String) -> ComparisonResult {
        let versionNumbers1 = version1.split(separator: ".").compactMap { Int($0) }
        let versionNumbers2 = version2.split(separator: ".").compactMap { Int($0) }

        for (num1, num2) in zip(versionNumbers1, versionNumbers2) {
            if num1 < num2 {
                return .orderedAscending
            } else if num1 > num2 {
                return .orderedDescending
            }
        }

        // Handle cases where one version string is longer than the other
        if versionNumbers1.count < versionNumbers2.count {
            return .orderedAscending
        } else if versionNumbers1.count > versionNumbers2.count {
            return .orderedDescending
        }

        return .orderedSame
    }
    
    //MARK: Set setSetings
    // - Structure to load InstrumentsSet to mutuate and save
    static func setSettings(
        instrumentSet: InstrumentsSet
    ) -> SetSettings {
        
        let masterEffects: OrderedDictionary<Int,MasterTrackEffectsSettings> = MasterTrackEffectsHelper.masterTrackSettings(instrumentSet: instrumentSet)
                
        let setLevels: [Int] = instrumentSet.levels
        let maxSetLevelIndex = setLevels.count
        
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
                    dontDrawVisual: partLoaded.dontDrawVisual ?? false,
                    dampMode: partLoaded.damperTarget.dampMode ?? .easeInCubic,
                    targetType: partLoaded.damperTarget.nodeType,
                    targetNameEffect: InstrumentsSet.Track.Effect.EffectType(
                        rawValue: partLoaded.damperTarget.nodeName) ?? .none,
                    parametersInversed: partLoaded.damperTarget.parameterInversed,
                    targetParameterEffect: InstrumentsSet.Track.Effect.EffectKeys(
                        rawValue: partLoaded.damperTarget.parameter) ?? .effectType,
                    targetParameterInstrument: partLoaded.damperTarget.parameter,
                    targetParameterSequencer: partLoaded.damperTarget.parameter
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
            
            var noteNumbersClips:[Int] = trackLoaded.noteNumbersClips ?? []
            if noteNumbersClips.count != instrumentSet.levels.count {
                noteNumbersClips = Array(repeating: 0, count: instrumentSet.levels.count)
            }
            
            var notesToGrid:[Int] = trackLoaded.notesToGrid ?? []
            if notesToGrid.count != cells {
                //We have a another amount of cells, reset
                notesToGrid = Array(repeating: midiGroup.min()!, count: cells)
            }
            
            var exsFile: ExsFiles = .trigger
            if let loaded = trackLoaded.exsFiles, !loaded.isEmpty {
                exsFile = ExsFiles(rawValue: loaded.first!.fileName)!
            }
            
            let effects: OrderedDictionary<Int,TrackEffectsSettings> = TrackEffectsHelper.trackEfectsSettings(track: trackLoaded)
            
            //Remove levels higher than after level so we get no new fade ins
            let filteredLevels = trackLoaded.levels.filter { $0 <= maxSetLevelIndex }
            
            print("setSettings track \(trackLoaded.instrumentName) filteredLevels: \(filteredLevels)")
            
            let track = TrackSettings(
                trackId: trackLoaded.id,
                trackIndex: trackIndex,
                trackName: trackLoaded.instrumentName,
                noteSource: trackLoaded.noteSource ?? .midiFile,
                startType: trackLoaded.startType,
                variationType: trackLoaded.variationType ?? .variationByPosition,
                instrumentType: trackLoaded.instrumentType,
                exsFile: exsFile,
                audioFiles: trackLoaded.audioFiles ?? [],
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
                noteNumbersClips: noteNumbersClips,
                notesSequenceType:  trackLoaded.notesSequenceType ?? .firstNote,
                loopLength: (trackLoaded.midiFiles?.first!.loopLength)!,
                loopsToLevel: loopsToLevel,
                loopsToGrid: loopsToGrid,
                loopsToGridMapped: AppUtils.areaOfInterestGridMapped(
                    areaOfInterest: firstAreaOfInterest,
                    cellsToGrid: loopsToGrid
                ),
                levels: filteredLevels,
                parts: parts,
                effects: effects
            )
            
            tracks[trackLoaded.id] = track
            trackIndex += 1
        }
        
        let setSettings = SetSettings(
            setName: instrumentSet.name,
            setPath: instrumentSet.filesPath,
            customName: instrumentSet.customName,
            published: instrumentSet.published ?? false,
            fileGroup: instrumentSet.fileGroup ?? .none,
            filesPath: instrumentSet.filesPath,
            imagePrefix: instrumentSet.imagePrefix,
            setURL: URL(setUrl),
            hasTempo: instrumentSet.hasTempo, 
            userViews: instrumentSet.userViews,
            rows: instrumentSet.rows,
            columns: instrumentSet.columns,
            levels: instrumentSet.levels,
            bpm: instrumentSet.bpm,
            masterEffects: masterEffects,
            tracks: tracks,
            semVersion: instrumentSet.semVersion ?? "1.0.0"
        )
        
        return setSettings
    }
    
    //MARK: crate folder for track recording
    static func createAvAudioFile (
        set: InstrumentsSet,
        trackName: String
    ) throws -> AVAudioFile {
        
        let fileManager = FileManager.default
        
        // Base documents path
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Create subfolders
        let setName = ( set.customName != "" ) ? set.customName : set.name
        let mainFolderName = "Recordings"
        let subFolderName = "\(setName)"
        
        // Full folder path
        let mainFolderPath = documentsPath.appendingPathComponent(mainFolderName)
        let subFolderPath = mainFolderPath.appendingPathComponent(subFolderName)
        
        // Create main folder if it doesn't exist
        if !fileManager.fileExists(atPath: mainFolderPath.path) {
            try fileManager.createDirectory(at: mainFolderPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Create subfolder if it doesn't exist
        if !fileManager.fileExists(atPath: subFolderPath.path) {
            try fileManager.createDirectory(at: subFolderPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Output file within the subfolder
        let outputFile = subFolderPath.appendingPathComponent("\(trackName).aac")
        
        // File settings
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVLinearPCMBitDepthKey: 16
        ]
        
        do {
            // File to write recording to
            let avAudioFile = try AVAudioFile(forWriting: outputFile, settings: settings)
            return avAudioFile
            
        } catch {
            print("Error creating record file \(trackName)")
            throw error // Propagate the error upwards
        }
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
            if SeMActive.Playlists(rawValue: parentDirectoryName) != nil {
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
            
            let trackEffect = InstrumentsSet.Track.Effect()
            let effectTypeHolder = trackEffect.effectVars(effectType: effectType)
            let parameterStrings: [String] = effectTypeHolder.map{$0.rawValue}
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
        
        //Problem! this needs to be generated from setSettings:
        
        //New
        for track in setSettings.tracks {
            
            var storeParts: [InstrumentsSet.Track.Part] = []
            for part in track.value.parts {
                
                let storeNodeSettings = InstrumentsSet.Track.Part.DamperTarget.NodeSettings(
                    minimalLevel: part.value.minimalLevel,
                    rampSpeed: part.value.rampUp,
                    rampSpeedDown: part.value.rampDown
                )
                
                var parameter: String = "";
                if part.value.targetType == .effect {
                    parameter = part.value.targetParameterEffect.rawValue
                }
                else if part.value.targetType == .instrument {
                    parameter = part.value.targetParameterInstrument
                }
                else if part.value.targetType == .sequencer {
                    parameter = part.value.targetParameterSequencer
                }
                
                let storeDamperTarget = InstrumentsSet.Track.Part.DamperTarget(
                    trackId: part.value.damperTarget.trackId,
                    nodeType: part.value.targetType,
                    nodeName: part.value.targetNameEffect.rawValue,
                    parameter: parameter,
                    parameterRange: part.value.damperTarget.parameterRange,
                    parameterInversed: part.value.parametersInversed,
                    midiData: part.value.damperTarget.midiData,
                    nodeSettings: storeNodeSettings,
                    dampMode: part.value.damperTarget.dampMode
                )
                
//                print("SAVING DAMPER TARGET")
//                print(storeDamperTarget)
                
                let storePart = InstrumentsSet.Track.Part(
                    instrumentPartName: part.value.partName,
                    areaOfInterest: part.value.areaOfInterest,
                    dontDrawVisual: part.value.dontDrawVisual,
                    damperTarget: storeDamperTarget
                )
                storeParts.append(storePart)
            }
            
            //Fix is length don't match current level length
            let loopsToLevel = adjustArray(target: track.value.loopsToLevel, example: setSettings.levels)
            
            let notesToLevel = adjustArray(target: track.value.notesToLevel, example: setSettings.levels)
            
            let midiFiles = [InstrumentsSet.Track.MidiFile(
                fileName: track.value.midiFile,
                fileExtension: "mid",
                loopLength: track.value.loopLength,
                //Fix length anomalies
                loopsToLevel: loopsToLevel,
                loopsToGrid: track.value.loopsToGrid
            )]
            
            let effects: [InstrumentsSet.Track.Effect] = TrackEffectsHelper.trackEffectInstrumentsSet(trackSetttings: track.value)
            
            let storeTrack = InstrumentsSet.Track(
                id: track.value.trackId,
                trackId: track.value.trackId,
                muted: false,
                instrumentType: track.value.instrumentType,
                noteSource: track.value.noteSource,
                startType: track.value.startType,
                variationType: track.value.variationType,
                instrumentName: track.value.trackName,
                instrumentColor: track.value.instrumentColor,
                volume: track.value.instrumentVolume,
                midiFiles: midiFiles,
                midiGroup: track.value.midiGroup,
                notesToGrid: track.value.notesToGrid,
                notesToLevel: notesToLevel,
                noteNumbersClips: track.value.noteNumbersClips,
                notesSequenceType: track.value.notesSequenceType,
                exsFiles: [InstrumentsSet.Track.ExsFile(fileName: track.value.exsFile.rawValue)],
                audioFiles: track.value.audioFiles,
//                effects: instrumentSet.tracks[track.value.trackIndex].effects,
                effects: effects,
                parts: storeParts,
                levels: track.value.levels
            )
            storeTracks.append(storeTrack)
        }
        
        var semVersion = "1.0.0"
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let versionNumber = appVersion.split(separator: " ").last {
            semVersion = "\(versionNumber)"
        }
        
        let storeInstrumentSet = InstrumentsSet(
            name: instrumentSet.name,
            customName: setSettings.customName,
            published: setSettings.published, 
            semVersion: semVersion, 
            fileGroup: setSettings.fileGroup,
            filesPath: setSettings.filesPath,
            imagePrefix: setSettings.imagePrefix,
            userViews: setSettings.userViews,
            bpm: setSettings.bpm,
            hasTempo: setSettings.hasTempo,
            timeSignature: instrumentSet.timeSignature,
            masterTrackEffects: modifiedMasterEffects, //MasterTrack effects editor values
            rows: setSettings.gridRows,
            columns: setSettings.gridColumns,
//            levelSpeed: setSettings.levelSpeed,
            levels: setSettings.levels, 
            setEffects: instrumentSet.setEffects ?? [],
            tracks: storeTracks
        )
            
        return storeInstrumentSet
    }
    
    static func adjustArray(target: [Int], example: [Int]) -> [Int] {
        var result = target
        if result.count > example.count {
            // If noteLevels is longer, remove the extra elements from the end
            result = Array(result[..<example.count])
        } else if result.count < example.count {
            // If noteLevels is shorter, append the last value until they're the same length
            let lastValue = result.last ?? 48
            let addIndeces = example.count - result.count
            result.append(contentsOf: Array(repeating: lastValue, count: addIndeces))
        }
        return result
    }
    
    static func adjustArrayLevels(target: [Int], example: [Int]) -> [Int] {
        
        var result = target

        if result.count < example.count {
            // If the target array is shorter, append the last value until they're the same length.
            let lastValue = result.last ?? 0
            result.append(contentsOf: Array(repeating: lastValue, count: example.count - target.count))
        } else if result.count > example.count {
            // If the target array is longer, remove the extra elements from the end.
            result = Array(result[..<example.count])
        }

        return result
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
}
