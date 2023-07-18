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
    
    @AppStorage(UserDefaultsKeys.isSetPlaying) var isSetPlaying: Bool = false
    @AppStorage(UserDefaultsKeys.showPartEditor) var showPartEditor: Bool = false
    
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplaySub: SessionDisplay
    @Binding var showMasterTrack: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 32.0) {
            
            VStack {
            
                HStack {
                    //Switch between video feedback modes
                    EMButton(action: {
                        setInfoModel.tapDisplayModeChange()
                    }, color: .accentColor, isSolid: false) {
                        setInfoModel.setInfoState.displayMode.icon
                    }
                    
                    //Settings button
                    SettingsButtonWithLongPress(
                        setInfoModel: setInfoModel
                    )
                    
                    //Master FX Button only available in part editor
                    if showPartEditor {
                        EMButton(action: {
                            showMasterTrack.toggle()
                        }, color: .accentColor, isSolid: false) {
                            Text("Master")
                        }
                    }
                    
                    //Start stop
                    EMButton(action: {
                        
                        if isSetPlaying {
                            sessionDisplaySub = .stopped
                            setInfoModel.tapStopAudioEngine()
                            self.isSetPlaying = false
                            setInfoModel.leveling.pauseLevel = false
                        }
                        else{
                            sessionDisplaySub = .playing
                            setInfoModel.tapStartAudioEngine()
                            self.isSetPlaying = true
                        }
                        
                    }, color: .accentColor) {
                        Image(systemName: isSetPlaying ?
                                "stop.fill" :
                                "play.fill")
                    }
                }
            }
        }
    }
}
