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
    
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding var showingSheet: Bool
    @Binding var stopEngine: Bool
    @State private(set) var localTempo: Int = 0
    
    var body: some View {
        
        let sensitivityBinding = Binding(
            get: { self.sensitivity },
            set: {
                self.sensitivity = $0
                setInfoModel.imageDifference.sensitivitySubject.send(Float($0))
                setInfoModel.imageDifference.sensitivityToMaxValue(sensitivity: Float($0))
                setInfoModel.imageDifference.sensitivityToFeedback(sensitivity: Float($0))
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
                            setInfoModel.tapToggleConductor()
                        }, color: .accentColor) {
                            Image(systemName: setInfoModel.conductor.isConductorPlayingSubject.value ?
                                  "stop.fill" :
                                    "play.fill")
                        }
                        .frame(width: geometry.size.width * 0.333)
                        Spacer()
                    }
                }
                
                //Sensitivity
                VStack(alignment: .leading){
                    Text("Sensitivity").padding(.top)
                    Slider(value: sensitivityBinding, in: 0...1)
                }
                
                //Level speed
                VStack(alignment: .leading){
                    Text("Level speed \(String(format: "%.1f", levelSpeed))").padding(.top)
                    Slider(value: $levelSpeed, in: 0.1...1.5)
                }
                
                //Tempo
                if setInfoModel.setSettings.hasTempo {
                    
                    VStack(alignment: .leading){
                        Text("Tempo").padding(.top)
                        HStack{
                            
                            EMButton(action: {
                                setInfoModel.tapSetTempoBPMMin()
                                localTempo -= 1
                            }, color: .accentColor, isSolid: true, maxWidth: geometry.size.width * 0.111) {
                                Image(systemName: "minus")
                            }
                            
                            EMButton(action: {
                                print("Reset pressed")
                                localTempo = 0
                                setInfoModel.tapSetTempoReset()
                            }, color: .accentColor, isSolid: true, maxWidth: geometry.size.width * 0.111) {
                                Text(String(localTempo))
                            }
                            
                            EMButton(action: {
                                setInfoModel.tapSetTempoBPMPlus()
                                localTempo += 1
                            }, color: .accentColor, isSolid: true, maxWidth: geometry.size.width * 0.111) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
                
                //Volume
                VStack(alignment: .leading){
                    Text("Volume").padding(.top)
                    VolumeSlider()
                        .frame(height: 10)
                        .padding(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 0))
                        .zIndex(101)
                }
                
                Spacer()
                
                //Start stop
                EMButton(action: {
                    showingSheet = false
                    if !setInfoModel.conductor.isConductorPlayingSubject.value {
                        setInfoModel.conductor.levelController(
                            level: Int(setInfoModel.leveling.currentSetLevelSubject.value),
                            setSettings: setInfoModel.setSettings
                        )
                        setInfoModel.conductor.playEngineAndTracks(
                            setSettings: setInfoModel.setSettings,
                            level: Int(setInfoModel.leveling.currentSetLevelSubject.value)
                        )
                    }
                }, color: .green, isSolid: true) {
                    Text(NSLocalizedString("Continue", comment: ""))
                }
                .frame(width: geometry.size.width * 0.333)
                
            }
            .onAppear{
                if stopEngine {
                    setInfoModel.tapStopAudioEngine()
                }
            }
            .padding()
        }
    }
}
