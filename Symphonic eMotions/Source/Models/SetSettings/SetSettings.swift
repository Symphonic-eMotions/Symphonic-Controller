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
        //Make 4 instrument compatible
        while instruments.count < 4 {
            instruments.append([])
        }
        
        return instruments
    }
    
    func getLevels() -> [[Int]] {
        
        var levels:[[Int]] = []
        for track in self.tracks {
            print("Levels Track order: \(track.value.trackId)")
            levels.append(track.value.levels)
        }
        //Make 4 instrument compatible
        while levels.count < 4 {
            levels.append([])
        }
        return levels
    }
    
    //Calculate positions and sizes
    func spriteKitInstruments(
        instrumentIndex: Int,
        instrumentAreas: [[[Int]]],
        size: CGSize,
        columns: Int,
        rows: Int
    ) -> ([CGPoint],[CGSize]){
        
        //Quick fix empty instrument
        if instrumentAreas[instrumentIndex].count > 0 {
            
            var positions:[CGPoint] = []
            var sizes:[CGSize] = []
            var index: Int = 0
            let flattenedParts:[Int] = flatttenParts(currentInstrumentArea: instrumentAreas[instrumentIndex])
            let cellWidth:CGFloat = size.width/CGFloat(columns)
            let cellHeight:CGFloat = size.height/CGFloat(rows)
            let centerWidth:CGFloat = cellWidth/2
            let centerHeight:CGFloat = cellHeight/2
            
            for row in 0..<rows {
                for column in 0..<columns {
                    //This current cell is within one of the instrument parts
                    
                    if flattenedParts[index] == 1 {
                        //Calculate center of cell
                        let x = CGFloat(column) * cellWidth + centerWidth
                        //Correct different 0,0 point SpriteKit row and SeM row on Y axis
                        let reversedRow = reverseNumber(number: row, min: 0, max: rows - 1)
                        let y = CGFloat(reversedRow) * cellHeight + centerHeight
                        positions.append(CGPoint(x: x, y: y))
                        //Calculate cell size
                        let size = CGSize(
                            width: size.width/CGFloat(columns),
                            height: size.height/CGFloat(rows)
                        )
                        sizes.append(size)
                    }
                    index += 1
                }
            }
            return (positions,sizes)
        }
        else{
            return ([CGPoint.zero],[CGSize.zero])
        }
            
        
        
    }
    
    func flatttenParts(
        currentInstrumentArea:[[Int]]
    ) -> [Int]{
        
        //For now, Combine parts within each other
        //Imitialize with first part of current instrument
        var combinedParts:[Int] = currentInstrumentArea[0]
        
        //Loop through all parts to add aditional values found in other parts
        for partArea in currentInstrumentArea {
            for (index, value) in partArea.enumerated() {
                if value == 1 {
                    combinedParts[index] = 1
                }
            }
        }
        return combinedParts
    }
    
    func reverseNumber(number:Int, min:Int, max:Int) -> Int{
        return (max + min) - number
    }
    
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
