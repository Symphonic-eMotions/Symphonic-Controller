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
    
    //Calculateactice cell borders
    
    
    //Calculate x- and y-axis center points
    func spriteKitInstrumentXYs(
        instrumentIndex: Int,
        instrumentAreas: [[[Int]]],
        size: CGSize,
        columns: Int,
        rows: Int
    ) -> ([CGFloat],[CGFloat]) {
        
        let cellWidth:CGFloat = size.width/CGFloat(columns)
        let cellHeight:CGFloat = size.height/CGFloat(rows)
        let centerWidth:CGFloat = cellWidth/2
        let centerHeight:CGFloat = cellHeight/2
        
        //We want ALL instrumentXs stored in here
        var instrumentXs: [CGFloat] = []
        var instrumentYs: [CGFloat] = []
        
        //For now, Combine parts within each other
        //Imitialize with first part of current instrument
        var combinedParts: [Int] = instrumentAreas[instrumentIndex][0]
        
        //Loop through all parts to add aditional values found in other parts
        for partArea in instrumentAreas[instrumentIndex] {
            for (index, value) in partArea.enumerated() {
                if value == 1 {
                    combinedParts[index] = 1
                }
            }
        }
    
        var index: Int = 0
        for row in 0..<rows {
            
            for column in 0..<columns {
                
                //Calculatie centerpoint of this cell
                if combinedParts[index] == 1 {
                    let x = CGFloat(column) * cellWidth + centerWidth
                    instrumentXs.append(x)
                    let reversedRow = reverseNumber(number: row, min: 0, max: rows - 1)
                    let y = CGFloat(reversedRow) * cellHeight + centerHeight
                    instrumentYs.append(y)
                }
                
                index += 1
            }
        }
        
        print("instrumentYs \(instrumentIndex) \(instrumentYs)")
        
        return (instrumentXs,instrumentYs)
    }
    
    func reverseNumber(number:Int, min:Int, max:Int) -> Int{
        return (max + min) - number
    }
    
//    func spriteKitInstrumentYs(
//        instrumentAreas: [[[Int]]],
//        size: CGSize,
//        rows: Int) -> [CGFloat] {
//
//            var instrumentYs: [CGFloat] = []
//
//            for instrument in instrumentAreas {
//                //Do this only for first part, other parts inherit x-axis value
//                let partAreas = instrument[0]
//
////            let firstIndex = partAreas.firstIndex(of: 1) ?? 0
////            let instrumentColumn = firstIndex % columns
////            let columnWidth:CGFloat = size.width / CGFloat(columns)
////            let x = CGFloat(instrumentColumn) * columnWidth + columnWidth / 2
////            instrumentXs.append(x)
//            }
//        }
    
//    func spriteKitInstrumentYsStatic( instrumentAreas: [[[Int]]] ) -> [CGFloat] {
//        var instrumentYs: [CGFloat] = []
//        for _ in instrumentAreas {
//            instrumentYs.append(200)
//        }
//        return instrumentYs
//    }
    
    func updateLimiter( instrumentAreas: [[[Int]]] ) -> [Int] {
        var midiClips: [Int] = []
        for _ in instrumentAreas {
            midiClips.append(-1)
        }
        return midiClips
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
