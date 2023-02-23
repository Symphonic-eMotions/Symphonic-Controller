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
    
    @Binding var mainViewUpdate: BuildSettings.ActiveView
    
    init(
        playViewModel: PlayViewModel,
        mainViewUpdate: Binding<BuildSettings.ActiveView>){
        self.playViewModel = playViewModel
        self._mainViewUpdate = mainViewUpdate
    }
    
    var body: some View {
        
        ZStack{
            
            //Vetical stack to hold levels, transport, settings, video / instrument feedback and instrument part feedback
            VStack {
                
                #if targetEnvironment(macCatalyst)
                Rectangle().frame(height: 25).foregroundColor(Color.clear)
                #endif
                
                LevelView(
                    playViewModel: playViewModel
                )
                .padding(.trailing)
                
                //Level editor
                if playViewModel.playViewState.buildSettings.instrumentPartEditor {
                    
                    let trackLevels: [Int] = playViewModel.setSettings.getTrackLevels(
                        trackId: playViewModel.partFeedback.currentTrackID.value
                    )
                    
                    EditLevelView(
                        playViewModel: playViewModel,
                        currentTrackLevels: TrackLevelsModel(trackLevels: trackLevels)
                    )
                    .padding(.trailing)
                }
                
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
                    ),
                    mainViewUpdate: $mainViewUpdate
                )
                
               //Hidden sensitivity setttings
                if playViewModel.playViewState.buildSettings.isAdvanced {
                    HStack {
                        SliderView(
                            label: "Feedback",
                            value: Binding(
                                get: { playViewModel.imageDifference.feedback.value },
                                set: { playViewModel.imageDifference.feedback.send($0) }
                            ),
                            showsSeparator: false
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
                            showsSeparator: false
                        )
                        
                        EMButton(action: {
                            if playViewModel.conductor.isConductorPlayingSubject.value {
                                playViewModel.conductor.togglePlayEngineAndTracks(
                                    currentSetLevel: 0, setSettings: self.playViewModel.setSettings
                                )
                            }
                            else{
                                self.mainViewUpdate = .calibration
                            }
                        }, color: .accentColor, isSolid: false, maxWidth: 50) {
                            Label("", systemImage: "hand.wave")
                                .blur(radius: 1)
                        }
                    }
                }
                
                //Video preview and instrument locations
                ZStack{
                    
                    //Instruments
                    if playViewModel.playViewState.displayMode == .instruments
                        || playViewModel.playViewState.displayMode == .both {
                        
                        if playViewModel.playViewState.buildSettings.instrumentPartEditor
                            && !playViewModel.conductor.isConductorPlayingSubject.value {
                            
                            EditGridView(playViewModel: playViewModel)
                            
                        } else {
                            
                            PlayGridView(playViewModel: playViewModel)
                        }
                    }
                    else{
                        DontPlayGridView()
                    }
                    
                    //Video
                    VideoPreviewViewRepresetable(
                        playViewModel: playViewModel
                    )
    //                .frame(width: 180.0, height: 120.0)
                    .aspectRatio(1.77777, contentMode: .fit)
                    .overlay(RoundedRectangle(cornerRadius: 10.0).stroke(Color.secondary))
                    .cornerRadius(10.0)
                    .opacity( playViewModel.playViewState.displayMode == .both ? 0.15 : 1.0)
                }
                
                if playViewModel.playViewState.buildSettings.instrumentPartEditor {

                    //Editing modee visual parameter value feedback
                    PartFeedbackView(
                        playViewModel: playViewModel
                    ).environmentObject(fileController)
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


/*
struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView(viewModel: PlayViewModel(appState: AppState()))
    }
}
 */

struct SliderView: View {
    
    var label: LocalizedStringKey
    @Binding var value: Float
    
    var minValue: Float = 0
    var maxValue: Float = 1
    var showsSeparator: Bool
    
    init(label: String, value: Binding<Float>, minValue: Float = 0, maxValue: Float = 1, showsSeparator: Bool = true) {
        self.init(label: LocalizedStringKey(label), value: value, minValue: minValue, maxValue: maxValue, showsSeparator: showsSeparator)
    }
    
    init(label: LocalizedStringKey, value: Binding<Float>, minValue: Float = 0, maxValue: Float = 1, showsSeparator: Bool = true) {
        self.label = label
        _value = value
        self.maxValue = minValue
        self.maxValue = maxValue
        self.showsSeparator = showsSeparator
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
                        .frame(width: geometry.size.width * 0.7)
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
