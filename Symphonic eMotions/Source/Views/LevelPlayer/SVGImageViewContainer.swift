//
//  SVGImageViewContainer.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 14/03/2024.
//

import SwiftUI

struct SVGImageViewContainer: View {
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var gridModel: GridModel
    @Binding var showLevelPlayerFullScreen: Bool
    //Also used for storing SVGPositions
    var levelFromIndex: Int
    var geometry: GeometryProxy
    
    
    var body: some View {

        let scaleOpacity = calculateScaleOpacity(for: levelFromIndex)
        // Bereken de offset gebaseerd op originalPosition en lastSVGPosition
        let position = gridModel.svgPositions[levelFromIndex] ?? SVGPosition(originalPosition: .zero, lastSVGPosition: .zero)
        let offsetX = position.lastSVGPosition.x - position.originalPosition.x
        let offsetY = position.lastSVGPosition.y - position.originalPosition.y

        SVGImageView(
            level: levelFromIndex,
            imageName: "level\(setInfoModel.setSettings.setPath)\(levelFromIndex)",
            scale: CGFloat(scaleOpacity.0),
            opacity: CGFloat(scaleOpacity.1)
        )
        .frame(width: showLevelPlayerFullScreen ? UIScreen.main.bounds.width : geometry.size.width, height: showLevelPlayerFullScreen ? UIScreen.main.bounds.height : geometry.size.height)
        .offset(x: offsetX, y: offsetY)
        .onAppear {
            // Update de positie wanneer de view verschijnt of de layout verandert
            let newSVGPosition = geometry.frame(in: .global).origin
            gridModel.updateSVGPosition(
                for: levelFromIndex,
                originalPosition: newSVGPosition, // Pas dit aan indien nodig
                newPosition: newSVGPosition
            )
        }
    }

    //@var (scale Float, Opacity Float)
    private func calculateScaleOpacity(for levelFromIndex: Int) -> (Float,Float) {
        
        //Amount of overlap next over previous level animation
        let overlap: Double = 0.25
        //Initial opcaity value
        var opacityBound: Float = 1
        // All level information
        let allLevelProgress = setInfoModel.leveling.currentSetLevelSubject.value
        // Current level
        let currentLevelValue = allLevelProgress - Double(levelFromIndex)
        
        // De exponent die je wilt gebruiken, dit kan elke waarde zijn die je instelt
        let exponentValue: Double = 0.9 // Voorbeeldwaarde, aanpasbaar naar wens

        // Bereken de waarde verheven tot de macht van de exponent
        let exponentiatedValue = Float(pow(currentLevelValue, exponentValue))
        
        //We starten de animatie op overlap voor 0
        if (allLevelProgress - overlap) > (0 - overlap) {
                
            //is de level reeds geweest? Start 2nd level animation
            if (exponentiatedValue > 1) {
                
                let opacityDouble = Double(exponentiatedValue)
                let opacity = opacityDouble.transform(
                    outputStart: 1,
                    outputEnd: 0.1,
                    inputStart: 1,
                    inputEnd: 1.8,
                    transformationDegree: 0
                )
                opacityBound = Float(max(0,min(1,opacity)))
            }

            return (max(0, exponentiatedValue),opacityBound)
        }
        // De animatie nog niet starten
        else {
            return (0,opacityBound)
        }
    }
}

