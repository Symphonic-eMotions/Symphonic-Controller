//
//  MainView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 25/09/2024.
//

import SwiftUI

private struct PartSelection: Identifiable, Equatable {
    let trackId: String
    let partId: String
    var id: String { "\(trackId)#\(partId)" }
}

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding var sessionDisplay: SessionDisplay

    @StateObject var fileController = FileController()
    @StateObject var userSettings = UserSettings.shared

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
                case .setInfo, .swiftUI, .home:
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
            
            VStack(spacing: 12) {
                PartControlsPane(setInfoModel: setInfoModel)   // ⬅︎ knoppen + inline editor + feedback
                PlayOverlayView(setInfoModel: setInfoModel) // jouw bestaande overlay
                // Calibration en settings
                HStack {
                    CalibrationView(
                        userSettings: setInfoModel.userSettings,
                        setInfoModel: setInfoModel
                    )
                    // Settings button
                    SettingsButtonWithLongPress(
                        setInfoModel: setInfoModel
                    )
                }
            }
        case .home:
            EmptyView()
        default:
            EmptyView()
        }
    }

    private var mainContent: some View {
        Group {
            switch sessionDisplay {
            case .swiftUI:
                EmptyView()
            case .setInfo, .pro, .creator:
                SetInfo(
                    setInfoModel: setInfoModel,
                    isCreator: $isCreator,
                    sessionDisplay: $sessionDisplay,
                    userPresets: $userPresets
                )
                .environmentObject(fileController)
            case .home:
                EmptyView();
            default:
                EmptyView()
            }
        }
    }

    private func updateSidebarItems() {
        // Maak een duidelijke array met items, kwalificeer de enum-waarden volledig
        var items: [(name: String, setName: String, fileGroup: FileGroup, sessionDisplay: SessionDisplay)] = [
            (
                name: "Activeer camera",
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

