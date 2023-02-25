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
    
    //Collect instrument areas
    func getInstrumentAreas() -> [[[Int]]] {
        
        var instruments: [[[Int]]] = []
        var trackParts: [[Int]] = []
        
        for track in self.tracks {
            trackParts = [[Int]]()
            for part in track.value.parts {
                trackParts.append(part.value.areaOfInterest)
            }
            instruments.append(trackParts)
        }
        return instruments
    }
    
    //Calculate column x-axis center fo
    func spriteKitInstrumentXs(
        instrumentAreas: [[[Int]]],
        size: CGSize,
        columns: Int) -> [CGFloat] {
        
        var instrumentXs: [CGFloat] = []
        for instrument in instrumentAreas {
            //Do this only for first part, other parts inherit x-axis value
            let partAreas = instrument[0]
            let firstIndex = partAreas.firstIndex(of: 1) ?? 0
            let instrumentColumn = firstIndex % columns
            let columnWidth:CGFloat = size.width / CGFloat(columns)
            let x = CGFloat(instrumentColumn) * columnWidth + columnWidth / 2
            instrumentXs.append(x)
        }
        return instrumentXs
    }
    
    func spriteKitInstrumentYs( instrumentAreas: [[[Int]]] ) -> [CGFloat] {
            
        var instrumentYs: [CGFloat] = []
        for _ in instrumentAreas {
            instrumentYs.append(200)
        }
        return instrumentYs
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
