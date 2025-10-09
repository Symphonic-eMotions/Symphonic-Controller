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
    // From valuesDidChange to SwiftUI grid index
    @Published var maxIndex: Int = -1

    // TODO: Translate maxIndex to center of grid coordinate

    // Keep track of playlist
    var currentPlaylist: SeMActive.Playlists
    var currentSetInList: URL

    // Keep track of current edited values
    var settingsCurrentTrackID: String
    var settingsVolume: Float
    var settingsCurrentPartID: String
    var settingsRampUp: Double
    var settingsRampDown: Double

    // Keep track of wave playing
    var isWavePlaying: Bool = false

    // Get loaded with firstPart.value.damperTarget.nodeSettings.minimalLevel
    // Which has a slider in the editor
    var waveUnderLevel: Double

    // Use tracks own ID to ommit use of indeces
    // Id comes from loaded struct
    // Set Name
    var setName: String
    var setPath: String
    var imagePrefix: String
    var customName: String
    var published: Bool
    var fileGroup: FileGroup
    var filesPath: String
    var setURL: URL
    var hasTempo: Bool

    // What views does the user see
    var userViews: [UserView]

    // grid dimention
    var gridRows: Int
    var gridColumns: Int

    // Dynamic tempo
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

    // Levels
    @Published var levels: [Int]
    @Published var levelSpeedSet: Double
    @Published var levelDifficultySet: Double

    // MasterTrack
    var masterEffects: OrderedDictionary<Int, MasterTrackEffectsSettings>

    // Tracks
    @Published var tracks: OrderedDictionary<String, TrackSettings> = .init() {
        didSet {
            objectWillChange.send()
        }
    }

    var semVersion: String

    init(
        setName: String,
        setPath: String,
        customName: String,
        published: Bool,
        fileGroup: FileGroup,
        filesPath: String,
        imagePrefix: String,
        setURL: URL,
        hasTempo: Bool,
        userViews: [UserView],
        rows: Int,
        columns: Int,
        levels: [Int],
        levelSpeedSet: Double,
        levelDifficultySet: Double,
        bpm: Double,
        masterEffects: OrderedDictionary<Int, MasterTrackEffectsSettings>,
        tracks: OrderedDictionary<String, TrackSettings>,
        semVersion: String
    ) {
        self.setName = setName
        self.setPath = setPath
        self.customName = customName
        self.published = published
        self.fileGroup = fileGroup
        self.filesPath = filesPath
        self.imagePrefix = imagePrefix
        self.setURL = setURL
        self.hasTempo = hasTempo
        self.userViews = userViews
        gridRows = rows
        self.bpm = bpm
        gridColumns = columns
        self.levels = levels
        self.levelSpeedSet = levelSpeedSet
        self.levelDifficultySet = levelDifficultySet
        self.masterEffects = masterEffects
        self.tracks = tracks
        self.semVersion = semVersion

        // In case of json error we need an "empty" instrumentsSet
        let initDamperTarget = InstrumentsSet.Track.Part.DamperTarget(trackIdString: "", nodeNameString: "", parameterString: "", parameterRangeArray: [], parameterInversedBool: false)
        let initPartSettings = PartSettings(partId: "", partName: "", partNumber: 0, rampUp: 0.5, rampDown: 0.5, minimalLevel: 0.1, areaOfInterest: [0], areaOfInterestColor: [.accentColor], damperTarget: initDamperTarget, dontDrawVisual: false, dampMode: .easeInCubic, targetType: .effect, targetNameEffect: .lowPassFilter, parametersInversed: false, targetParameterEffect: .cutoffFrequency, targetParameterInstrument: "samplerCC9", targetParameterSequencer: "velocity")
        let partDict = OrderedDictionary<String, PartSettings>(uniqueKeysWithValues: [("part", initPartSettings)])
        let initTrackSettings = TrackSettings(trackId: "", trackIndex: 0, trackName: "", noteSource: .midiFile, chordEntries: [ChordEntry()], startType: .loopedTransport, variationType: .variationByPosition, instrumentType: .exsSampler, exsFile: .trigger, audioFiles: [], instrumentVolume: 1, instrumentColor: .white, midiFile: "triggers.mid", midiGroup: [], notesToGrid: [], notesToGridMapped: [], notesToLevel: [], noteNumbersClips: [], notesSequenceType: .firstNote, loopLength: [], loopsToLevel: [], loopsToGrid: [], loopsToGridMapped: [], levels: [], parts: partDict, effects: [:])
        let firstTrack = tracks.elements.first ?? ("track", initTrackSettings)
        settingsCurrentTrackID = firstTrack.key
        settingsVolume = firstTrack.value.instrumentVolume
        let firstPart = firstTrack.value.parts.elements.first!
        waveUnderLevel = 0.25 // firstMinimalLevel * 0.75
        settingsCurrentPartID = firstPart.key
        settingsRampUp = firstPart.value.rampUp
        settingsRampDown = firstPart.value.rampDown
        // End empty InstrumentsSet

        currentPlaylist = .none
        currentSetInList = URL("noSet")
    }

    // ValuesDidChange
    func allIndexes(rows: Int, columns: Int) -> [InstrumentsSet.Index] {
        var indexes: [InstrumentsSet.Index] = []
        indexes.append(contentsOf: Array(repeating: InstrumentsSet.Index(row: rows, column: columns), count: rows * columns))

        return indexes
    }

    // PlayView
    func getTrackLevels(trackId: String?) -> [Int] {
        return tracks[trackId!]!.levels
    }

    // Editor set settings
    func resetGridArrays(cells: Int) {
        for (index, _) in tracks {
            for (partIndex, _) in tracks[index]!.parts {
                let zeroArray: [Int] = Array(repeating: 1, count: cells)

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

                var notesToGrid: [Int] = []
                if tracks[index]!.midiGroup.count > 0 {
                    notesToGrid = Array(repeating: tracks[index]!.midiGroup.first!, count: cells)
                } else {
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
}
