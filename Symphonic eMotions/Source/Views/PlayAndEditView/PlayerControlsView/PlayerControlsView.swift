//
//  PlayerControlsView.swift
//  PlayerControlsView
//
//  Created by Mihai Fratu on 31.07.2021.
//

import SwiftUI
import MediaPlayer
import UIKit

struct VolumeSlider: UIViewRepresentable {
   func makeUIView(context: Context) -> MPVolumeView {
      MPVolumeView(frame: .zero)
   }

   func updateUIView(_ view: MPVolumeView, context: Context) {}
}

struct PlayerControlsView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplaySub: SessionDisplay
    @Binding var showMasterTrack: Bool
    
    @State var areTracksRecording: Bool = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 32.0) {
            
            VStack {
            
                HStack {
                    //Switch between video feedback modes
                    EMButton(action: {
                        AnalyticsAction.instrumentCameraView.logEvent(
                            sessionDisplay: sessionDisplaySub,
                            fileGroup: setInfoModel.setSettings.fileGroup,
                            setName: setInfoModel.setSettings.setName
                        )
                        setInfoModel.tapDisplayModeChange()
                    }, color: .accentColor, isSolid: false) {
                        setInfoModel.setInfoState.displayMode.icon
                    }
                    
                    //Settings button
                    SettingsButtonWithLongPress(
                        setInfoModel: setInfoModel
                    )
                    
                    //Master FX Button only available in part editor
                    if userSettings.showPartEditor {
                        EMButton(action: {
                            AnalyticsAction.masterEfects.logEvent(
                                sessionDisplay: sessionDisplaySub,
                                fileGroup: setInfoModel.setSettings.fileGroup,
                                setName: setInfoModel.setSettings.setName
                            )
                            showMasterTrack.toggle()
                        }, color: .accentColor, isSolid: false) {
                            Text("Master")
                        }
                    }
                    
                    //In creator mode you can record all instruments separate
                    if UserCode(rawValue: UserDefaults.standard.string(forKey: "userCode") ?? UserCode.none.rawValue) == .creator {
                        
                        //Record tracks to file start stop
                        EMButton(action: {
                            
                            if areTracksRecording {
                                sessionDisplaySub = .stopped
                                setInfoModel.tapStopAudioEngine()
                                userSettings.isSetPlaying = false
                                setInfoModel.leveling.pauseLevel = false
                                
                                //Record part
                                
                                self.areTracksRecording = false
                                setInfoModel.tapStopRecordTracks()
                            }
                            else{
                                
                                sessionDisplaySub = .playing
                                setInfoModel.tapStartAudioEngine()
                                userSettings.isSetPlaying = true
                                
                                //Record part
                                setInfoModel.tapAStartRecordTracks()
                                self.areTracksRecording = true
                            }
                            
                        }, color: .accentColor) {
                            Image(systemName: areTracksRecording ? "record.circle" : "record.circle.fill")
                                    .foregroundColor(areTracksRecording ? .red : .primary)
                        }
                    }
                    
                    //Start stop
                    EMButton(action: {
                        
                        if userSettings.isSetPlaying {
                            AnalyticsAction.stopSet.logEvent(
                                sessionDisplay: sessionDisplaySub,
                                fileGroup: setInfoModel.setSettings.fileGroup,
                                setName: setInfoModel.setSettings.setName
                            )
                            sessionDisplaySub = .stopped
                            setInfoModel.tapStopAudioEngine()
                            userSettings.isSetPlaying = false
                            //Over ride hold level button
                            setInfoModel.leveling.pauseLevel = false
                        }
                        else{
                            AnalyticsAction.startSet.logEvent(
                                sessionDisplay: sessionDisplaySub,
                                fileGroup: setInfoModel.setSettings.fileGroup,
                                setName: setInfoModel.setSettings.setName
                            )
                            sessionDisplaySub = .playing
                            setInfoModel.tapStartAudioEngine()
                            userSettings.isSetPlaying = true
                        }
                        
                    }, color: .accentColor) {
                        Image(systemName: userSettings.isSetPlaying ?
                                "stop.fill" :
                                "play.fill")
                    }
                }
                .onAppear {
                    setInfoModel.onLevelReached = {
                        sessionDisplaySub = .stopped                    }
                }
            }
        }
    }
}
