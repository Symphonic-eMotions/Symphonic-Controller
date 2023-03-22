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
    @State var showOverView: Bool = false
    let transportHeigth: CGFloat = 50
    
    //Create the complete 2D "gaming" interface
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
        let levels = mainViewModel.mainState.setSettings.getLevels()
        
        scene.isPlaying = mainViewModel.conductor.isConductorPlayingSubject.value
        scene.backgroundColor = .clear
        scene.size = size
        scene.scaleMode = .fill
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        scene.rows = rows
        scene.columns = columns
        scene.instrumentPartAreas = instrumentAreas
        scene.levels = levels
        
        //For now we have 4 instruments who control unique named variables in the SKScene
        var instruments = mainViewModel.mainState.setSettings.spriteKitInstruments(
            instrumentIndex: 0,
            instrumentAreas: instrumentAreas,
            size: size,
            columns: columns,
            rows: rows
        )
        scene.instrument0Positions = instruments.0
        scene.instrument0Sizes = instruments.1
        
        instruments = mainViewModel.mainState.setSettings.spriteKitInstruments(
            instrumentIndex: 1,
            instrumentAreas: instrumentAreas,
            size: size,
            columns: columns,
            rows: rows
        )
        scene.instrument1Positions = instruments.0
        scene.instrument1Sizes = instruments.1
        
        instruments = mainViewModel.mainState.setSettings.spriteKitInstruments(
            instrumentIndex: 2,
            instrumentAreas: instrumentAreas,
            size: size,
            columns: columns,
            rows: rows
        )
        scene.instrument2Positions = instruments.0
        scene.instrument2Sizes = instruments.1
        
        instruments = mainViewModel.mainState.setSettings.spriteKitInstruments(
            instrumentIndex: 3,
            instrumentAreas: instrumentAreas,
            size: size,
            columns: columns,
            rows: rows
        )
        scene.instrument3Positions = instruments.0
        scene.instrument3Sizes = instruments.1
        //Frameskipper particle emitters per instrument
        scene.updateLimiter = mainViewModel.mainState.setSettings.updateLimiter(
            instrumentAreas: instrumentAreas
        )
        //We store the skin within the session
        
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
            VStack{
                SpriteKitTransport(
                    mainViewModel: mainViewModel,
                    playViewModel: playViewModel,
                    sessionDisplay: $sessionDisplay,
                    transportHeigth: transportHeigth
                )
                //SKScene with underneat a video (camera) preview
                ZStack{
                    
                    //Video (Camera), first is by default the bottom View in ZStack
                    //Adjustable through displayOpacity
                    VideoPreviewViewRepresetable(
                        playViewModel: playViewModel
                    )
                    .aspectRatio(1.666666, contentMode: .fit)
                    .overlay(RoundedRectangle(cornerRadius: 10.0).stroke(Color.secondary))
                    .cornerRadius(10.0)
                    .opacity( Double(playViewModel.playViewState.displayOpacity) )
                    
                    
                    //The SpriteKit interface with layered SwiftUI calibrator
                    SpriteView(
                        scene: scene,
                        options: [.allowsTransparency]
                    )
                    .frame(width: width, height: height - transportHeigth - 10)
                    .ignoresSafeArea()
                    .onReceive(mainViewModel.conductor.isConductorPlayingSubject ){ ( value ) in
                        scene.isPlaying = value
                    }
                    .onReceive(mainViewModel.leveling.currentSetLevelSubject ){ ( value ) in
                        scene.currentLevel = value
                    }
                    //Again 4 static instruments
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
                    .onLongPressGesture {
                        self.showOverView.toggle()
                    }
                    
                    //The calibrator slider and video slider
                    if showOverView {
                        SensitivityView(
                            playViewModel: playViewModel
                        )
                    }
                }
            }
        }
    }
}
