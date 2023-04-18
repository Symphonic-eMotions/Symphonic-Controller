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
    @State var setInfoLocalState = SetInfoLocalState(sessioDisplay: .swiftUI)
    //Keep track of local saved SeM setting files
    @StateObject var fileController = FileController()
    @State var urls: [URL] = []
    
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
            
        //What Skin is selected by default
        //TODO: This doesn't get updated with set change.
//        if viewModel.mainState.setSettings.skins.name != "default"{
//            setInfoLocalState = SetInfoLocalState(sessioDisplay: SessionDisplay.spriteKit
//            )
//        }
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
//          SpriteKitZonesView(
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
                viewModel.conductor.playEngineAndTracks(setSetting: viewModel.mainState.setSettings)
                viewModel.conductor.trackMuteAndClipStatusPerLevelControl(
                    level: 0,
                    setSettings: viewModel.mainState.setSettings,
                    from: "spriteKitOnAppear"
                )
            }
            .padding(.top, 20)
        }
        
        //SwiftUI Interface with Part editor
        else if sessionDisplay == .swiftUI || sessionDisplay == .setInfo  || sessionDisplay == .home {
            
            NavigationView {
                SidebarView(
                    viewModel: viewModel,
                    sidebarViewModel: SidebarViewModel(
                        state: SidebarViewState(
                            currentInstrumentsSetName: viewModel.mainState.currentInstrumentsSet.name,
                            currentInstrumentSet: viewModel.mainState.currentInstrumentsSet,
                            buildSettings: viewModel.mainState.buildSettings
                        ),
                        currentInstrumentsSetIsChanged: { instrumentsSet in
                            viewModel.currentModelInstrumentsSetChanged(
                                instrumentsSet: instrumentsSet,
                                sessionSettings: viewModel.mainState.sessionSettings
                            )
                        }
                    ),
                    sessionDisplay: $sessionDisplay,
                    sessionDisplaySub: $sessionDisplaySub,
                    setInfoLocalState: $setInfoLocalState
                )
                
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
                        mainViewUpdate: $mainViewUpdate
                    )
                    .environmentObject(fileController)
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
                    .edgesIgnoringSafeArea([.top, .trailing])
                    .onAppear{
                        viewModel.leveling.pauseLevel = false
                        viewModel.conductor.trackMuteAndClipStatusPerLevelControl(
                            level: 0,
                            setSettings: viewModel.mainState.setSettings,
                            from: "playViewOnAppear"
                        )
                        viewModel.conductor.playEngineAndTracks(setSetting: viewModel.mainState.setSettings)
                    }
                }
                
                //Selected set info View
                else if sessionDisplay == .setInfo || sessionDisplay == .home {
                    
                    SetInfo(
                        setInfoModel: SetInfoModel(
                            setInfoLocalState: $setInfoLocalState,
                            setSettings: $viewModel.mainState.setSettings,
                            setInfoState: SetInfoState(
                                setCollections: viewModel.mainState.setCollection,
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
                        urls: $urls
                    )
                    .environmentObject(fileController)
                }
            }
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
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
                    viewModel.conductor.playEngineAndTracks(setSetting: viewModel.mainState.setSettings)
                }
            }
        }
    }
}
