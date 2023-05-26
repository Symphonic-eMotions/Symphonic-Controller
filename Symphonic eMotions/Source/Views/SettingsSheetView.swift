//
//  SettingsSheetView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 25/05/2023.
//

import SwiftUI

struct SettingsSheetView: View {
    
    @AppStorage(UserDefaultsKeys.levelSpeed) var levelSpeed: Double = 1
    @AppStorage(UserDefaultsKeys.sensitivity) var sensitivity: Double = 0.8
    
    @ObservedObject var playViewModel: PlayViewModel
    @Binding var showingSheet: Bool
    @Binding var stopEngine: Bool
    @State private(set) var localTempo: Int = 0
    
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
        
        return GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 15) {
                
                //Section(header: Text("Settings")) {
                
                //Start stop
                VStack(alignment: .leading){
                    Text("Play / Stop").padding(.top)
                    HStack {
                        
                        EMButton(action: {
                            playViewModel.tapMediaControlButton()
                        }, color: .accentColor) {
                            Image(systemName: playViewModel.conductor.isConductorPlayingSubject.value ?
                                  "stop.fill" :
                                    "play.fill")
                        }
                        .frame(width: geometry.size.width * 0.333)
                        Spacer()
                    }
                }
                
                VStack(alignment: .leading){
                    Text("Sensitivity").padding(.top)
                    Slider(value: sensitivityBinding, in: 0...1)
                }
                
                VStack(alignment: .leading){
                    Text("Level speed \(String(format: "%.1f", levelSpeed))").padding(.top)
                    Slider(value: $levelSpeed, in: 0.1...4)
                }
                
                //Tempo
                if playViewModel.setSettings.hasTempo {
                    
                    VStack(alignment: .leading){
                        Text("Tempo").padding(.top)
                        HStack{
                            
                            EMButton(action: {
                                playViewModel.tapSetTempoMin()
                                localTempo -= 1
                            }, color: .accentColor, isSolid: true, maxWidth: geometry.size.width * 0.111) {
                                Image(systemName: "minus")
                            }
                            
                            EMButton(action: {
                                print("Reset pressed")
                                localTempo = 0
                                playViewModel.tapSetTempoReset()
                            }, color: .accentColor, isSolid: true, maxWidth: geometry.size.width * 0.111) {
                                Text(String(localTempo))
                            }
                            
                            EMButton(action: {
                                playViewModel.tapSetTempoPlus()
                                localTempo += 1
                            }, color: .accentColor, isSolid: true, maxWidth: geometry.size.width * 0.111) {
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
                .frame(width: geometry.size.width * 0.333)
                
            }
            .onAppear{
                if stopEngine {
                    playViewModel.tapMediaControlButton()
                }
            }
            .padding()
        }
    }
}
