//
//  MainView.swift
//  MainView
//
//  Created by Mihai Fratu on 29.07.2021.
//

import UIKit
import SwiftUI

struct MainView: View {
    
    @ObservedObject var viewModel: MainViewModel
    //Highest lvel View control
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    
    //This needs to be replaced with sessionDisplay
    @State private var mainViewUpdate: BuildSettings.ActiveView
    //Set info page vars from navigation
    @State var setInfoLocalState = SetInfoLocalState()
    //Keep track of local saved SeM setting files
    @StateObject var fileController = FileController()
    @State var userPresets: [URL] = []
    @State var templatePresets: [URL] = []
    
    //Keep track of View switches from lower Views
    @State private var autoNavigation: SessionDisplay
    
    
    init(
        viewModel: MainViewModel,
        sessionDisplay: Binding<SessionDisplay>,
        sessionDisplaySub: Binding<SessionDisplay>,
        mainViewUpdate: BuildSettings.ActiveView
    ) {
        
        self.viewModel = viewModel
        self._sessionDisplay = sessionDisplay
        self._sessionDisplaySub = sessionDisplaySub
        self.mainViewUpdate = mainViewUpdate
        
        self.autoNavigation = .none
        
        //Create Playlists if needed
        AppUtils.createPlayListFolders()
    }
    
    var body: some View {
        
        //Object for Master track effect editor
        //Does this also need to go to the MainViewModel?
        let masterTrackSetting = AppUtils.masterTrackViewObject(
            instrumentSet: viewModel.mainState.currentInstrumentsSet,
            setSettings:  viewModel.mainState.setSettings
        )
        
        //SpriteKit (2D Game) interface
        if sessionDisplay == .spriteKit {
            SpriteKitView(
                playViewModel: PlayViewModel(
                    playViewState: PlayViewState(
                        currentInstrumentsSet: viewModel.mainState.currentInstrumentsSet,
                        buildSettings: viewModel.mainState.buildSettings
                    ),
                    conductor: viewModel.conductor,
                    imageDifference: $viewModel.mainState.imageDifference,
                    leveling: viewModel.leveling,
                    
                    setSettings: $viewModel.mainState.setSettings,
                    
                    //Part feedback is part of editor
                    partFeedback: viewModel.partFeedback,
                    partFeedbackState: PartFeedbackState(),
                    
                    //Feedback objects are for custom controllable UI objects
                    feedbackObjectsSate: FeedbackObjectsState()
                ),
                mainViewModel: viewModel,
                sessionDisplay: $sessionDisplay,
                sessionDisplaySub: $sessionDisplaySub
            )
            .onAppear{
                viewModel.conductor.playEngineAndTracks(
                    setSettings: viewModel.mainState.setSettings,
                    level: 0
                )
                viewModel.conductor.levelController(
                    level: 0,
                    setSettings: viewModel.mainState.setSettings
                )
            }
            .padding(.top, 20)
        }
        
        if sessionDisplay == .countDown {
            
            CountDown(
                setInfoModel: SetInfoModel(
                    setInfoLocalState: $setInfoLocalState,
                    setSettings: $viewModel.mainState.setSettings,
                    setInfoState: SetInfoState(
                        currentInstrumentsSet: viewModel.mainState.currentInstrumentsSet
                    ),
                    currentInstrumentsSetIsChanged: { instrumentsSet in
                        viewModel.currentModelInstrumentsSetChanged(
                            instrumentsSet: instrumentsSet,
                            sessionSettings: viewModel.mainState.sessionSettings
                        )
                    },
                    conductor: viewModel.conductor
                ),
                sessionDisplay: $sessionDisplay,
                sessionDisplaySub: $sessionDisplaySub
            )
            .environmentObject(fileController)
        }
        
        //SwiftUI Interface with Part editor
        else if sessionDisplay == .swiftUI || sessionDisplay == .setInfo  || sessionDisplay == .home {
            
            NavigationView {
                
                SideBarView(
                    setInfoModel: SetInfoModel(
                        setInfoLocalState: $setInfoLocalState,
                        setSettings: $viewModel.mainState.setSettings,
                        setInfoState: SetInfoState(
                            currentInstrumentsSet: viewModel.mainState.currentInstrumentsSet
                        ),
                        currentInstrumentsSetIsChanged: { instrumentsSet in
                            viewModel.currentModelInstrumentsSetChanged(
                                instrumentsSet: instrumentsSet,
                                sessionSettings: viewModel.mainState.sessionSettings
                            )
                        },
                        conductor: viewModel.conductor
                    ),
                    sessionDisplay: $sessionDisplay,
                    sessionDisplaySub: $sessionDisplaySub,
                    setInfoLocalState: $setInfoLocalState
                )
                .environmentObject(fileController)
                
                //SeM Pro interface with interaction editor
                if sessionDisplay == .swiftUI {
                    
                    ZStack{
                        
                        PlayView(
                            playViewModel: PlayViewModel(
                                playViewState: PlayViewState(
                                    currentInstrumentsSet: viewModel.mainState.currentInstrumentsSet,
                                    buildSettings: viewModel.mainState.buildSettings,
                                    masterTrackStructure: masterTrackSetting
                                ),
                                conductor: viewModel.conductor,
                                imageDifference: $viewModel.mainState.imageDifference,
                                leveling: viewModel.leveling,
                                setSettings: $viewModel.mainState.setSettings,
                                partFeedback: viewModel.partFeedback,
                                partFeedbackState: PartFeedbackState(),
                                feedbackObjectsSate: FeedbackObjectsState()
                            ),
                            mainViewUpdate: $mainViewUpdate,
                            sessionDisplay: $sessionDisplay,
                            sessionDisplaySub: $sessionDisplaySub
                        )
                        .environmentObject(fileController)
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                        .edgesIgnoringSafeArea([.top, .trailing])
                        //It's not called PlayView for nothing
                        .onAppear{
                            //Start leveling over
                            viewModel.leveling.pauseLevel = false
                            viewModel.conductor.levelController(
                                level: 0,
                                setSettings: viewModel.mainState.setSettings
                            )
                            //Start sequencer
                            viewModel.conductor.playEngineAndTracks(
                                setSettings: viewModel.mainState.setSettings,
                                level: 0
                            )
                        }
                        //If levels are completed go to count down view
                        .onReceive(viewModel.leveling.currentSetLevelSubject){ currentSetLevel in
                            if viewModel.mainState.setSettings.currentPlaylist != .none {
                                if currentSetLevel >= Double(viewModel.mainState.setSettings.levels.count) {
                                    self.sessionDisplay = .countDown
                                }
                            }
                        }
                    }
                }
                
                //Selected set info View
                else if sessionDisplay == .setInfo || sessionDisplay == .home {
                    
                    SetInfo(
                        setInfoModel: SetInfoModel(
                            setInfoLocalState: $setInfoLocalState,
                            setSettings: $viewModel.mainState.setSettings,
                            setInfoState: SetInfoState(
                                //                                setCollections: viewModel.mainState.setCollection,
                                currentInstrumentsSet: viewModel.mainState.currentInstrumentsSet
                            ),
                            currentInstrumentsSetIsChanged: { instrumentsSet in
                                viewModel.currentModelInstrumentsSetChanged(
                                    instrumentsSet: instrumentsSet,
                                    sessionSettings: viewModel.mainState.sessionSettings
                                )
                            },
                            conductor: viewModel.conductor
                        ),
                        sessionDisplay: $sessionDisplay,
                        sessionDisplaySub: $sessionDisplaySub,
                        userPresets: $userPresets
                    )
                    .environmentObject(fileController)
                }
            }
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
        }
        
        //Playlists!
        else if sessionDisplay == .playlists {
            
            NavigationView {
                
                SideBarView(
                    setInfoModel: SetInfoModel(
                        setInfoLocalState: $setInfoLocalState,
                        setSettings: $viewModel.mainState.setSettings,
                        setInfoState: SetInfoState(
                            currentInstrumentsSet: viewModel.mainState.currentInstrumentsSet
                        ),
                        currentInstrumentsSetIsChanged: { instrumentsSet in
                            viewModel.currentModelInstrumentsSetChanged(
                                instrumentsSet: instrumentsSet,
                                sessionSettings: viewModel.mainState.sessionSettings
                            )
                        },
                        conductor: viewModel.conductor
                    ),
                    sessionDisplay: $sessionDisplay,
                    sessionDisplaySub: $sessionDisplaySub,
                    setInfoLocalState: $setInfoLocalState
                )
                .environmentObject(fileController)
                
                PlayListsView(
                    setInfoModel: SetInfoModel(
                        setInfoLocalState: $setInfoLocalState,
                        setSettings: $viewModel.mainState.setSettings,
                        setInfoState: SetInfoState(
                            currentInstrumentsSet: viewModel.mainState.currentInstrumentsSet
                        ),
                        currentInstrumentsSetIsChanged: { instrumentsSet in
                            viewModel.currentModelInstrumentsSetChanged(
                                instrumentsSet: instrumentsSet,
                                sessionSettings: viewModel.mainState.sessionSettings
                            )
                        },
                        conductor: viewModel.conductor
                    ),
                    sessionDisplay: $sessionDisplay,
                    sessionDisplaySub: $sessionDisplaySub
                )
                .environmentObject(fileController)
            }
        }
        
        else if sessionDisplay == .muur {
            
            if viewModel.mainState.buildSettings.activeView == .homeView {
                FullView(
                    playViewModel: PlayViewModel(
                        playViewState: PlayViewState(
                            currentInstrumentsSet: viewModel.mainState.currentInstrumentsSet,
                            buildSettings: viewModel.mainState.buildSettings
                        ),
                        conductor: viewModel.conductor,
                        imageDifference: $viewModel.mainState.imageDifference,
                        leveling: viewModel.leveling,
                        setSettings: $viewModel.mainState.setSettings,
                        //Part feedback is part of editor
                        partFeedback: viewModel.partFeedback,
                        partFeedbackState: PartFeedbackState(),
                        
                        //Feedback objects are for custom controllable UI objects
                        feedbackObjectsSate: FeedbackObjectsState()
                    ),
                    fullViewModel: FullViewModel(
                        state: FullViewState(
                            currentInstrumentSet: viewModel.mainState.currentInstrumentsSet,
                            buildSettings: viewModel.mainState.buildSettings
                        ),
                        currentInstrumentSetIsChanged: { instrumentsSet in
                            viewModel.currentModelInstrumentsSetChanged(
                                instrumentsSet: instrumentsSet,
                                sessionSettings: viewModel.mainState.sessionSettings
                            )
                        },
                        conductor: viewModel.conductor
                    )
                )
            }
            
            else if viewModel.mainState.buildSettings.activeView == .playView {
                
                FullPlayView(
                    playViewModel: PlayViewModel(
                        playViewState: PlayViewState(
                            currentInstrumentsSet: viewModel.mainState.currentInstrumentsSet,
                            buildSettings: viewModel.mainState.buildSettings
                        ),
                        conductor: viewModel.conductor,
                        imageDifference: $viewModel.mainState.imageDifference,
                        leveling: viewModel.leveling,
                        
                        setSettings: $viewModel.mainState.setSettings,
                        
                        //Part feedback is part of editor
                        partFeedback: viewModel.partFeedback,
                        partFeedbackState: PartFeedbackState(),
                        
                        //Feedback objects are for custom controllable UI objects
                        feedbackObjectsSate: FeedbackObjectsState()
                    ),
                    mainViewModel: viewModel
                )
                .navigationBarTitle("")
                .navigationBarHidden(false)
                .edgesIgnoringSafeArea([.top, .trailing])
                .onAppear{
                    viewModel.conductor.playEngineAndTracks(
                        setSettings: viewModel.mainState.setSettings,
                        level: 0
                    )
                }
            }
        }
    }
}
