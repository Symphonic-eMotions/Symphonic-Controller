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
    
    //Keep track of current edited values
    var settingsCurrentTrackID: String
    var settingsVolume: Float
    var settingsCurrentPartID: String
    var settingsRampUp: Double
    var settingsRampDown: Double
    
    //Keep track of wave playing
    var isWavePlaying: Bool = false
    var waveThreshold: Double = 0.1
    
    //Use tracks own ID to ommit use of indeces
    //Id comes from loaded struct
    //Set Name
    var setName: String
    var customName: String
    var setURL: URL
    
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
    
    //Level speed
    var levelSpeed: Double
    //Levels
    @Published var levels: [Int]
    
    //MasterTrack
    var masterEffects: OrderedDictionary<Int,MasterTrackEffectsSettings>
    
    //Tracks
    var tracks: OrderedDictionary<String,TrackSettings>
    
    //Skins
    var skins: InstrumentsSet.Skin
    
    init(
        setName: String,
        customName: String,
        setURL: URL,
        defaultSkin: SessionDisplay,
        rows: Int,
        columns: Int,
        levelSpeed: Double,
        levels: [Int],
        bpm: Double,
        masterEffects: OrderedDictionary<Int, MasterTrackEffectsSettings>,
        tracks: OrderedDictionary<String,TrackSettings>,
        skins: InstrumentsSet.Skin
    ){
        self.setName = setName
        self.customName = customName
        self.setURL = setURL
        self.defaultSkin = defaultSkin
        self.gridRows = rows
        self.bpm = bpm
        self.gridColumns = columns
        self.levelSpeed = levelSpeed
        self.levels = levels
        self.masterEffects = masterEffects
        self.tracks = tracks
        self.skins = skins
        //Set editor values (partFeedbackView) ready for first track first part editing
        let firstTrack = tracks.elements.first!
        self.settingsCurrentTrackID = firstTrack.key
        self.settingsVolume = firstTrack.value.instrumentVolume
        let firstPart = firstTrack.value.parts.elements.first!
        self.settingsCurrentPartID = firstPart.key
        self.settingsRampUp = firstPart.value.rampUp
        self.settingsRampDown = firstPart.value.rampDown
        
    }
    
    func updateTrackClipInLevel(){
        
        let levelsSize = self.levels.count
        tracks.forEach{ (trackId, track) in
            
            var loopsToLevelSize = track.loopsToLevel.count
            if loopsToLevelSize < levelsSize {
                while loopsToLevelSize < levelsSize {
                    track.loopsToLevel.append(0)
                    loopsToLevelSize = track.loopsToLevel.count
                }
            }
            else if loopsToLevelSize > levelsSize {
                while loopsToLevelSize > levelsSize {
                    track.loopsToLevel.removeLast()
                    loopsToLevelSize = track.loopsToLevel.count
                }
            }
            
            var noteToLoopSize = track.notesToLevel.count
            if noteToLoopSize < levelsSize {
                while noteToLoopSize < levelsSize {
                    track.notesToLevel.append(track.midiGroup.max() ?? 48)
                    noteToLoopSize = track.notesToLevel.count
                }
            }
            else if noteToLoopSize > levelsSize {
                while noteToLoopSize > levelsSize {
                    track.notesToLevel.removeLast()
                    noteToLoopSize = track.notesToLevel.count
                }
            }
        }
    }
    
    func resetGridArrays(cells: Int) {
        
        for( index, _ ) in tracks {
            
            for( partIndex, _ ) in tracks[index]!.parts {
                
                let zeroArray:[Int] = Array(repeating: 0, count: cells)
                
                tracks[index]!.parts[partIndex]?.areaOfInterest = zeroArray
                
                //Loop's not a grid!
//                tracks[index]!.loopsToGrid = zeroArray
//                tracks[index]!.loopsToGridMapped = AppUtils.areaOfInterestGridMapped(
//                    areaOfInterest: zeroArray,
//                    loopsToGrid: zeroArray
//                )
                
                var notesToGrid:[Int] = []
                if tracks[index]!.midiGroup.count > 0 {
                    notesToGrid = Array(repeating: tracks[index]!.midiGroup.first!, count: cells)
                }
                else {
                    notesToGrid = Array(repeating: 48, count: cells)
                }
                tracks[index]!.notesToGrid = notesToGrid
            }
        }
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
