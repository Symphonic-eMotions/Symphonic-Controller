//
//  AmoebaView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 26/06/2023.
//

import SpriteKit
import SwiftUI

struct AmoebaView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
//    @Binding public var sessionDisplay: Binding<SessionDisplay>
//    @Binding public var sessionDisplaySub: Binding<SessionDisplay>
    
    
    
    
    var scene = AmoebaScene()
    
    init(
        setInfoModel: SetInfoModel
//        ,
//        sessionDisplay: Binding<SessionDisplay>,
//        sessionDisplaySub: Binding<SessionDisplay>
    ) {
        self.setInfoModel = setInfoModel
//        self._sessionDisplay = sessionDisplay
//        self._sessionDisplaySub = sessionDisplaySub
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            SpriteView(
                scene: scene,
                options: [.allowsTransparency]
            )
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.black)
            .onAppear {
                // This will update the scene's rotation duration when the view appears.
                scene.rotationDuration = 25
            }
            .onReceive(spriteKitParts1a) { value in
                
                let rotationDuration = setInfoModel.scale(
                    input: value.2, fromInputRange: (0,1), toOutputRange: (10000,10)
                )
                
                print(rotationDuration)
                
                scene.rotationDuration = rotationDuration
                
                // This will update the scene's rotation duration whenever the duration in setInfoModel changes.
//                scene.instrumentPart1aMaxIndex = value.0
//                scene.instrumentPart1aMidiClip = value.1
//                scene.instrumentPart1aScale = CGFloat(value.2)
            }
        }
    }
}
