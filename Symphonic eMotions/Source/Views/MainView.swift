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
                sessionDisplay: $sessionDisplay
            )
            .onAppear{
                viewModel.conductor.playEngineAndTracks(
                    setSettings: viewModel.mainState.setSettings,
                    level: 0
                )
                viewModel.conductor.trackMuteAndClipStatusPerLevelControl(
                    level: 0,
                    setSettings: viewModel.mainState.setSettings
                )
            }
            .padding(.top, 20)
        }
        
        //SwiftUI Interface with Part editor
        else if sessionDisplay == .swiftUI || sessionDisplay == .setInfo  || sessionDisplay == .home {
            
            NavigationView {
                
                SideBarFolderView(
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
                    .onAppear{
                        viewModel.leveling.pauseLevel = false
                        viewModel.conductor.trackMuteAndClipStatusPerLevelControl(
                            level: 0,
                            setSettings: viewModel.mainState.setSettings
                        )
                        viewModel.conductor.playEngineAndTracks(
                            setSettings: viewModel.mainState.setSettings,
                            level: 0
                        )
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
                
                SideBarFolderView(
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
