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
        let columns = mainViewModel.mainState.setSettings.gridColumns
        let rows = mainViewModel.mainState.setSettings.gridRows
        let instrumentAreas = mainViewModel.mainState.setSettings.getInstrumentAreas()
        
        scene.size = size
        scene.scaleMode = .fill
        
        scene.rows = rows
        scene.columns = columns
        scene.instrumentPartAreas = instrumentAreas
        scene.instrumentXs = mainViewModel.mainState.setSettings.spriteKitInstrumentXs(
            instrumentAreas: instrumentAreas,
            size: size,
            columns: columns
        )
        let instrumentYs = mainViewModel.mainState.setSettings.spriteKitInstrumentYs(
            instrumentAreas: instrumentAreas
        )
        scene.instrumentYs = instrumentYs
        scene.rememberYs = instrumentYs
        scene.yStep = size.height / CGFloat(rows)
        scene.sessionSkin = mainViewModel.mainState.sessionSettings.activeSkin
//        scene.videoOpacity = playViewModel.playViewState.displayOpacity
        
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
                    SpriteView(
                        scene: scene,
                        options: [.allowsTransparency]
                    )
                    .frame(width: width, height: height - transportHeigth - 10)
                    .ignoresSafeArea()
                    //Cello
                    .onReceive(playViewModel.conductor.spriteKitParts0a){ ( value ) in
                        
                        scene.instrumentPart0aMaxIndex = value.0
                        scene.instrumentPart0aScale = CGFloat(value.1)
                    }
                    //Drums
                    .onReceive(playViewModel.conductor.spriteKitParts1a){ ( value ) in
                        
                        scene.instrumentPart1aMaxIndex = value.0
                        scene.instrumentPart1aScale = CGFloat(value.1)
                    }
                    //Bassline
                    .onReceive(playViewModel.conductor.spriteKitParts2a){ ( value ) in
                        
                        scene.instrumentPart2aMaxIndex = value.0
                        scene.instrumentPart2aScale = CGFloat(value.1)
                    }
                    //Synth
                    .onReceive(playViewModel.conductor.spriteKitParts3a){ ( value ) in
                        
                        scene.instrumentPart3aMaxIndex = value.0
                        scene.instrumentPart3aScale = CGFloat(value.1)
                    }
                    
                    //Video
                    VideoPreviewViewRepresetable(
                        playViewModel: playViewModel
                    )
                    .aspectRatio(1.666666, contentMode: .fit)
                    .overlay(RoundedRectangle(cornerRadius: 10.0).stroke(Color.secondary))
                    .cornerRadius(10.0)
                    .opacity( Double(playViewModel.playViewState.displayOpacity) )
                }
            }
        }
    }
}
