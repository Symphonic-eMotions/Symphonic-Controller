//
//  SetInfoModelPartEditor.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 19/07/2023.
//

import SwiftUI

extension SetInfoModel {
    // Part editor
    func partColor(row: Int, column: Int) -> Color {
        let trackId = partFeedback.currentTrackID.value

        if trackId == "" {
            return .black.opacity(0.01)
        }

        let partId = partFeedback.currentPartID.value

        if partId == "" {
            return .black.opacity(0.01)
        }

        let index: Int = row * setSettings.gridColumns + column

        let color = setSettings.tracks[trackId]?.parts[partId]?.areaOfInterestColor[index] ?? .red

        return color
    }

    func partDegree(row _: Int, column _: Int) -> Double {
        let trackId = partFeedback.currentTrackID.value
        if trackId == "" {
            return 0
        }

        let partId = partFeedback.currentPartID.value
        if partId == "" {
            return 0
        }

        if setSettings.tracks[trackId]?.parts[partId]?.partNumber == 1 {
            return 25
        } else if setSettings.tracks[trackId]?.parts[partId]?.partNumber == 2 {
            return -25
        }

        return 0
    }

    func tapOnCell(row: Int, column: Int) {
        let trackId = partFeedback.currentTrackID.value
        if trackId == "" {
            print("tapOnCell No track selected")
            return
        }

        let partId = partFeedback.currentPartID.value
        if partId == "" {
            print("tapOnCell No part selected")
            return
        }

        let index: Int = row * setSettings.gridColumns + column

        // Update areaOfInterest and areaOfInterestColor for storage
        if setSettings.tracks[trackId]!.parts[partId]!.areaOfInterest[index] == 1 {
            setSettings.tracks[trackId]!.parts[partId]!.areaOfInterest[index] = 0
            setSettings.tracks[trackId]!.parts[partId]!.areaOfInterestColor[index] = .white.opacity(0.01)
        } else {
            setSettings.tracks[trackId]!.parts[partId]!.areaOfInterest[index] = 1
            setSettings.tracks[trackId]!.parts[partId]!.areaOfInterestColor[index] = setSettings.tracks[trackId]!.instrumentColor
        }

        // Get new connection with clip positions
        setSettings.tracks[trackId]!.loopsToGridMapped = AppUtils.areaOfInterestGridMapped(
            areaOfInterest: setSettings.tracks[trackId]!.parts[partId]!.areaOfInterest,
            cellsToGrid: setSettings.tracks[trackId]!.loopsToGrid
        )

        // Get new connections with note positions
        setSettings.tracks[trackId]!.notesToGridMapped = AppUtils.areaOfInterestGridMapped(
            areaOfInterest: setSettings.tracks[trackId]!.parts[partId]!.areaOfInterest,
            cellsToGrid: setSettings.tracks[trackId]!.notesToGrid
        )

        // Update this var to update View
        setInfoState.updateEditView += 1
    }

    // PlayGridView AlL Track / Part colors at correct Indexes
    func colorTypes(row: Int, column: Int) -> [ColorType] {
        let colors = colorsPerTrack(
            row: row, column: column, currentLevel: Int(leveling.currentSetLevelSubject.value)
        )

        guard userSettings.isSetPlaying else { return colors }

        if row < setInfoState.values.count {
            if column < setInfoState.values[row].count {
                return colors.map {
                    ColorType(color: $0.color.opacity(CGFloat(self.setInfoState.values[row][column].scaledValue)))
                }
            }
        }
        return colors
    }

    // PlayGridView Get colors per track, ColorTypes make iterating in a SwiftUI View possible
    internal func colorsPerTrack(row: Int, column: Int, currentLevel: Int) -> [ColorType] {
        var colors: [ColorType] = []

        for settingsTrack in setSettings.tracks {
            if settingsTrack.value.levels.contains(currentLevel) {
                let trackColor = settingsTrack.value.instrumentColor

                for setPart in settingsTrack.value.parts {
                    // FIXME: add currentLevel
                    if !setPart.value.dontDrawVisual {
                        if setPart.value.isIndexSelected(
                            row: row,
                            column: column,
                            gridRows: setSettings.gridRows,
                            gridColumns: setSettings.gridColumns
                        ) {
                            colors.append(ColorType(color: trackColor))
                        }
                    }
                }
            }
        }

        return colors.isEmpty ? [ColorType(color: .black.opacity(0.01))] : colors
    }
}
