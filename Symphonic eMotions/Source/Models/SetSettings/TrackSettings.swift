//
//  TrackSettings.swift
//  Symphonic eMotions Intern
//
//  Created by Frans-Jan Wind on 16/02/2023.
//

import OrderedCollections
import SwiftUI

class TrackSettings: Identifiable, ObservableObject {
    var trackId: String
    var trackName: String
    var trackType: TrackType
    var instrumentVolume: Float
    var instrumentColor: Color
    var midiFile: String
    var midiGroup: [Int]
    var loopLength: [Double]
    var loopsToLevel: [Int]
    var loopsToGrid: [Int]
    var loopsToGridMapped: [Int]
    var levels: [Int]
    var parts: OrderedDictionary<String, PartSettings>
    
    init(
        trackId: String,
        trackName: String,
        trackType: TrackType,
        instrumentVolume: Float,
        instrumentColor: Color,
        midiFile: String,
        midiGroup: [Int],
        loopLength: [Double],
        loopsToLevel: [Int],
        loopsToGrid: [Int],
        loopsToGridMapped: [Int],
        levels: [Int],
        parts: OrderedDictionary<String, PartSettings>
    ){
        self.trackId = trackId
        self.trackName = trackName
        self.trackType = trackType
        self.instrumentVolume = instrumentVolume
        self.instrumentColor = instrumentColor
        self.midiFile = midiFile
        self.midiGroup = midiGroup
        self.loopLength = loopLength
        self.loopsToLevel = loopsToLevel
        self.loopsToGrid = loopsToGrid
        self.loopsToGridMapped = loopsToGridMapped
        self.levels = levels
        self.parts = parts
    }
    
    func changeAreaOfInterestColor(newColor: Color){
        for partId in self.parts.keys {
            self.parts[partId]?.areaOfInterestColor = AppUtils.getPartColors(trackColor: newColor, areaOfInterest: self.parts[partId]!.areaOfInterest)
        }
    }
    
}
