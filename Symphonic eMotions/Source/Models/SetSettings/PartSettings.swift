//
//  PartSettings.swift
//  Symphonic eMotions Intern
//
//  Created by Frans-Jan Wind on 16/02/2023.
//

import SwiftUI

class PartSettings: Identifiable {
    
    var partId: String
    var partName: String
    var partNumber: Int
    var rampUp: Double
    var rampDown: Double
    var minimalLevel: Double
    var areaOfInterest: [Int]
    var areaOfInterestColor: [Color]
    var damperTarget: InstrumentsSet.Track.Part.DamperTarget
    var dontDrawVisual: Bool
    
    //Controllers
    var dampMode: InstrumentsSet.Track.Part.DamperTarget.DampMode
    var targetType: InstrumentsSet.Track.Part.DamperTarget.NodeType
    var targetNameEffect: InstrumentsSet.Track.Effect.EffectType
    var targetParameterEffect: InstrumentsSet.Track.Effect.EffectKeys
    
    init(partId: String,
         partName: String,
         partNumber: Int,
         rampUp: Double,
         rampDown: Double,
         minimalLevel: Double,
         areaOfInterest: [Int],
         areaOfInterestColor: [Color],
         damperTarget: InstrumentsSet.Track.Part.DamperTarget,
         dontDrawVisual: Bool,
         dampMode: InstrumentsSet.Track.Part.DamperTarget.DampMode,
         targetType: InstrumentsSet.Track.Part.DamperTarget.NodeType,
         targetNameEffect: InstrumentsSet.Track.Effect.EffectType,
         targetParameterEffect: InstrumentsSet.Track.Effect.EffectKeys
    ){
        self.partId = partId
        self.partName = partName
        self.partNumber = partNumber
        self.rampUp = rampUp
        self.rampDown = rampDown
        self.minimalLevel = minimalLevel
        self.areaOfInterest = areaOfInterest
        self.areaOfInterestColor = areaOfInterestColor
        self.damperTarget = damperTarget
        self.dontDrawVisual = dontDrawVisual
        self.dampMode = dampMode
        self.targetType = targetType
        self.targetNameEffect = targetNameEffect
        self.targetParameterEffect = targetParameterEffect
    }
    
    func interestIndexes(rows: Int, columns: Int) -> [InstrumentsSet.Track.Part.Index] {
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
        self.interestIndexes( rows: gridRows, columns: gridColumns).contains { $0.column == column && $0.row == row }
    }
}
