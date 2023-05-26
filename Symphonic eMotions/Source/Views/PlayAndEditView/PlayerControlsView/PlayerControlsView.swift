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
    
    @ObservedObject var playViewModel: PlayViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 32.0) {
            
            VStack {
            
                HStack {
                    //Switch between video feedback modes
                    EMButton(action: {
                        playViewModel.tapDisplayModeChange()
                    }, color: .accentColor, isSolid: false) {
                        playViewModel.playViewState.displayMode.icon
                    }
                    
                    //Settings button
                    SettingsButtonWithLongPress(
                        playViewModel: playViewModel
                    )
                    
                    
                    if playViewModel.playViewState.buildSettings.instrumentPartEditor {
                        //Master FX Button
                        EMButton(action: {
                            playViewModel.tapMasterFxButton()
                        }, color: .accentColor, isSolid: false) {
                            Image(systemName: "fx")
                        }
                    }
                    
                    //Start stop
                    EMButton(action: {
                        playViewModel.tapMediaControlButton()
                    }, color: .accentColor) {
                        Image(systemName: playViewModel.conductor.isConductorPlayingSubject.value ?
                                "stop.fill" :
                                "play.fill")
                    }
                }
            }
        }
    }
    
}
