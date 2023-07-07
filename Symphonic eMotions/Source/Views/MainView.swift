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
    
    @AppStorage("userCode") private var userCodeRaw: String = UserCode.none.rawValue
    
    @ObservedObject var viewModel: MainViewModel
    @ObservedObject var setInfoModel: SetInfoModel
    //Highest lvel View control
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    
    
    //Keep track of local saved SeM setting files
    @StateObject var fileController = FileController()
    @State var userPresets: [URL] = []
    @State var templatePresets: [URL] = []
    
    // Initialize sidebarItems as @State
    @State var sidebarItems: [(name: String, setName: String, fileGroup: FileGroup, sessionDisplay: SessionDisplay)] = []
    
    init(
        viewModel: MainViewModel,
        setInfoModel: SetInfoModel,
        sessionDisplay: Binding<SessionDisplay>,
        sessionDisplaySub: Binding<SessionDisplay>
    ) {
        
        self.viewModel = viewModel
        self.setInfoModel = setInfoModel
        self._sessionDisplay = sessionDisplay
        self._sessionDisplaySub = sessionDisplaySub
        
        //Main navigation
        var items = [
            (name: "Home", setName: "home", fileGroup: FileGroup.home, sessionDisplay: SessionDisplay.home),
            // (name: "Demo", setName: "demo", fileGroup: FileGroup.demo, sessionDisplay: SessionDisplay.demo),
            (name: "Active", setName: "playlists", fileGroup: FileGroup.playlists, sessionDisplay: SessionDisplay.playlists),
            (name: "Pro", setName: "pro", fileGroup: FileGroup.pro, sessionDisplay: SessionDisplay.pro)
        ]
        
        if UserCode(rawValue: UserDefaults.standard.string(forKey: "userCode") ?? UserCode.none.rawValue) == .creator {
            items.append((name: "Creator", setName: "creator", fileGroup: FileGroup.template, sessionDisplay: SessionDisplay.creator))
        }
        
        _sidebarItems = State(initialValue: items)
        
        //Create Playlists if needed
        AppUtils.createPlayListFolders()
    }
    
    var body: some View {
        
        //SpriteKit (2D Game) interface
        if sessionDisplay == .spriteKit {
            SpriteKitView(
                setInfoModel: setInfoModel,
                mainViewModel: viewModel,
                sessionDisplay: $sessionDisplay,
                sessionDisplaySub: $sessionDisplaySub
            )
            .padding(.top, 20)
        }
        
        //Playlist full screen count down
        if sessionDisplay == .countDown {
            
            CountDown(
                setInfoModel: setInfoModel,
                sessionDisplay: $sessionDisplay,
                sessionDisplaySub: $sessionDisplaySub
            )
            .environmentObject(fileController)
        }
        
        //Introdcution
        if sessionDisplay == .home {
            
            //Light measurment
            if sessionDisplaySub == .page03 {
                LightView(
                    setInfoModel: setInfoModel,
                    sessionDisplay: $sessionDisplay,
                    sessionDisplaySub: $sessionDisplaySub
                )
            }
            //Movment settings
            else if sessionDisplaySub == .page04 {
                MovementView(
                    setInfoModel: setInfoModel,
                    sessionDisplay: $sessionDisplay,
                    sessionDisplaySub: $sessionDisplaySub
                )
            }
            else {
                IntroductionView(
                    setInfoModel: setInfoModel,
                    sessionDisplay: $sessionDisplay,
                    sessionDisplaySub: $sessionDisplaySub
                )
            }
        }
        //SwiftUI Interface with Part editor
        else if [.swiftUI,.setInfo,.pro,.demo,.creator].contains(sessionDisplay) {
            
            NavigationView {
                
                SideBarView(
                    setInfoModel: setInfoModel,
                    sessionDisplay: $sessionDisplay,
                    sessionDisplaySub: $sessionDisplaySub,
//                    setInfoLocalState: $setInfoLocalState,
                    sidebarItems: $sidebarItems
                )
                .environmentObject(fileController)
                
                //SeM Pro interface with interaction editor
                if sessionDisplay == .swiftUI {
                    
                    ZStack{
                        PlayView(
                            setInfoModel: setInfoModel,
                            sessionDisplay: $sessionDisplay,
                            sessionDisplaySub: $sessionDisplaySub
                        )
                        .environmentObject(fileController)
                        .navigationBarHidden(false)
                        //It's not called PlayView for nothing
                        .onAppear{
                            sessionDisplaySub = .playing
                            viewModel.conductor.playEngineAndTracks(
                                setSettings: viewModel.mainState.setSettings,
                                level: 0
                            )
                            viewModel.conductor.levelController(
                                level: 0,
                                setSettings: viewModel.mainState.setSettings
                            )
                        }
                        .onDisappear{
                            sessionDisplaySub = .stopped
                            viewModel.conductor.pauzeEngineAndStopTracks(
                                setSettings: viewModel.mainState.setSettings,
                                resetLevels: true
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
                        setInfoModel: setInfoModel,
                        sessionDisplay: $sessionDisplay,
                        sessionDisplaySub: $sessionDisplaySub
                    )
                    .environmentObject(fileController)
                }
                
                //Selected set info View
                else if [.setInfo,.pro,.creator].contains(sessionDisplay) {
                    
                    SetInfo(
                        setInfoModel: setInfoModel,
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
                    setInfoModel: setInfoModel,
                    sessionDisplay: $sessionDisplay,
                    sessionDisplaySub: $sessionDisplaySub,
//                    setInfoLocalState: $setInfoLocalState,
                    sidebarItems: $sidebarItems
                )
                .environmentObject(fileController)
                
                PlayListsView(
                    setInfoModel: setInfoModel,
                    sessionDisplay: $sessionDisplay,
                    sessionDisplaySub: $sessionDisplaySub
                )
                .environmentObject(fileController)
            }
        }
        
        ChangeView(
            sessionDisplay: $sessionDisplay,
            sessionDisplaySub: $sessionDisplaySub
        )
    }
}

