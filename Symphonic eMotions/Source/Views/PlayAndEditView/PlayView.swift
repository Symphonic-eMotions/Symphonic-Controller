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
    @State var showOverView: Bool = false
    
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
                    viewModelPlayerControls: PlayerControlsViewModel(
                        playerControlsViewState: PlayerControlsViewState(
                            displayMode: playViewModel.playViewState.displayMode,
                            buildSettings: playViewModel.playViewState.buildSettings
                        ),
                        conductor: playViewModel.conductor,
                        frameExtractor: playViewModel.frameExtractor,
                        leveling: playViewModel.leveling,
                        setSettings: playViewModel.setSettings,
                        hasTempo: playViewModel.playViewState.currentInstrumentsSet.hasTempo,
                        playerControlsAction: playViewModel.controlsViewAction(action:)
                    )
                )
                .zIndex(100)
                
               //Hidden sensitivity setttings
                if playViewModel.playViewState.buildSettings.isAdvanced {
                    HStack {
                        SliderView(
                            label: "Feedback",
                            value: Binding(
                                get: { playViewModel.imageDifference.feedback.value },
                                set: { playViewModel.imageDifference.feedback.send($0) }
                            ),
                            showsSeparator: false,
                            withPercentage: 0.6
                        )
                        
                        SliderView(
                            label: "Max value",
                            value:
                                Binding(
                                    get: { Float(playViewModel.imageDifference.maxValueSubject.value) },
                                    set: { playViewModel.imageDifference.maxValueSubject.send(Int($0)) }
                                ),
                            minValue: 1,
                            maxValue: 255,
                            showsSeparator: false,
                            withPercentage: 0.6
                        )
                    }
                    
                    SensitivityPlayView(
                        playViewModel: playViewModel,
                        label: "Sensitivity",
                        value: Binding(
                                get: {
                                    playViewModel.imageDifference.sensitivitySubject.value
                                },
                                set: {
                                    playViewModel.imageDifference.sensitivitySubject.send($0)
                                    playViewModel.imageDifference.sensitivityToMaxValue(sensitivity: $0)
                                    playViewModel.imageDifference.sensitivityToFeedback(sensitivity: $0)
                                }
                            ),
                        minValue: 0,
                        maxValue: 1,
                        showsSeparator: false,
                        withPercentage: 0.8
                    )
                    
                }
                
                //Video preview and instrument locations
                ZStack{
                    
                    //Instruments
                    if playViewModel.playViewState.displayMode == .instruments ||
                       playViewModel.playViewState.displayMode == .both {
                        
                        if playViewModel.playViewState.buildSettings.instrumentPartEditor && !playViewModel.conductor.isConductorPlayingSubject.value {
                            
                            EditGridView(playViewModel: playViewModel)
                            
                        } else {
                            
                            PlayGridView(playViewModel: playViewModel)
                            .onLongPressGesture {
                                self.showOverView.toggle()
                            }
                            
                            //The calibrator slider and video slider
                            if showOverView {
                                SensitivityView(
                                     playViewModel: playViewModel
                                )
                                .zIndex(50)
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
                    Text(playViewModel.setSettings.customName)
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

struct SensitivityPlayView: View {
    
    @ObservedObject var playViewModel: PlayViewModel
    
    var label: LocalizedStringKey
    @Binding var value: Float
    var minValue: Float = 0
    var maxValue: Float = 1
    var showsSeparator: Bool
    var withPercentage: CGFloat = 0.7
    
    init(
        playViewModel: PlayViewModel,
        label: LocalizedStringKey,
        value: Binding<Float>,
        minValue: Float = 0,
        maxValue: Float = 1,
        showsSeparator: Bool = true,
        withPercentage: CGFloat = 0.7
    ) {
        self.playViewModel = playViewModel
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
                    //Write to session file (Sensitivity Slider)
                    Slider(value: $value, in: minValue...maxValue, onEditingChanged: { changed in
                        //Only on end of slide change
                        if !changed {
                            
                            print("Sensitivity changed and stored to: \(value)")
                            
                            AppUtils.createSessionFile(
                                sensitivity: value,
                                setURL: playViewModel.setSettings.setURL
                            )
                        }
                    })
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
