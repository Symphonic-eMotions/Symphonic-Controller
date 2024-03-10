//
//  SetSettings.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 23/09/2022.
//

import Foundation
import OrderedCollections
import SwiftUI

// SetSettings is used to keep track of settingchanges to store them to disk

class SetSettings: Identifiable, ObservableObject {
    
    //Keep track of playlist
    var currentPlaylist: SeMActive.Playlists
    var currentSetInList: URL
    
    //Keep track of current edited values
    var settingsCurrentTrackID: String
    var settingsVolume: Float
    var settingsCurrentPartID: String
    var settingsRampUp: Double
    var settingsRampDown: Double
    
    //Keep track of wave playing
    var isWavePlaying: Bool = false
    
    //Get loaded with firstPart.value.damperTarget.nodeSettings.minimalLevel
    //Which has a slider in the editor
    var waveUnderLevel: Double
    
    //Use tracks own ID to ommit use of indeces
    //Id comes from loaded struct
    //Set Name
    var setName: String
    var customName: String
    var published: Bool
    var fileGroup: FileGroup
    var filesPath: String
    var setURL: URL
    var hasTempo: Bool
    
    var defaultSkin: SessionDisplay
    
    //grid dimention
    var gridRows: Int
    var gridColumns: Int
    
    //Dynamic tempo
    var bpm: Double
    var bpmAsString: String {
        get {
            return String(format: "%.2f", bpm)
        }
        set {
            if let value = Double(newValue) {
                bpm = value
            }
        }
    }
    
    //Levels
    @Published var levels: [Int]
    
    //MasterTrack
    var masterEffects: OrderedDictionary<Int,MasterTrackEffectsSettings>
    
    //Tracks
    @Published var tracks: OrderedDictionary<String, TrackSettings> = OrderedDictionary<String, TrackSettings>() {
        didSet {
            objectWillChange.send()
        }
    }
    
    var skins: InstrumentsSet.Skin
    var semVersion: String
    
    init(
        setName: String,
        customName: String,
        published: Bool,
        fileGroup: FileGroup,
        filesPath: String,
        setURL: URL,
        hasTempo: Bool,
        defaultSkin: SessionDisplay,
        rows: Int,
        columns: Int,
        levels: [Int],
        bpm: Double,
        masterEffects: OrderedDictionary<Int, MasterTrackEffectsSettings>,
        tracks: OrderedDictionary<String,TrackSettings>,
        skins: InstrumentsSet.Skin,
        semVersion: String
    ){
        self.setName = setName
        self.customName = customName
        self.published = published
        self.fileGroup = fileGroup
        self.filesPath = filesPath
        self.setURL = setURL
        self.hasTempo = hasTempo
        self.defaultSkin = defaultSkin
        self.gridRows = rows
        self.bpm = bpm
        self.gridColumns = columns
        self.levels = levels
        self.masterEffects = masterEffects
        self.tracks = tracks
        self.skins = skins
        self.semVersion = semVersion
        
        //In case of json error we need an "empty" instrumentsSet
        let initDamperTarget = InstrumentsSet.Track.Part.DamperTarget(trackIdString: "", nodeNameString: "", parameterString: "", parameterRangeArray: [], parameterInversedBool: false)
        let initPartSettings = PartSettings(partId: "", partName: "", partNumber: 0, rampUp: 0.5, rampDown: 0.5, minimalLevel: 0.1, areaOfInterest: [0], areaOfInterestColor: [.accentColor], damperTarget: initDamperTarget, dontDrawVisual: false, dampMode: .easeInCubic, targetType: .effect, targetNameEffect: .lowPassFilter, parametersInversed: false, targetParameterEffect: .cutoffFrequency, targetParameterInstrument: "samplerCC9", targetParameterSequencer: "velocity")
        let partDict = OrderedDictionary<String, PartSettings>(uniqueKeysWithValues: [("part", initPartSettings)])
        let initTrackSettings = TrackSettings(trackId: "", trackIndex: 0, trackName: "", noteSource: .midiFile, startType: .loopedTransport, variationType: .variationByPosition, instrumentType: .exsSampler, exsFile: .trigger, audioFiles: [], instrumentVolume: 1, instrumentColor: .white, midiFile: "triggers.mid", midiGroup: [], notesToGrid: [], notesToGridMapped: [], notesToLevel: [], noteNumbersClips: [], notesSequenceType: .firstNote, loopLength: [], loopsToLevel: [], loopsToGrid: [], loopsToGridMapped: [], levels: [], parts: partDict, effects: [:])
        let firstTrack = tracks.elements.first ?? ("track", initTrackSettings)
        self.settingsCurrentTrackID = firstTrack.key
        self.settingsVolume = firstTrack.value.instrumentVolume
        let firstPart = firstTrack.value.parts.elements.first!
        self.waveUnderLevel = 0.25 //firstMinimalLevel * 0.75
        self.settingsCurrentPartID = firstPart.key
        self.settingsRampUp = firstPart.value.rampUp
        self.settingsRampDown = firstPart.value.rampDown
        //End empty InstrumentsSet
        
        self.currentPlaylist = .none
        self.currentSetInList = URL("noSet")
    }
    
    //ValuesDidChange
    func allIndexes(rows: Int, columns: Int) -> [InstrumentsSet.Index] {
        var indexes: [InstrumentsSet.Index] = []
        indexes.append(contentsOf: Array(repeating: InstrumentsSet.Index(row: rows, column: columns), count: (rows * columns)))
        
        return indexes
    }
    
    //PlayView
    func getTrackLevels(trackId: String?) -> [Int] {
        return self.tracks[trackId!]!.levels
    }
    
    //Editor set settings
    func resetGridArrays(cells: Int) {
        
        for( index, _ ) in tracks {
            
            for( partIndex, _ ) in tracks[index]!.parts {
                
                let zeroArray:[Int] = Array(repeating: 1, count: cells)
                
                tracks[index]!.parts[partIndex]?.areaOfInterest = zeroArray
                tracks[index]!.parts[partIndex]?.areaOfInterestColor = AppUtils.getPartColors(
                    trackColor: tracks[index]!.instrumentColor,
                    areaOfInterest: zeroArray
                )
                
                tracks[index]!.loopsToGrid = zeroArray
                tracks[index]!.loopsToGridMapped = AppUtils.areaOfInterestGridMapped(
                    areaOfInterest: zeroArray,
                    cellsToGrid: zeroArray
                )
                
                var notesToGrid:[Int] = []
                if tracks[index]!.midiGroup.count > 0 {
                    notesToGrid = Array(repeating: tracks[index]!.midiGroup.first!, count: cells)
                }
                else {
                    notesToGrid = Array(repeating: 48, count: cells)
                }
                tracks[index]!.notesToGrid = notesToGrid
                tracks[index]!.notesToGridMapped = AppUtils.areaOfInterestGridMapped(
                    areaOfInterest: zeroArray,
                    cellsToGrid: notesToGrid
                )
            }
        }
    }
    
    func resetRampSetting(version: Int){
        
        for( index, _ ) in tracks {
            
            for( partIndex, _ ) in tracks[index]!.parts {
                
                if version == 2 {
                    tracks[index]!.parts[partIndex]?.rampUp = 0.0323
                    tracks[index]!.parts[partIndex]?.rampDown = 0.3190
                }
                //Version is 1 for now
                else {
                    tracks[index]!.parts[partIndex]?.rampUp = 0.0008
                    tracks[index]!.parts[partIndex]?.rampDown = 0.0028
                }
            }
        }
    }
}
