//
//  SpriteKitView.swift
//  Symphonic eMotions Pro RC
//
//  Created by Frans-Jan Wind on 31/01/2023.
//

import SpriteKit
import SwiftUI

//SwiftUI creating a SpriteKit scene and sizing it
struct SpriteKitView: View {
    
    @ObservedObject var playViewModel: PlayViewModel
    @ObservedObject var mainViewModel: MainViewModel
    @Binding public var sessionDisplay: SessionDisplay
    let transportHeigth: CGFloat = 50
    
    var scene = CellScene()
    
    init( playViewModel: PlayViewModel,
          mainViewModel: MainViewModel,
          sessionDisplay: Binding<SessionDisplay>
    ) {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        let size = CGSize(width: width, height: height - transportHeigth)
        let rows = mainViewModel.mainState.setSettings.gridRows
        let columns = mainViewModel.mainState.setSettings.gridColumns
        let instrumentAreas = mainViewModel.mainState.setSettings.getInstrumentAreas()
        
        scene.backgroundColor = .clear
        scene.size = size
        scene.scaleMode = .fill
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        scene.rows = rows
        scene.columns = columns
        scene.instrumentPartAreas = instrumentAreas
        
        var instrumentPositions = mainViewModel.mainState.setSettings.spriteKitInstrumenPositions(
            instrumentIndex: 0,
            instrumentAreas: instrumentAreas,
            size: size,
            columns: columns,
            rows: rows
        )
        scene.instrument0Positions = instrumentPositions
        
        instrumentPositions = mainViewModel.mainState.setSettings.spriteKitInstrumenPositions(
            instrumentIndex: 1,
            instrumentAreas: instrumentAreas,
            size: size,
            columns: columns,
            rows: rows
        )
        scene.instrument1Positions = instrumentPositions
        
        instrumentPositions = mainViewModel.mainState.setSettings.spriteKitInstrumenPositions(
            instrumentIndex: 2,
            instrumentAreas: instrumentAreas,
            size: size,
            columns: columns,
            rows: rows
        )
        scene.instrument2Positions = instrumentPositions
        
        instrumentPositions = mainViewModel.mainState.setSettings.spriteKitInstrumenPositions(
            instrumentIndex: 3,
            instrumentAreas: instrumentAreas,
            size: size,
            columns: columns,
            rows: rows
        )
        scene.instrument3Positions = instrumentPositions
        
        
        scene.updateLimiter = mainViewModel.mainState.setSettings.updateLimiter(
            instrumentAreas: instrumentAreas
        )
        scene.sessionSkin = mainViewModel.mainState.sessionSettings.activeSkin
        
        self.playViewModel = playViewModel
        self.mainViewModel = mainViewModel
        self._sessionDisplay = sessionDisplay
    }
    
    var body: some View {
        
        #if targetEnvironment(macCatalyst)
        let width:CGFloat = UIScreen.main.bounds.width / 2
        let height:CGFloat = UIScreen.main.bounds.height / 2
        #else
        let width:CGFloat = UIScreen.main.bounds.width
        let height:CGFloat = UIScreen.main.bounds.height
        #endif
        
        VStack(spacing: 0){
            //Stack
            
            VStack{
                SpriteKitTransport(
                    mainViewModel: mainViewModel,
                    playViewModel: playViewModel,
                    sessionDisplay: $sessionDisplay,
                    transportHeigth: transportHeigth
                )
                ZStack{
                    
                    //Video
                    VideoPreviewViewRepresetable(
                        playViewModel: playViewModel
                    )
                    .aspectRatio(1.666666, contentMode: .fit)
                    .overlay(RoundedRectangle(cornerRadius: 10.0).stroke(Color.secondary))
                    .cornerRadius(10.0)
                    .opacity( Double(playViewModel.playViewState.displayOpacity) )
                    
                    
                    //The SpriteKit interface
                    SpriteView(
                        scene: scene,
                        options: [.allowsTransparency]
                    )
                    .frame(width: width, height: height - transportHeigth - 10)
                    .ignoresSafeArea()
                    //First configured instrument (GO Cello)
                    .onReceive(playViewModel.conductor.spriteKitParts0a){ ( value ) in
                        
                        scene.instrumentPart0aMaxIndex = value.0
                        scene.instrumentPart0aMidiClip = value.1
                        scene.instrumentPart0aScale = CGFloat(value.2)
                    }
                    //Second configured instrument (GO Drums)
                    .onReceive(playViewModel.conductor.spriteKitParts1a){ ( value ) in
                        
                        scene.instrumentPart1aMaxIndex = value.0
                        scene.instrumentPart1aMidiClip = value.1
                        scene.instrumentPart1aScale = CGFloat(value.2)
                    }
                    //Bassline
                    .onReceive(playViewModel.conductor.spriteKitParts2a){ ( value ) in
                        
                        scene.instrumentPart2aMaxIndex = value.0
                        scene.instrumentPart2aMidiClip = value.1
                        scene.instrumentPart2aScale = CGFloat(value.2)
                    }
                    //Synth
                    .onReceive(playViewModel.conductor.spriteKitParts3a){ ( value ) in
                        
                        scene.instrumentPart3aMaxIndex = value.0
                        scene.instrumentPart3aMidiClip = value.1
                        scene.instrumentPart3aScale = CGFloat(value.2)
                    }
                    
                    
                }
            }
        }
    }
}
