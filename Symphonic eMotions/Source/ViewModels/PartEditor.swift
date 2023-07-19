//
//  PartEditor.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 19/07/2023.
//

import SwiftUI

extension SetInfoModel {
    
    //Part editor
    public func partColor(row: Int, column: Int) -> Color {
        
        let trackId = self.partFeedback.currentTrackID.value
        
        if trackId == "" {
            return .black.opacity(0.01)
        }
        
        let partId = self.partFeedback.currentPartID.value
        
        if partId == "" {
            return .black.opacity(0.01)
        }
        
        let index: Int = row * setSettings.gridColumns + column
        
        let color = setSettings.tracks[trackId]?.parts[partId]?.areaOfInterestColor[index] ?? .red
        
        return color
    }
    
    public func partDegree(row: Int, column: Int) -> Double {

        let trackId = self.partFeedback.currentTrackID.value
        if trackId == "" {
            return 0
        }

        let partId = self.partFeedback.currentPartID.value
        if partId == "" {
            return 0
        }

        if setSettings.tracks[trackId]?.parts[partId]?.partNumber == 1 {
            return 25
        }
        else if setSettings.tracks[trackId]?.parts[partId]?.partNumber == 2 {
            return -25
        }

        return 0
    }
    
    public func tapOnCell(row: Int, column: Int){
        
        let trackId = self.partFeedback.currentTrackID.value
        if trackId == "" {
            print("tapOnCell No track selected")
            return
        }
        
        let partId = self.partFeedback.currentPartID.value
        if partId == "" {
            print("tapOnCell No part selected")
            return
        }
        
        let index: Int = row * setSettings.gridColumns + column
        
        //Update areaOfInterest and areaOfInterestColor for storage
        if self.setSettings.tracks[trackId]!.parts[partId]!.areaOfInterest[index] == 1 {
            self.setSettings.tracks[trackId]!.parts[partId]!.areaOfInterest[index] = 0
            self.setSettings.tracks[trackId]!.parts[partId]!.areaOfInterestColor[index] = .white.opacity(0.01)
        }
        else {
            self.setSettings.tracks[trackId]!.parts[partId]!.areaOfInterest[index] = 1
            self.setSettings.tracks[trackId]!.parts[partId]!.areaOfInterestColor[index] = self.setSettings.tracks[trackId]!.instrumentColor
        }
        
        //Get new connection with clip positions
        self.setSettings.tracks[trackId]!.loopsToGridMapped = AppUtils.areaOfInterestGridMapped(
            areaOfInterest: self.setSettings.tracks[trackId]!.parts[partId]!.areaOfInterest,
            cellsToGrid: self.setSettings.tracks[trackId]!.loopsToGrid)
        
        //Get new connections with note positions
        self.setSettings.tracks[trackId]!.notesToGridMapped = AppUtils.areaOfInterestGridMapped(
            areaOfInterest: self.setSettings.tracks[trackId]!.parts[partId]!.areaOfInterest,
            cellsToGrid: self.setSettings.tracks[trackId]!.notesToGrid)
        
        //Update this var to update View
        self.setInfoState.updateEditView += 1
    }

    //PlayGridView AlL Track / Part colors at correct Indexes
    public func colorTypes(row: Int, column: Int) -> [ColorType] {
        
        let colors = colorsPerTrack(
            row: row, column: column, currentLevel: Int( self.leveling.currentSetLevelSubject.value )
        )
        
        guard isSetPlaying else { return colors }
        
        if row < self.setInfoState.values.count {
            if column < self.setInfoState.values[row].count {
                return colors.map {
                    ColorType(color: $0.color.opacity(CGFloat(self.setInfoState.values[row][column].scaledValue)))
                }
            }
        }
        return colors
    }
    
    //PlayGridView Get colors per track, ColorTypes make iterating in a SwiftUI View possible
    func colorsPerTrack(row: Int, column: Int, currentLevel: Int) -> [ColorType] {
        
        var colors: [ColorType] = []
        
        for settingsTrack in setSettings.tracks {
            
            if settingsTrack.value.levels.contains(currentLevel){
                
                let trackColor = settingsTrack.value.instrumentColor
                
                for setPart in settingsTrack.value.parts {
                    
                    //FIXME: add currentLevel
                    if !setPart.value.dontDrawVisual {
                        
                        if setPart.value.isIndexSelected(
                            row: row,
                            column: column,
                            gridRows: setSettings.gridRows,
                            gridColumns: setSettings.gridColumns){
                            
                            colors.append(ColorType(color: trackColor))
                        }
                    }
                }
            }
        }
        
        return colors.isEmpty ? [ColorType(color: .black.opacity(0.01))] : colors
    }
}
