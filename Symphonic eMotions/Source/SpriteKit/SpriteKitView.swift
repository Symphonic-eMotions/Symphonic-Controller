//
//  SpriteKitView.swift
//  Symphonic eMotions Pro RC
//
//  Created by Frans-Jan Wind on 31/01/2023.
//

import SpriteKit
import SwiftUI



//SwiftUI creating a GameScene and sizing it
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
        scene.size = CGSize(width: width, height: height - transportHeigth)
        scene.scaleMode = .fill
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
            
            SpriteKitTransport(
                mainViewModel: mainViewModel,
                playViewModel: playViewModel,
                sessionDisplay: $sessionDisplay,
                transportHeigth: transportHeigth
            )
            
            SpriteView(
                scene: scene,
                options: [.allowsTransparency]
            )
            .frame(width: width, height: height - transportHeigth - 10)
            .ignoresSafeArea()
            .onReceive(playViewModel.conductor.spriteKitParts0a){ ( value ) in
    
                scene.instrumentPart0aScale = CGFloat(value)
            }
        }
    }
}
