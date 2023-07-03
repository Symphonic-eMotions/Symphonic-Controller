//
//  PlayView.swift
//  PlayView
//
//  Created by Mihai Fratu on 29.07.2021.
//

import SwiftUI
import AudioKit

struct PlayView: View {
    
    //To shut down the conductor if going inactive
//    @Environment(\.scenePhase) private var scenePhase
    
    @ObservedObject var setInfoModel: SetInfoModel
    @EnvironmentObject var fileController: FileController
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    
    @State private var presentSettingSheet = false
    @State private var stopEngine: Bool = true
    
    init(
        setInfoModel: SetInfoModel,
        sessionDisplay: Binding<SessionDisplay>,
        sessionDisplaySub: Binding<SessionDisplay>
    ){
        self.setInfoModel = setInfoModel
        self._sessionDisplay = sessionDisplay
        self._sessionDisplaySub = sessionDisplaySub
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
                
                LevelView(
                    setInfoModel: setInfoModel
                )
                
                //Transport buttons
                PlayerControlsView(
                    setInfoModel: setInfoModel
                )
                .zIndex(100)
                
                //Video preview and instrument locations
                ZStack{
                    
                    //Instruments
                    if setInfoModel.setInfoState.displayMode == .instruments ||
                        setInfoModel.setInfoState.displayMode == .both {
                        
                        if setInfoModel.setInfoState.buildSettings.instrumentPartEditor && !setInfoModel.conductor.isConductorPlayingSubject.value {
                            
                            EditGridView(setInfoModel: setInfoModel)
                            
                        } else {
                            
                            PlayGridView(setInfoModel: setInfoModel)
                            .onTapGesture {
                                presentSettingSheet.toggle()
                            }
                            .sheet(isPresented: $presentSettingSheet) {
                                SettingsSheetView(
                                    setInfoModel: setInfoModel,
                                    showingSheet: $presentSettingSheet,
                                    stopEngine: $stopEngine
                                )
                            }
                        }
                    }
                    else{
                        DontPlayGridView()
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
                //Instrument Part editor
                if setInfoModel.setInfoState.buildSettings.instrumentPartEditor {

                    //Editing modee visual parameter value feedback
                    PartFeedbackView(
                        setInfoModel: setInfoModel,
                        sessionDisplay: $sessionDisplay,
                        sessionDisplaySub: $sessionDisplaySub
                    )
                    .environmentObject(fileController)
                }
                else {
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
                        }, color: .accentColor, isSolid: false) {
                            Text(NSLocalizedString("Finish", comment: ""))
                        }
                        
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            .navigationBarTitleDisplayMode(.inline)
            
            if setInfoModel.setInfoState.buildSettings.isMasterTrack {
                
                MasterTrackView(
                    setInfoModel: setInfoModel,
                    masterEffect: State(initialValue: AppUtils.masterTrackStateObject(viewObject: setInfoModel.setInfoState.masterTrackStructure!))
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
