//
//  SetInfo.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 23/02/2023.
//

import SwiftUI

struct SetInfoLocalState {
    var setName: String
    // String of document with relative path with extension
    var setConfig: String
    // Path of setting
    var setURL: String
    // Navigation header
    var sideBarHead: String

    init() {
        setName = "home"
        setConfig = ""
        setURL = "SetInfoLocalState"
        sideBarHead = NSLocalizedString("Welcome", comment: "Header of left navigation bar")
    }
}

struct SetInfo: View {
    @EnvironmentObject var userSettings: UserSettings
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding var isCreator: Bool
    @Binding var sessionDisplay: SessionDisplay
    @EnvironmentObject var fileController: FileController
    @Binding var userPresets: [URL]

    var body: some View {
        VStack {
            // .home is the page on entering app, also accesible by clicking the Sets header in the side bar
            if sessionDisplay == .pro {
                SetInfoHome(
                    //                    setInfoModel: setInfoModel,
//                    sessionDisplay: $sessionDisplay
                    userSettings: userSettings
                )
            }
            // Set info is also the navigator to saved files within the set
            else if sessionDisplay == .setInfo {
                // Here we got the Editor!
//                if [.setEditor,.playListEditor].contains(sessionDisplaySub) {
//
//                    Text("Variation \(setInfoModel.setInfoLocalState.setName)")
//                        .font(.largeTitle)
//                        .fontWeight(.regular)
//
//                    EditorView(
//                        setInfoModel: setInfoModel,
//                        isCreator: $isCreator,
//                        sessionDisplay: $sessionDisplay,
//                        sessionDisplaySub: $sessionDisplaySub
//                    ).environmentObject(fileController)
//                }
                // Set Info
//                else{

                // Title set name
                Text("Set \(setInfoModel.setInfoLocalState.setName)")
                    .font(.largeTitle)
                    .fontWeight(.regular)
                // Main play set button
                HStack {
                    Spacer()
                    SetLoadAndPlay(setInfoModel: setInfoModel)
                        .onTapGesture {
                            // We do not want to go to the next set
                            setInfoModel.setSettings.currentPlaylist = .none
                            // Load set
                            setInfoModel.tapSetRow(
                                filePath: setInfoModel.setInfoLocalState.setConfig
                            )
                            // Save current location
                            userSettings.currentUrl = setInfoModel.setInfoLocalState.setConfig
                            // Start capturing engine
                            setInfoModel.userSettings.isCapturingRunning = true
                            // Change View
                            sessionDisplay = .swiftUI
                        }
                    Spacer()
                    // New variation button
                    EMButton(
                        action: {
                            setInfoModel.setInfoState.currentInstrumentsSet = AppUtils.loadInstrumentSet(json: setInfoModel.setInfoLocalState.setConfig)

                            if setInfoModel.setInfoState.currentInstrumentsSet.name != "No Set" {
                                let setSetting = AppUtils.setSettings(
                                    instrumentSet: setInfoModel.setInfoState.currentInstrumentsSet
                                )
                                // Add new file to document directory
                                _ = AppUtils.createWorkingFile(
                                    setSettings: setSetting,
                                    instrumentSet: setInfoModel.setInfoState.currentInstrumentsSet,
                                    duplicateLastTrack: false,
                                    asNewFile: true
                                )
                                // Reload view
                                userPresets = fileController.getContentsOfDirectory()
                            }
                        }, color: .orange, isSolid: true, maxWidth: 170, height: 35
                    ) {
                        Text(NSLocalizedString("New variation", comment: ""))
                    }
                    .frame(width: 170, height: 50)
                    Spacer()
                }

//                    Spacer(minLength: 20)

                ScrollView {
                    SavedSetsList(
                        setInfoModel: setInfoModel,
                        sessionDisplay: $sessionDisplay,
                        userPresets: $userPresets
                    )
                    .environmentObject(fileController)
                }
                Spacer()
            }
        }
        .onAppear {
            userSettings.isSetPlaying = false
            userSettings.showPartEditor = false
        }
    }
}
