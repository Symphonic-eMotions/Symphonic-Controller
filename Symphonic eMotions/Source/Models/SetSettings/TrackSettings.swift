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
    var instrumentVolume: Float
    var instrumentColor: Color
    var loopLength: [Double]
    var loopsToGrid: [Int]
    var levels: [Int]
    var parts: OrderedDictionary<String, PartSettings>
    
    init(
        trackId: String,
        trackName: String,
        instrumentVolume: Float,
        instrumentColor: Color,
        loopLength: [Double],
        loopsToGrid: [Int],
        levels: [Int],
        parts: OrderedDictionary<String, PartSettings>
    ){
        self.trackId = trackId
        self.trackName = trackName
        self.instrumentVolume = instrumentVolume
        self.instrumentColor = instrumentColor
        self.loopLength = loopLength
        self.loopsToGrid = loopsToGrid
        self.levels = levels
        self.parts = parts
    }
    
    func changeAreaOfInterestColor(newColor: Color){
        for partId in self.parts.keys {
            self.parts[partId]?.areaOfInterestColor = AppUtils.getPartColors(trackColor: newColor, areaOfInterest: self.parts[partId]!.areaOfInterest)
        }
    }
}
