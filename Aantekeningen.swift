//
//  Aantekeningen.swift
//  Symphonic eMotions MVP
//
//  Created by Frans-Jan Wind on 16/11/2023.
//

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
    @ObservedObject var setInfoModel: SetInfoModel
    //Highest lvel View control
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    
    
    //Keep track of local saved SeM setting files
    @StateObject var fileController = FileController()
    @StateObject var userSettings = UserSettings()
    
    @State var isCreator: Bool = false
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
        
        //Create Playlists if needed
        AppUtils.createPlayListFolders(resetPlaylist: true)
    }
    
    var body: some View {
            
        NavigationView {
            
            SideBarView(
                setInfoModel: setInfoModel,
                sessionDisplay: $sessionDisplay,
                sessionDisplaySub: $sessionDisplaySub,
                sidebarItems: $sidebarItems
            )
            .environmentObject(fileController)
            .onAppear {
                // Update `isCreator` based on the `userCode`
                isCreator = userSettings.userCode == .creator
                
                //Main navigation
                var items = [
                    (name: "Home", setName: "home", fileGroup: FileGroup.home, sessionDisplay: SessionDisplay.home),
//                        (name: "Active", setName: "playlists", fileGroup: FileGroup.playlists, sessionDisplay: SessionDisplay.playlists),
                    (name: "Pro", setName: "pro", fileGroup: FileGroup.pro, sessionDisplay: SessionDisplay.pro)
                ]
                
                //Add creator navigation item
                if isCreator {
                    items.append((name: "Creator", setName: "creator", fileGroup: FileGroup.template, sessionDisplay: SessionDisplay.creator))
                }
                
                sidebarItems = items
            }
            
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
                    
                }
            }
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        
    }
}

