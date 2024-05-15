//
//  PlayView.swift
//  PlayView
//
//  Created by Mihai Fratu on 29.07.2021.
//

import SwiftUI
import AudioKit

struct PlayView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    @ObservedObject var setInfoModel: SetInfoModel
    @EnvironmentObject var fileController: FileController
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    @StateObject private var columnOpacityController: ColumnOpacityController
    @StateObject private var cellOpacityController: CellOpacityController
    @StateObject private var gridModel: GridModel
    @State private var presentSettingSheet = false
    @State private var showMasterTrack: Bool = false
    @Binding public var showLevelPlayerFullScreen: Bool
    
    init(
        setInfoModel: SetInfoModel,
        sessionDisplay: Binding<SessionDisplay>,
        sessionDisplaySub: Binding<SessionDisplay>,
        showLevelPlayerFullScreen: Binding<Bool>
    ){
        self.setInfoModel = setInfoModel
        self._columnOpacityController = StateObject(wrappedValue: ColumnOpacityController(count:(setInfoModel.setInfoState.currentInstrumentsSet.columns))
        )
        self._cellOpacityController = StateObject(wrappedValue: CellOpacityController(count:(setInfoModel.setInfoState.currentInstrumentsSet.rows * setInfoModel.setInfoState.currentInstrumentsSet.columns))
        )
        self._gridModel = StateObject(wrappedValue:
            GridModel(
                levelCount: setInfoModel.setSettings.levels.count,
                levelSubject: setInfoModel.leveling.currentSetLevelSubject,
                gridRows: setInfoModel.setInfoState.currentInstrumentsSet.rows,
                gridColumns: setInfoModel.setInfoState.currentInstrumentsSet.columns
            )
        )
        self._sessionDisplay = sessionDisplay
        self._sessionDisplaySub = sessionDisplaySub
        self._showLevelPlayerFullScreen = showLevelPlayerFullScreen
    }
    
    var body: some View {
        
        //ZStack for masterFX
        ZStack{
            
            //Vetical stack to hold levels, transport, settings,
            //video/instrument feedback and instrument part feedback
            VStack {
                
                #if targetEnvironment(macCatalyst)
                Rectangle().frame(height: 25).foregroundColor(Color.clear)
                #endif
                
                if !showLevelPlayerFullScreen {
                    LevelView(
                        setInfoModel: setInfoModel
                    )
                    //Transport buttons
                    PlayerControlsView(
                        setInfoModel: setInfoModel,
                        sessionDisplaySub: $sessionDisplaySub,
                        showMasterTrack: $showMasterTrack
                    )
                    .zIndex(100)
                }
                //Video preview and instrument locations
                GeometryReader { geometry in
                    VStack{
                        Spacer()
                        HStack {
                            Spacer()
                            ZStack{
                                
                                //Editor
                                if userSettings.showPartEditor  {
                                    EditGridView(setInfoModel: setInfoModel)
                                }
                                //PlayView
                                else {
                                    
                                    if !setInfoModel.userSettings.isSetPlaying {
                                        StartView(
                                            setInfoModel: setInfoModel,
                                            sessionDisplaySub: $sessionDisplaySub,
                                            geometry: geometry
                                        )
                                        .zIndex(210)
                                    }
                                    
                                    if setInfoModel.setSettings.userViews.contains(.playView) {
                                        if [.instruments,.both].contains(setInfoModel.setInfoState.displayMode) {
                                            PlayGridView(setInfoModel: setInfoModel)
                                            .onTapGesture {
                                                presentSettingSheet.toggle()
                                            }
                                        } else {
                                            DontPlayGridView()
                                        }
                                    }
                                    
                                    //LevelPlayer
                                    else if setInfoModel.setSettings.userViews.contains(.levelPlayer){
                                        LevelPlayer(
                                            setInfoModel: setInfoModel,
                                            columnOpacityController: columnOpacityController,
                                            cellOpacityController: cellOpacityController,
                                            gridModel: gridModel,
                                            showLevelPlayerFullScreen: $showLevelPlayerFullScreen,
                                            geometry: geometry
                                        )
                                        .zIndex(showLevelPlayerFullScreen ? 200 : 0)
                                        .frame(width: geometry.size.width, height: geometry.size.height)
                                        .onTapGesture {
                                            presentSettingSheet.toggle()
                                        }
                                    }
                                }
                                
                                //Video
                                VideoPreviewViewRepresetable(
                                    setInfoModel: setInfoModel
                                )
                                //.frame(width: 180.0, height: 120.0)
                                .aspectRatio(1.77777, contentMode: .fit)
                                .overlay(RoundedRectangle(cornerRadius: 10.0).stroke(Color.secondary))
                                .cornerRadius(10.0)
                                .opacity( setInfoModel.setInfoState.displayMode == .both ? 0.15 : 1.0)
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    .sheet(isPresented: $presentSettingSheet) {
                        SettingsSheetView(
                            userSettings: userSettings,
                            setInfoModel: setInfoModel,
                            sessionDisplaySub: $sessionDisplaySub,
                            showingSheet: $presentSettingSheet
                        )
                    }
                }
                .zIndex(110)
                
                if userSettings.showPartEditor {

                    //Editor below grid editor
                    PartFeedbackView(
                        setInfoModel: setInfoModel,
                        sessionDisplay: $sessionDisplay,
                        sessionDisplaySub: $sessionDisplaySub
                    )
                    .environmentObject(fileController)
                }
                Spacer()
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

struct SliderView: View {
    
    var label: LocalizedStringKey
    @Binding var value: Float
    var minValue: Float = 0
    var maxValue: Float = 1
    var showsSeparator: Bool
    var withPercentage: CGFloat = 0.7
    
    init(
        label: LocalizedStringKey,
        value: Binding<Float>,
        minValue: Float = 0,
        maxValue: Float = 1,
        showsSeparator: Bool = true,
        withPercentage: CGFloat = 0.7
    ) {
        self.label = label
        _value = value
        self.maxValue = minValue
        self.maxValue = maxValue
        self.showsSeparator = showsSeparator
        self.withPercentage = withPercentage
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(label)
                            .font(.headline)
                        Text("\(value)")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                    Spacer()
                    
                    Slider(value: $value, in: minValue...maxValue)
                        .foregroundColor(.accentColor)
                        .frame(width: geometry.size.width * withPercentage)
                
                }
                .padding(.horizontal)
                
                if showsSeparator {
                    Rectangle()
                        .fill(Color.secondary)
                        .frame(height: 1.0)
                }
            }
        }
        .frame(height: 50.0)
    }
}
