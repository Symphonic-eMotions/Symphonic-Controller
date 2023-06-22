//
//  MainView.swift
//  MainView
//
//  Created by Mihai Fratu on 29.07.2021.
//

import UIKit
import SwiftUI
import AVFoundation

struct MainView: View {
        
    @ObservedObject var viewModel: MainViewModel
    //Highest lvel View control
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    
    //Set info page vars from navigation
    @State var setInfoLocalState = SetInfoLocalState()
    //Keep track of local saved SeM setting files
    @StateObject var fileController = FileController()
    @State var userPresets: [URL] = []
    @State var templatePresets: [URL] = []
    
    
    init(
        viewModel: MainViewModel,
        sessionDisplay: Binding<SessionDisplay>,
        sessionDisplaySub: Binding<SessionDisplay>
    ) {
        
        self.viewModel = viewModel
        self._sessionDisplay = sessionDisplay
        self._sessionDisplaySub = sessionDisplaySub
        
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
                    partFeedback: viewModel.partFeedback,
                    partFeedbackState: PartFeedbackState()
                ),
                mainViewModel: viewModel,
                sessionDisplay: $sessionDisplay,
                sessionDisplaySub: $sessionDisplaySub
            )
//            .onAppear(perform: checkCameraAuthorization)
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
                            instrumentsSet: instrumentsSet
                        )
                    },
                    conductor: viewModel.conductor
                ),
                sessionDisplay: $sessionDisplay,
                sessionDisplaySub: $sessionDisplaySub
            )
            .environmentObject(fileController)
        }
        
        if sessionDisplay == .home {
            
            Introduction(
                setInfoModel: SetInfoModel(
                    setInfoLocalState: $setInfoLocalState,
                    setSettings: $viewModel.mainState.setSettings,
                    setInfoState: SetInfoState(
                        currentInstrumentsSet: viewModel.mainState.currentInstrumentsSet
                    ),
                    currentInstrumentsSetIsChanged: { instrumentsSet in
                        viewModel.currentModelInstrumentsSetChanged(
                            instrumentsSet: instrumentsSet
                        )
                    },
                    conductor: viewModel.conductor
                ),
                sessionDisplay: $sessionDisplay,
                sessionDisplaySub: $sessionDisplaySub
            )
        }
        //SwiftUI Interface with Part editor
        else if [.swiftUI,.setInfo,.pro,.demo,.creator].contains(sessionDisplay) {
            
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
                                instrumentsSet: instrumentsSet
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
                                partFeedbackState: PartFeedbackState()
                            ),
                            sessionDisplay: $sessionDisplay,
                            sessionDisplaySub: $sessionDisplaySub
                        )
                        .environmentObject(fileController)
                        .navigationBarHidden(false)
                        //It's not called PlayView for nothing
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
                
                else if sessionDisplay == .demo {
                    DemoView(
                        setInfoModel: SetInfoModel(
                            setInfoLocalState: $setInfoLocalState,
                            setSettings: $viewModel.mainState.setSettings,
                            setInfoState: SetInfoState(
                                currentInstrumentsSet: viewModel.mainState.currentInstrumentsSet
                            ),
                            currentInstrumentsSetIsChanged: { instrumentsSet in
                                viewModel.currentModelInstrumentsSetChanged(
                                    instrumentsSet: instrumentsSet
                                )
                            },
                            conductor: viewModel.conductor
                        ),
                        sessionDisplay: $sessionDisplay,
                        sessionDisplaySub: $sessionDisplaySub
                    )
                    .environmentObject(fileController)
                }
                
                //Selected set info View
                else if [.setInfo,.pro,.creator].contains(sessionDisplay) {
                    
                    SetInfo(
                        setInfoModel: SetInfoModel(
                            setInfoLocalState: $setInfoLocalState,
                            setSettings: $viewModel.mainState.setSettings,
                            setInfoState: SetInfoState(
                                currentInstrumentsSet: viewModel.mainState.currentInstrumentsSet
                            ),
                            currentInstrumentsSetIsChanged: { instrumentsSet in
                                viewModel.currentModelInstrumentsSetChanged(
                                    instrumentsSet: instrumentsSet
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
                                instrumentsSet: instrumentsSet
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
                                instrumentsSet: instrumentsSet
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
        
        ChangeView()
        
    }
}

