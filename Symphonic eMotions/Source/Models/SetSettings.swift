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

class SetSettings: Identifiable {
    
    //Keep track of current edited values
    var settingsCurrentTrackID: String
    var settingsVolume: Float
    var settingsCurrentPartID: String
    var settingsRampUp: Double
    var settingsRampDown: Double
    
    //Use tracks own ID to ommit use of indeces
    //Id comes from loaded struct
    //Set Name
    var setName: String
    
    //grid dimention
    var gridRows: Int
    var gridColumns: Int
    
    //Dynamic tempo
    var bpm: Double
    
    //MasterTrack
    var masterEffects: OrderedDictionary<Int,MasterTrackEffectsSettings>
    
    //Tracks
    var tracks: OrderedDictionary<String,TrackSettings>
    
    init(
        setName: String,
        rows: Int,
        columns: Int,
        bpm: Double,
        masterEffects: OrderedDictionary<Int, MasterTrackEffectsSettings>,
        tracks: OrderedDictionary<String,TrackSettings>
    ){
        self.setName = setName
        self.gridRows = rows
        self.bpm = bpm
        self.gridColumns = columns
        self.masterEffects = masterEffects
        self.tracks = tracks
        
        //Set editor values (partFeedbackView) ready for first track first part editing
        let firstTrack = tracks.elements.first!
        
        print("Set loaded, first track ID: \(firstTrack.key)")
        
        self.settingsCurrentTrackID = firstTrack.key
        self.settingsVolume = firstTrack.value.instrumentVolume
        let firstPart = firstTrack.value.parts.elements.first!
        self.settingsCurrentPartID = firstPart.key
        self.settingsRampUp = firstPart.value.rampUp
        self.settingsRampDown = firstPart.value.rampDown
    }
    
    func getTrackLevels(trackId: String?) -> [Int] {
        
        return self.tracks[trackId!]!.levels
    }
    
    func updateLevelIndex(trackId: String, level: Int){
        if let index = self.tracks[trackId]!.levels.firstIndex(of: level) {
            self.tracks[trackId]?.levels.remove(at: index)
        }
        else{
            self.tracks[trackId]!.levels.append(level)
        }
    }
}

//extension SetSettings {
    
    class TrackSettings: Identifiable {
        var trackId: String
        var trackName: String
        var instrumentVolume: Float
        var instrumentColor: Color
        var levels: [Int]
        var parts: OrderedDictionary<String, PartSettings>
        
        init(
            trackId: String,
            trackName: String,
            instrumentVolume: Float,
            instrumentColor: Color,
            levels: [Int],
            parts: OrderedDictionary<String, PartSettings>
        ){
            self.trackId = trackId
            self.trackName = trackName
            self.instrumentVolume = instrumentVolume
            self.instrumentColor = instrumentColor
            self.levels = levels
            self.parts = parts
        }
        
        func changeAreaOfInterestColor(newColor: Color){
            for partId in self.parts.keys {
                self.parts[partId]?.areaOfInterestColor = AppUtils.getPartColors(trackColor: newColor, areaOfInterest: self.parts[partId]!.areaOfInterest)
            }
        }
    }
//}

//extension SetSettings.TrackSettings {
    
    class PartSettings: Identifiable {
        
        var partId: String
        var partName: String
        var partNumber: Int
        var rampUp: Double
        var rampDown: Double
        var areaOfInterest: [Int]
        var areaOfInterestColor: [Color]
        var dontDrawVisual: Bool
        
        init(partId: String,
             partName: String,
             partNumber: Int,
             rampUp: Double,
             rampDown: Double,
             areaOfInterest: [Int],
             areaOfInterestColor: [Color],
             dontDrawVisual: Bool
        ){
            self.partId = partId
            self.partName = partName
            self.partNumber = partNumber
            self.rampUp = rampUp
            self.rampDown = rampDown
            self.areaOfInterest = areaOfInterest
            self.areaOfInterestColor = areaOfInterestColor
            self.dontDrawVisual = dontDrawVisual
        }
        
        func indexes(rows: Int, columns: Int) -> [InstrumentsSet.Track.Part.Index] {
            var indexes: [InstrumentsSet.Track.Part.Index] = []
            for row in 0..<rows {
                for column in 0..<columns {
                    if areaOfInterest[row * columns + column] == 1 {
                        indexes.append(InstrumentsSet.Track.Part.Index(row: row, column: column))
                    }
                }
            }
            return indexes
        }
        
        func isIndexSelected(row: Int, column: Int, gridRows: Int, gridColumns: Int) -> Bool {
            self.indexes( rows: gridRows, columns: gridColumns).contains { $0.column == column && $0.row == row }
        }
    }
//}

class MasterTrackEffectsSettings: Identifiable {
    
    var id: Int { index }
    var index: Int
    var name: String
    var parameters: OrderedDictionary<Int, ParameterSettings>
    
    init(
        index: Int,
        name: String,
        parameters: OrderedDictionary<Int, ParameterSettings>
    ) {
        self.index = index
        self.name = name
        self.parameters = parameters
    }
}

class ParameterSettings: Identifiable {
    
    var id: Int { index }
    var index: Int
    var name: String
    var value: Double
    var range: [Double]
    
    init( index: Int, name: String, value: Double, range: [Double] ) {
        self.index = index
        self.name = name
        self.value = value
        self.range = range
    }
}
