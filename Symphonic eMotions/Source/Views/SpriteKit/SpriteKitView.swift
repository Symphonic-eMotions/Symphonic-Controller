//
//  SpriteKitView.swift
//  Symphonic eMotions Pro RC
//
//  Created by Frans-Jan Wind on 31/01/2023.
//

import SpriteKit
import SwiftUI
import Combine

//InstrumentParts to SpriteKit through PassthroughSubject

var spriteKitParts0b = PassthroughSubject<(Int,Int,Double), Never>()
var spriteKitParts1b = PassthroughSubject<(Int,Int,Double), Never>()
var spriteKitParts2b = PassthroughSubject<(Int,Int,Double), Never>()
var spriteKitParts3b = PassthroughSubject<(Int,Int,Double), Never>()

//SwiftUI creating a SpriteKit scene and sizing it
struct SpriteKitView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var mainViewModel: MainViewModel
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    @State private var presentSettingSheet = false
    
    let transportHeigth: CGFloat = 50
    
    //Create the complete 2D "gaming" interface
    var scene = CellScene()
    
    init( setInfoModel: SetInfoModel,
          mainViewModel: MainViewModel,
          sessionDisplay: Binding<SessionDisplay>,
          sessionDisplaySub: Binding<SessionDisplay>
    ) {
        //These are defined twice, this one for init and the second for body
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        let size = CGSize(width: width, height: height - transportHeigth)
        let rows = mainViewModel.mainState.setSettings.gridRows
        let columns = mainViewModel.mainState.setSettings.gridColumns
        let instrumentAreas = mainViewModel.mainState.setSettings.getInstrumentAreas()
        let levels = mainViewModel.mainState.setSettings.getLevels()
        
//        scene.isPlaying = appModel.isPlaying
        scene.backgroundColor = .clear
        scene.size = size
        scene.scaleMode = .fill
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        scene.rows = rows
        scene.columns = columns
        scene.instrumentPartAreas = instrumentAreas
        scene.levels = levels
        scene.sceneSkin = setInfoModel.setSettings.skins
        
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
        
        self.setInfoModel = setInfoModel
        self.mainViewModel = mainViewModel
        self._sessionDisplay = sessionDisplay
        self._sessionDisplaySub = sessionDisplaySub
    }
    
    var body: some View {
        
//        #if targetEnvironment(macCatalyst)
//        let width:CGFloat = UIScreen.main.bounds.width / 2
//        let height:CGFloat = UIScreen.main.bounds.height / 2
//        #else
//        let width:CGFloat = UIScreen.main.bounds.width
//        let height:CGFloat = UIScreen.main.bounds.height
//        #endif
        
        VStack(spacing: 0){
            VStack{
                SpriteKitTransport(
//                    mainViewModel: mainViewModel,
                    setInfoModel: setInfoModel,
                    sessionDisplay: $sessionDisplay,
                    sessionDisplaySub: $sessionDisplaySub,
                    transportHeigth: transportHeigth
                )
                //SKScene with underneat a video (camera) preview
                ZStack{
                    GeometryReader { geometry in
                        //Video (Camera), first is by default the bottom View in ZStack
                        //Adjustable through displayOpacity
                        VideoPreviewViewRepresetable(
                            setInfoModel: setInfoModel
                        )
                        .aspectRatio(1.666666, contentMode: .fit)
                        .overlay(RoundedRectangle(cornerRadius: 10.0).stroke(Color.secondary))
                        .cornerRadius(10.0)
                        .opacity( Double(setInfoModel.setInfoState.displayOpacity) )
                        
                        
                        //The SpriteKit interface with layered SwiftUI calibrator
                        SpriteView(
                            scene: scene,
                            options: [.allowsTransparency]
                        )
                        .onAppear{
                            setInfoModel.conductor.playEngineAndTracks(
                                setSettings: setInfoModel.setSettings,
                                level: 0
                            )
                            setInfoModel.conductor.levelController(
                                level: 0,
                                setSettings: setInfoModel.setSettings
                            )
                        }
                        .onDisappear{
                            sessionDisplaySub = .stopped
                            setInfoModel.conductor.pauzeEngineAndStopTracks(
                                setSettings: setInfoModel.setSettings,
                                resetLevels: true
                            )
                        }
                        //Present sheet
                        .sheet(isPresented: $presentSettingSheet) {
                            SettingsSheetView(
                                userSettings: userSettings,
                                setInfoModel: setInfoModel, 
                                sessionDisplaySub: $sessionDisplaySub,
                                showingSheet: $presentSettingSheet
                            )
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .ignoresSafeArea()
//                        .onReceive(appModel.isPlaying ){ ( value ) in
//                            scene.isPlaying = value
//                        }
                        .onReceive(mainViewModel.leveling.currentSetLevelSubject ){ ( value ) in
                            scene.currentLevel = value
                            
                            if mainViewModel.mainState.setSettings.currentPlaylist != .none {
                                if value >= Double(mainViewModel.mainState.setSettings.levels.count) {
                                    self.sessionDisplay = .countDown
                                }
                            }
                        }
                        //Again 4 static instruments
                        //First configured instrument (GO Cello)
                        .onReceive(spriteKitParts0a){ ( value ) in
                            
                            scene.updateInstrumentPart0a(value: value)
                            
//                            scene.instrumentPart0aMaxIndex = value.0
//                            scene.instrumentPart0aMidiClip = value.1
//                            scene.instrumentPart0aScale = CGFloat(value.2)
                        }
                        //Second configured instrument (GO Drums)
                        .onReceive(spriteKitParts1a){ ( value ) in
                            
                            scene.instrumentPart1aMaxIndex = value.0
                            scene.instrumentPart1aMidiClip = value.1
                            scene.instrumentPart1aScale = CGFloat(value.2)
                        }
                        //Bassline
                        .onReceive(spriteKitParts2a){ ( value ) in
                            
                            scene.instrumentPart2aMaxIndex = value.0
                            scene.instrumentPart2aMidiClip = value.1
                            scene.instrumentPart2aScale = CGFloat(value.2)
                        }
                        //Synth
                        .onReceive(spriteKitParts3a){ ( value ) in
                            
                            scene.instrumentPart3aMaxIndex = value.0
                            scene.instrumentPart3aMidiClip = value.1
                            scene.instrumentPart3aScale = CGFloat(value.2)
                        }
                        .onTapGesture {
                            print("short")
                            presentSettingSheet = true
                        }
                        .onLongPressGesture(minimumDuration: 1) {
                            print("long")
                            presentSettingSheet = true
                        }
                    }
                }
                
                HStack{
                    EMButton(action: {
                        setInfoModel.leveling.pauseLevel.toggle()
                    }, color: .accentColor, isSolid: setInfoModel.leveling.pauseLevel) {
                        Text(NSLocalizedString("Hold level", comment: ""))
                    }
                    
                    EMButton(action: {
                        setInfoModel.leveling.pauseLevel = false
                        let nrLevels = setInfoModel.setInfoState.currentInstrumentsSet.levels.count
                        setInfoModel.leveling.currentSetLevelSubject.value = Double(nrLevels) + 0.999
                        sessionDisplaySub = .stopped
                    }, color: .accentColor, isSolid: false) {
                        Text(NSLocalizedString("Finish", comment: ""))
                    }
                }
            }
        }
    }
}
