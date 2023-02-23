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
