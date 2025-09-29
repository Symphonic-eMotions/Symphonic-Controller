//
//  PlayerControlsView.swift
//  PlayerControlsView
//
//  Created by Mihai Fratu on 31.07.2021.
//

import MediaPlayer
import SwiftUI
import UIKit

struct VolumeSlider: UIViewRepresentable {
    func makeUIView(context _: Context) -> MPVolumeView {
        MPVolumeView(frame: .zero)
    }

    func updateUIView(_: MPVolumeView, context _: Context) {}
}

struct PlayerControlsView: View {
    @EnvironmentObject var userSettings: UserSettings
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding var showMasterTrack: Bool

//    @State var areTracksRecording: Bool = false

    var body: some View {
        HStack(alignment: .center, spacing: 32.0) {
            VStack {
                HStack {
                    // Switch between video feedback modes
                    EMButton(action: {
                        setInfoModel.tapDisplayModeChange()
                    }, color: .accentColor, isSolid: false) {
                        setInfoModel.setInfoState.displayMode.icon
                    }

                    // Settings button
                    SettingsButtonWithLongPress(
                        setInfoModel: setInfoModel
                    )

                    // Master FX Button only available in part editor
                    if userSettings.showPartEditor {
                        EMButton(action: {
                            showMasterTrack.toggle()
                        }, color: .accentColor, isSolid: false) {
                            Text("Master")
                        }
                    }

                    // Creator mode
                    if UserCode(rawValue: UserDefaults.standard.string(forKey: "userCode") ?? UserCode.none.rawValue) == .creator {
                        EMButton(action: {
                            userSettings.showPartEditor.toggle()
                        }, color: .accentColor, isSolid: false) {
                            Image(systemName: userSettings.showPartEditor ? "wrench.adjustable" : "wrench.adjustable.fill")
                        }
                    }

                    // Start stop
                    EMButton(action: {
                        if userSettings.isSetPlaying {
                            setInfoModel.tapStopAudioEngine()
                            userSettings.isSetPlaying = false
                        } else {
                            setInfoModel.tapStartAudioEngine()
                            userSettings.isSetPlaying = true
                        }

                    }, color: .accentColor) {
                        Image(systemName: userSettings.isSetPlaying ?
                            "stop.fill" :
                            "play.fill")
                    }
                }
            }
        }
    }
}
