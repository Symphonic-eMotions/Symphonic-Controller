//
//  LevelOSCView.swift
//  LevelOSCView
//
//  Created by Frans-Jan on 14-10-2024.
//

import SwiftUI
import AudioKit

struct LevelOSCView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    @ObservedObject var setInfoModel: SetInfoModel
    @EnvironmentObject var fileController: FileController
    @Binding public var sessionDisplay: SessionDisplay
    @State private var presentSettingSheet = false
    @State private var showMasterTrack: Bool = false
    
    init(
        setInfoModel: SetInfoModel,
        sessionDisplay: Binding<SessionDisplay>
    ){
        self.setInfoModel = setInfoModel
        self._sessionDisplay = sessionDisplay
    }
    
    var body: some View {
        
        //ZStack for masterFX
        ZStack{
            
            //Vetical stack to hold levels, transport, settings,
            //video/instrument feedback and instrument part feedback
            VStack {
                
                //Video preview and instrument locations
                GeometryReader { geometry in
                    VStack{
                        Spacer()
                        HStack {
                            Spacer()
                            ZStack{
                                
//                                if !setInfoModel.userSettings.isSetPlaying {
//                                    CalibrationView(
//                                        geometry: geometry,
//                                        userSettings: setInfoModel.userSettings,
//                                        setInfoModel: setInfoModel
//                                    )
//                                    .zIndex(210)
//                                }
                                
                                //Editor
                                if userSettings.showPartEditor  {
                                    EditGridView(setInfoModel: setInfoModel)
                                }
                                
                                //Video
                                VideoPreviewViewRepresentable(
                                    setInfoModel: setInfoModel
                                )
                                //.frame(width: 180.0, height: 120.0)
                                .aspectRatio(1.77777, contentMode: .fit)
                                .overlay(RoundedRectangle(cornerRadius: 10.0).stroke(Color.secondary))
                                .cornerRadius(10.0)
                                .opacity( 0.75)
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    .sheet(isPresented: $presentSettingSheet) {
                        SettingsSheetView(
                            userSettings: userSettings,
                            setInfoModel: setInfoModel,
                            showingSheet: $presentSettingSheet
                        )
                    }
                }
                .zIndex(110)
            }
            .padding(.horizontal)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showMasterTrack) {
                MasterTrackView(
                    setInfoModel: setInfoModel,
                    masterEffect: State(
                        initialValue: MasterTrackEffectsHelper.masterTrackStateObject(
                            viewObject: setInfoModel.setInfoState.masterTrackStructure!
                        )
                    ),
                    showMasterTrack: $showMasterTrack
                )
            }
        }
    }
}
