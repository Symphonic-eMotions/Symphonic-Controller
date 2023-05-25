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
    
    @ObservedObject var viewModelPlayerControls: PlayerControlsViewModel
    
    init(
        viewModelPlayerControls: PlayerControlsViewModel
    ){
        self.viewModelPlayerControls = viewModelPlayerControls
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 32.0) {
            
            VStack {
            
                HStack {
                    //Switch between video feedback modes
                    EMButton(action: {
                        viewModelPlayerControls.tapDisplayModeChange()
                    }, color: .accentColor, isSolid: false) {
                        viewModelPlayerControls.playerControlsViewState.displayMode.icon
                    }
                    
                    //Settings button
                    EMButtonLongPress(
                        viewModelPlayerControls: viewModelPlayerControls
                    )
                    
                    
                    if viewModelPlayerControls.playerControlsViewState.buildSettings.instrumentPartEditor {
                        //Master FX Button
                        EMButton(action: {
                            viewModelPlayerControls.tapMasterFxButton()
                        }, color: .accentColor, isSolid: false) {
                            Image(systemName: "fx")
                        }
                    }
                    
                    //Start stop
                    EMButton(action: {
                        viewModelPlayerControls.tapMediaControlButton()
                    }, color: .accentColor) {
                        Image(systemName: viewModelPlayerControls.conductor.isConductorPlayingSubject.value ?
                                "stop.fill" :
                                "play.fill")
                    }
                }
                
                HStack {
                    if viewModelPlayerControls.hasTempo {
                        EMButton(action: {
                            viewModelPlayerControls.tapSetTempoMin()
                        }, color: .accentColor, isSolid: false, maxWidth: 100) {
                            Image(systemName: "minus.square")
                        }
                        
                        EMButton(action: {
                            viewModelPlayerControls.tapSetTempoPlus()
                        }, color: .accentColor, isSolid: false, maxWidth: 100) {
                            Image(systemName: "plus.square")
                        }
                    }
                    
                    //Volume slider
                    VolumeSlider()
                       .frame(height: 10)
                       .padding(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 0))
                       .zIndex(101)
                }
            }
        }
    }
    
}
