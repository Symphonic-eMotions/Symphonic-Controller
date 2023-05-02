//
//  SpriteKitSettings.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 02/05/2023.
//

import Foundation

extension SetSettings {
    
    internal func getLevels() -> [[Int]] {
        
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
    internal func spriteKitInstruments(
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
    
    internal func flatttenParts(
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
    
    //Collect instrument areas
    internal func getInstrumentAreas() -> [[[Int]]] {
        
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
    
    internal func reverseNumber(number:Int, min:Int, max:Int) -> Int{
        return (max + min) - number
    }
    
    func updateLimiter( instrumentAreas: [[[Int]]] ) -> [Int] {
        var midiClips: [Int] = []
        for _ in instrumentAreas {
            midiClips.append(-1)
        }
        return midiClips
    }
}
