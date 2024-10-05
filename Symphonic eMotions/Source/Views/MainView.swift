//
//  MainView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 25/09/2024.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding var sessionDisplay: SessionDisplay
    // Verwijder sessionDisplaySub

    @StateObject var fileController = FileController()
    @StateObject var userSettings = UserSettings()
    
    @State var isCreator: Bool = false
    @State var userPresets: [URL] = []
    @State var sidebarItems: [(name: String, setName: String, fileGroup: FileGroup, sessionDisplay: SessionDisplay)] = []
    @State private var showLevelPlayerFullScreen: Bool = false
    
    // State to manage the navigation path
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                // Sidebar or Tab view for navigation items
                SideBarView(
                    setInfoModel: setInfoModel,
                    sessionDisplay: $sessionDisplay,
                    sidebarItems: $sidebarItems
                )
                .environmentObject(fileController)
                .onAppear {
                    isCreator = userSettings.userCode == .creator
//                    updateSidebarItems()
                }
                
                // Main content based on the sessionDisplay
                mainContent
                    .navigationDestination(for: SessionDisplay.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .onAppear {
                updateSidebarItems()
            }
            .onChange(of: sessionDisplay) { newValue in
                switch newValue {
                case .setInfo, .swiftUI:
                    navigationPath.append(newValue)
                default:
                    break
                }
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for destination: SessionDisplay) -> some View {
        switch destination {
        case .setInfo:
            SetInfo(
                setInfoModel: setInfoModel,
                isCreator: $isCreator,
                sessionDisplay: $sessionDisplay,
                userPresets: $userPresets
            )
            .environmentObject(fileController)

        case .swiftUI:
            PlayView(
                setInfoModel: setInfoModel,
                sessionDisplay: $sessionDisplay,
                showLevelPlayerFullScreen: $showLevelPlayerFullScreen
            )
            .environmentObject(fileController)
            .onAppear {
                viewModel.conductor.levelController(
                    level: 0,
                    setSettings: viewModel.mainState.setSettings
                )
            }
            .onDisappear {
                viewModel.conductor.pauzeEngineAndStopTracks(
                    setSettings: viewModel.mainState.setSettings,
                    resetLevels: true
                )
            }

        default:
            EmptyView()
        }
    }
    
    private var mainContent: some View {
        Group {
            switch sessionDisplay {
            case .swiftUI:
                PlayView(
                    setInfoModel: setInfoModel,
                    sessionDisplay: $sessionDisplay,
                    showLevelPlayerFullScreen: $showLevelPlayerFullScreen
                )
                .environmentObject(fileController)
                .navigationBarHidden(false)
                .onAppear{
                    viewModel.conductor.levelController(
                        level: 0,
                        setSettings: viewModel.mainState.setSettings
                    )
                }
                .onDisappear{
                    viewModel.conductor.pauzeEngineAndStopTracks(
                        setSettings: viewModel.mainState.setSettings,
                        resetLevels: true
                    )
                }
                
                //If levels are completed go to count down view
                //At the moment this is not possible
                .onReceive(viewModel.leveling.currentSetLevelSubject){ currentSetLevel in
                    if viewModel.mainState.setSettings.currentPlaylist != .none {
                        if currentSetLevel >= Double(viewModel.mainState.setSettings.levels.count) {
                            self.sessionDisplay = .countDown
                        }
                    }
                }

            case .setInfo, .pro, .creator:
                SetInfo(
                    setInfoModel: setInfoModel,
                    isCreator: $isCreator,
                    sessionDisplay: $sessionDisplay,
                    userPresets: $userPresets
                )
                .environmentObject(fileController)
            default:
                EmptyView()
            }
        }
    }
    
    private func updateSidebarItems() {
        // Maak een duidelijke array met items, kwalificeer de enum-waarden volledig
        var items: [(name: String, setName: String, fileGroup: FileGroup, sessionDisplay: SessionDisplay)] = [
            (
                name: "Home",
                setName: "home",
                fileGroup: .home,
                sessionDisplay: .home
            ),
            (
                name: "Pro",
                setName: "pro",
                fileGroup: .pro,
                sessionDisplay: .pro
            )
        ]
        
        // Voeg de 'Creator' optie toe indien de gebruiker een creator is
        if isCreator {
            items.append(
                (
                    name: "Creator",
                    setName: "creator",
                    fileGroup: .template,
                    sessionDisplay: .creator
                )
            )
        }
        
        // Update de sidebarItems state met de nieuwe items
        sidebarItems = items
    }
}

