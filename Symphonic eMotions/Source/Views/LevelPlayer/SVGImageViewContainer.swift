//
//  SVGImageViewContainer.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 14/03/2024.
//

import SwiftUI

struct SVGImageViewContainer: View {
    
    @ObservedObject var levelPlayerModel: LevelPlayerModel
    @ObservedObject var setInfoModel: SetInfoModel
    var geometry: GeometryProxy
    var level: Int
    var imageName: String
    @Binding var scale: Float
    
    var body: some View {
        
        let scaleOpcity = calculateScaleOpacity(for: level)
        
        SVGImageView(
            levelPlayerModel: levelPlayerModel,
            level: level,
            imageName: "level\(level)",
            scale: CGFloat(scaleOpcity.0), 
            opacity: CGFloat(scaleOpcity.1)

        )
        .frame(
            width: geometry.size.width,
            height: geometry.size.height
        )
    }
    
    //@var scale Float Opacity Float
    private func calculateScaleOpacity(for level: Int) -> (Float,Float) {
        
        //Amount of overlap next over previous level animation
        let overlap: Double = 0.25
        //Initial opcaity value
        var opacityBound: Float = 1
        
        // All level information
        let allLevelProgress = setInfoModel.leveling.currentSetLevelSubject.value
        // Current level
        let currentLevelValue = Float(allLevelProgress - Double(level))
        
        //We starten de animatie op overlap voor 0
        if (allLevelProgress - overlap) > (0 - overlap) {
                
            //is de level reeds geweest? Start 2nd level animation
            if (currentLevelValue > 1) {
                
                let opacityDouble = Double(currentLevelValue)
                let opacity = opacityDouble.transform(
                    outputStart: 1,
                    outputEnd: 0,
                    inputStart: 1,
                    inputEnd: 1.5,
                    transformationDegree: 0
                )
                opacityBound = Float(max(0,min(1,opacity)))
            }
            let maxCurrentLevelValue = max(0, currentLevelValue)

            return (maxCurrentLevelValue,opacityBound)
        }
        // De animatie nog niet starten
        else {
            return (0,opacityBound)
        }
    }
}
