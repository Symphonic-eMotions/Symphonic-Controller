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
    
    @State private var mainViewUpdate: BuildSettings.ActiveView
    
    //Keep track of local saved setting files
    @StateObject var fileController = FileController()
    
    //HomeKit connection for external lamp control
    @StateObject private var homeKitStore: HomeKitManager = .init()
    
    init(viewModel: MainViewModel, mainViewUpdate: BuildSettings.ActiveView) {
        
        self.viewModel = viewModel
        self.mainViewUpdate = mainViewUpdate
    }
    
    var body: some View {
        
        //Object for Master track effect editor
        //Does this also need to go to the MainViewModel?
        let masterTrackSetting = AppUtils.masterTrackViewObject(
            instrumentSet: viewModel.mainState.currentInstrumentsSet,
            setSettings:  viewModel.mainState.setSettings
        )
        
        //
        
        //Main view selector (skin)
        if viewModel.mainState.sessionSettings.activeSkin.name != .swiftUI &&
            viewModel.mainState.buildSettings.activeView == .playView {
            
            SpriteKitView(
//            SpriteKitZonesView(
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
                    feedbackObjects: viewModel.feedbackObjects,
                    feedbackObjectsSate: FeedbackObjectsState()
                ),
                mainViewModel: viewModel
            )
            .onAppear{
                viewModel.conductor.playEngineAndTracks()
                viewModel.conductor.trackMuteAndClipStatusPerLevel(
                    level: 0,
                    setSettings: viewModel.mainState.setSettings,
                    from: "spriteKitOnAppear"
                )
            }
        }
        
        else if viewModel.mainState.buildSettings.mainSettings == .zorg {
            
            if self.mainViewUpdate == .calibration {
                
                CalibrationView(
                    calibrationModel: CalibrationModel(
                        conductor: viewModel.conductor,
                        calibrationState: CalibrationState(
                            buildSettings: viewModel.mainState.buildSettings,
                            sessionSettings: viewModel.mainState.sessionSettings
                        ),
                        imageDifference: $viewModel.mainState.imageDifference,
                        setSettings: viewModel.mainState.setSettings,
                        partFeedback: viewModel.partFeedback,
                        partFeedbackState: PartFeedbackState()
                    ),
                    mainViewUpdate: $mainViewUpdate
                )
            }
            else {
                ZStack{
                    NavigationView {
                        SidebarView(
                            sidebarViewModel: SidebarViewModel(
                                state: SidebarViewState(
                                    currentInstrumentsSetName: viewModel.mainState.currentInstrumentsSet.name,
                                    currentInstrumentSet: viewModel.mainState.currentInstrumentsSet,
                                    buildSettings: viewModel.mainState.buildSettings
                                ),
                                currentInstrumentsSetIsChanged: { instrumentsSet in
                                    viewModel.currentModelInstrumentsSetChanged(
                                        instrumentsSet: instrumentsSet,
                                        sessionSettings: AppUtils.setSessionSetting()
                                    )
                                }
                            )
                        ).environmentObject(fileController)
                        
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
                                
                                feedbackObjects: viewModel.feedbackObjects,
                                feedbackObjectsSate: FeedbackObjectsState()
                            ),
                            mainViewUpdate: $mainViewUpdate
                        )
                        .environmentObject(fileController)
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                        .edgesIgnoringSafeArea([.top, .trailing])
                    }
                    .navigationViewStyle(DoubleColumnNavigationViewStyle())
                }
            }
        }
        
        else if viewModel.mainState.buildSettings.mainSettings == .muur {
            
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
                        feedbackObjects: viewModel.feedbackObjects,
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
                ).environmentObject(homeKitStore)
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
                        feedbackObjects: viewModel.feedbackObjects,
                        feedbackObjectsSate: FeedbackObjectsState()
                    ),
                    mainViewModel: viewModel
                )
                .navigationBarTitle("")
                .navigationBarHidden(false)
                .edgesIgnoringSafeArea([.top, .trailing])
                .onAppear{
                    viewModel.conductor.playEngineAndTracks()
                }
                .environmentObject(homeKitStore)
            }
        }
    }
}

//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}
