//
//  InstrumentLocationContainer.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 17/07/2023.
//

import SwiftUI

struct InstrumentLocationContainer: View {
    
    @EnvironmentObject var userSettings: UserSettings
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    
    var instrument0: ([CGPoint],[CGSize])
//    var instrument1: ([CGPoint],[CGSize])
//    var instrument2: ([CGPoint],[CGSize])
//    var instrument3: ([CGPoint],[CGSize])
    
    let transportHeigth: CGFloat = 50
    
    init( setInfoModel: SetInfoModel,
          sessionDisplay: Binding<SessionDisplay>,
          sessionDisplaySub: Binding<SessionDisplay>
    ) {
        self.setInfoModel = setInfoModel
        self._sessionDisplay = sessionDisplay
        self._sessionDisplaySub = sessionDisplaySub
        
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        let size = CGSize(width: width, height: height - transportHeigth)
        let rows = setInfoModel.setSettings.gridRows
        let columns = setInfoModel.setSettings.gridColumns
        let instrumentAreas = setInfoModel.setSettings.getInstrumentAreas()
//        let levels = setInfoModel.setSettings.getLevels()
        
        instrument0 = setInfoModel.setSettings.spriteKitInstruments(
            instrumentIndex: 0,
            instrumentAreas: instrumentAreas,
            size: size,
            columns: columns,
            rows: rows
        )
        
//        instrument1 = setInfoModel.setSettings.spriteKitInstruments(
//            instrumentIndex: 1,
//            instrumentAreas: instrumentAreas,
//            size: size,
//            columns: columns,
//            rows: rows
//        )
//
//        instrument2 = setInfoModel.setSettings.spriteKitInstruments(
//            instrumentIndex: 2,
//            instrumentAreas: instrumentAreas,
//            size: size,
//            columns: columns,
//            rows: rows
//        )
//
//        instrument3 = setInfoModel.setSettings.spriteKitInstruments(
//            instrumentIndex: 3,
//            instrumentAreas: instrumentAreas,
//            size: size,
//            columns: columns,
//            rows: rows
//        )
    }
    
    @State private var presentSettingSheet = false
    
    var body: some View {
        
        VStack(spacing: 0){
            
            SpriteKitTransport(
                setInfoModel: setInfoModel,
                sessionDisplay: $sessionDisplay,
                sessionDisplaySub: $sessionDisplaySub,
                transportHeigth: transportHeigth
            )
            
            ZStack(alignment: .topLeading){
                
                GeometryReader { geometry in
                    
                    //Visual Feedback
                    VStack {
                        InstrumentLocations(
                            sceneSize: CGSize(width: geometry.size.width, height: geometry.size.height),
                            sceneSkin: setInfoModel.setSettings.skins,
                            instrument0Positions: instrument0.0
//                            ,
//                            instrument1Positions: instrument1.0,
//                            instrument2Positions: instrument2.0,
//                            instrument3Positions: instrument3.0
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onTapGesture {
                            print("short")
                            presentSettingSheet = true
                        }
                        .onLongPressGesture(minimumDuration: 1) {
                            print("long")
                            presentSettingSheet = true
                        }
                        .sheet(isPresented: $presentSettingSheet) {
                            SettingsSheetView(
                                userSettings: userSettings,
                                setInfoModel: setInfoModel,
                                showingSheet: $presentSettingSheet
                            )
                            .background(Color.black.opacity(0.5))
                        }
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
                    }
                    .background(Color.black)
                    .edgesIgnoringSafeArea(.all)
                }
            }
        }
    }
}
