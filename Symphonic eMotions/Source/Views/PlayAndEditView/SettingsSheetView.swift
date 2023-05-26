//
//  SettingsSheetView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 25/05/2023.
//

import SwiftUI

struct SettingsSheetView: View {
    
    @AppStorage(UserDefaultsKeys.levelSpeed) var levelSpeed: Double = 0.5
    @AppStorage(UserDefaultsKeys.sensitivity) var sensitivity: Double = 0.5

    @ObservedObject var playViewModel: PlayViewModel
    @ObservedObject var viewModelPlayerControls: PlayerControlsViewModel
    @Binding var showingSheet: Bool
//    @Binding var sensitivity: Float
    @State private(set) var localTempo: Int = 0
    
    //    @State private var sensitivity = 0.5
    
    var body: some View {
        
        let sensitivityBinding = Binding(
            get: { self.sensitivity },
            set: {
                self.sensitivity = $0
                playViewModel.imageDifference.sensitivitySubject.send(Float($0))
                playViewModel.imageDifference.sensitivityToMaxValue(sensitivity: Float($0))
                playViewModel.imageDifference.sensitivityToFeedback(sensitivity: Float($0))
            }
        )
        
        return VStack(alignment: .leading, spacing: 15) {
            
            //Section(header: Text("Settings")) {
            
            //Start stop
            VStack(alignment: .leading){
                Text("Play / Stop").padding(.top)
                EMButton(action: {
                    viewModelPlayerControls.tapMediaControlButton()
                }, color: .accentColor) {
                    Image(systemName: playViewModel.conductor.isConductorPlayingSubject.value ?
                          "stop.fill" :
                            "play.fill")
                }
            }
            
            VStack(alignment: .leading){
                Text("Sensitivity").padding(.top)
                Slider(value: sensitivityBinding, in: 0...1)
            }
            
            VStack(alignment: .leading){
                Text(NSLocalizedString("Level speed \(levelSpeed)",comment: "")).padding(.top)
                Slider(value: $levelSpeed, in: 0.5...2)
            }
            
            //Tempo
            if playViewModel.setSettings.hasTempo {
                
                VStack{
                    Text("Tempo").padding(.top)
                    HStack{
                        
                        EMButton(action: {
                            viewModelPlayerControls.tapSetTempoMin()
                            localTempo -= 1
                        }, color: .accentColor, isSolid: true, maxWidth: 65) {
                            Image(systemName: "minus")
                        }
                        
                        EMButton(action: {
                            print("Reset pressed")
                            localTempo = 0
                            viewModelPlayerControls.tapSetTempoReset()
                        }, color: .accentColor, isSolid: true, maxWidth: 65) {
                            Text(String(localTempo))
                        }
                        
                        EMButton(action: {
                            viewModelPlayerControls.tapSetTempoPlus()
                            localTempo += 1
                        }, color: .accentColor, isSolid: true, maxWidth: 65) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            
            VStack(alignment: .leading){
                Text("Volume").padding(.top)
                VolumeSlider()
                    .frame(height: 10)
                    .padding(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 0))
                    .zIndex(101)
            }
            
            Spacer()
            
            EMButton(action: {
                showingSheet = false
            }, color: .green, isSolid: true) {
                Text(NSLocalizedString("Continue", comment: ""))
            }
            
        }
        .padding()
    }
}
