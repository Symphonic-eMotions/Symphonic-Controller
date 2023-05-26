//
//  PlayView.swift
//  PlayView
//
//  Created by Mihai Fratu on 29.07.2021.
//

import SwiftUI
import AudioKit

struct PlayView: View {
    
    @ObservedObject var playViewModel: PlayViewModel
    @EnvironmentObject var fileController: FileController
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    
    @State private var presentSettingSheet = false
    @State private var stopEngine: Bool = true
    
    init(
        playViewModel: PlayViewModel,
        sessionDisplay: Binding<SessionDisplay>,
        sessionDisplaySub: Binding<SessionDisplay>
    ){
        self.playViewModel = playViewModel
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
                    playViewModel: playViewModel
                )
                .padding(.trailing)
                
                //Transport buttons
                PlayerControlsView(
                    playViewModel: playViewModel
                )
                .zIndex(100)
                
                //Video preview and instrument locations
                ZStack{
                    
                    //Instruments
                    if playViewModel.playViewState.displayMode == .instruments ||
                       playViewModel.playViewState.displayMode == .both {
                        
                        if playViewModel.playViewState.buildSettings.instrumentPartEditor && !playViewModel.conductor.isConductorPlayingSubject.value {
                            
                            EditGridView(playViewModel: playViewModel)
                            
                        } else {
                            
                            PlayGridView(playViewModel: playViewModel)
                            .onTapGesture {
                                presentSettingSheet.toggle()
                            }
                            .sheet(isPresented: $presentSettingSheet) {
                                SettingsSheetView(
                                    playViewModel: playViewModel,
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
                        playViewModel: playViewModel
                    )
                    //.frame(width: 180.0, height: 120.0)
                    .aspectRatio(1.77777, contentMode: .fit)
                    .overlay(RoundedRectangle(cornerRadius: 10.0).stroke(Color.secondary))
                    .cornerRadius(10.0)
                    .opacity( playViewModel.playViewState.displayMode == .both ? 0.15 : 1.0)
                }
                //Instrument Part editor
                if playViewModel.playViewState.buildSettings.instrumentPartEditor {

                    //Editing modee visual parameter value feedback
                    PartFeedbackView(
                        playViewModel: playViewModel,
                        sessionDisplay: $sessionDisplay,
                        sessionDisplaySub: $sessionDisplaySub
                    )
                    .environmentObject(fileController)
                }
                else {
                    Spacer()
                    Text("If playlist hold level and next set")
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(.horizontal)
            .navigationBarTitleDisplayMode(.inline)
            
            if playViewModel.playViewState.buildSettings.isMasterTrack {
                
                MasterTrackView(
                    playViewModel: playViewModel,
                    masterEffect: State(initialValue: AppUtils.masterTrackStateObject(viewObject: playViewModel.playViewState.masterTrackStructure!))

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
