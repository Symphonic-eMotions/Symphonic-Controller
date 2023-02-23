//
//  SpriteKitZonesView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 07/02/2023.
//

import SpriteKit
import SwiftUI

struct Zone {
    
    let columns: Int
//    let column: Int
    let zoneWidth: CGFloat
//    let zoneHeigth: CGFloat
    let centerWidth: CGFloat
    
    init(columns: Int) {
        self.columns = columns
        self.zoneWidth = 1/CGFloat(columns)
//        self.celHeight = 1/Float(rows)
        self.centerWidth = self.zoneWidth/2
//        self.centerHeigth = self.celHeight/2
    }
}

struct ZoneInstrument{
    
    let color:UIColor
    let shape:String
    let image:String
    let areas:[Int]
}

class ZoneScene: SKScene {
        
    //GameScene globals to change through update
    var instrumentPart0a: SKShapeNode!
    var instrumentPart0aScale: CGFloat = 0
    
    var sessionSkin: InstrumentsSet.Skin!
    
    //Columns
    let columns = 4
    let rows = 4
    
    override func didMove(to view: SKView) {
        
        //Initialize instruments and zones
        let instruments = sessionSkin.instruments
        let zone = Zone(columns: columns)
        
        setupZones(zone: zone, instruments: instruments)
    }
    
    func setupZones(zone: Zone, instruments: [InstrumentsSet.Skin.Instrument]) -> Void {
        
        //Create instrument rectangle based on first instrument part location
        let instrument = instruments[0]
        
        print(instrument)
        
        //scnView.backgroundColor = NSColor.lightGray
    }
}

//Import SpriteKit into SwiftUI View
//Have observable objects fo interaction with SpriteKit
struct SpriteKitZonesView: View {
    
    @ObservedObject var playViewModel: PlayViewModel
    @ObservedObject var mainViewModel: MainViewModel
    @Binding public var sessionDisplay: SessionDisplay
    
    let transportHeigth: CGFloat = 50
    var scene = ZoneScene()
    
    init(playViewModel:PlayViewModel,
         mainViewModel:MainViewModel,
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
        let width:CGFloat = 1024
        let height:CGFloat = 960
        #else
        let width:CGFloat = UIScreen.main.bounds.width
        let height:CGFloat = UIScreen.main.bounds.height
        #endif
        
        VStack{
            
            SpriteKitTransport(
                mainViewModel: mainViewModel,
                playViewModel: playViewModel,
                sessionDisplay: $sessionDisplay,
//                viewModelPlayerControls: PlayerControlsViewModel(
//                    playerControlsViewState: PlayerControlsViewState(
//                        displayMode: playViewModel.playViewState.displayMode,
//                        buildSettings: playViewModel.playViewState.buildSettings
//                    ),
//                    conductor: playViewModel.conductor,
//                    frameExtractor: playViewModel.frameExtractor,
//                    leveling: playViewModel.leveling,
//                    setSettings: playViewModel.setSettings,
//                    hasTempo: playViewModel.playViewState.currentInstrumentsSet.hasTempo,
//                    playerControlsAction: playViewModel.controlsViewAction(action:)
//
//                ),
                transportHeigth: transportHeigth
            )
            
            SpriteView(scene: scene, options: [.allowsTransparency])
                .frame(width: width, height: height - transportHeigth - 10)
                .ignoresSafeArea()
                .onReceive(playViewModel.conductor.spriteKitParts0a){ ( value ) in
                    
//                    print("Received: spriteKitParts0a \(value)")
                    
                    scene.instrumentPart0aScale = CGFloat(value)
                }
            
        }
    }
}
