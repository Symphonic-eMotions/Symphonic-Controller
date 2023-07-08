//
//  SettingsSheetView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 25/05/2023.
//

import SwiftUI

struct SettingsSheetView: View {
    
    @AppStorage(UserDefaultsKeys.isSetPlaying) var isSetPlaying: Bool = false
    @AppStorage(UserDefaultsKeys.levelSpeed) var levelSpeed: Double = 1
    @AppStorage(UserDefaultsKeys.sensitivitySession) var sensitivitySession: Double = 0.8
    @AppStorage(UserDefaultsKeys.sensitivityDeviation) var sensitivityDeviation: Double = 0
    
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding var showingSheet: Bool
//    @Binding var stopEngine: Bool
    @State private(set) var localTempo: Int = 0
    
    var body: some View {
        
        let sensitivityBinding = Binding(
            get: { self.sensitivityDeviation },
            set: {
                self.sensitivityDeviation = $0
                setInfoModel.imageDifference.sensitivityDeviationSubject.send(Float($0))
                
                
                let sensitivity: Float = Float(sensitivitySession + sensitivityDeviation)
                print("SENDING SESSION PRESET PLUS DEVIATION: \(self.sensitivitySession) + \(self.sensitivityDeviation)")
                setInfoModel.imageDifference.sensitivityToMaxValue(sensitivityPlusDeviation: sensitivity)
                
            }
        )
        
        return GeometryReader { geometry in
            
            ScrollView{
                
                VStack(alignment: .leading, spacing: 15) {
                    
                    //Start stop
                    VStack(alignment: .leading){
                        
                        Text( self.isSetPlaying ? "Stop" : "Play").padding(.top)
                        HStack {
                            
                            EMButton(action: {
                                
                                if isSetPlaying {
                                    setInfoModel.tapStopAudioEngine()
                                    self.isSetPlaying = false
                                }
                                else{
                                    setInfoModel.tapStartAudioEngine()
                                    self.isSetPlaying = true
                                }
                                
                            }, color: .accentColor) {
                                Image(systemName: isSetPlaying ?
                                      "stop.fill" :
                                        "play.fill")
                            }
                            .frame(width: geometry.size.width * 0.333)
                            Spacer()
                        }
                    }
                    
                    //Sensitivity deviation
                    VStack(alignment: .leading){
                        Text("Sensitivity").padding(.top)
                        HStack {
                            Text("-")
                            Spacer()
                            Text("0")
                            Spacer()
                            Text("+")
                        }
                        Slider(value: sensitivityBinding, in: -0.25...0.25)
                    }
                    
                    FeedbackButtonsView(
                        setInfoModel: setInfoModel,
                        imageSide: UIScreen.main.bounds.width * 0.05
                    )
                    
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
                    
                    //Continue
                    EMButton(action: {
                        showingSheet = false
//                        if !isSetPlaying {
//                            setInfoModel.conductor.levelController(
//                                level: Int(setInfoModel.leveling.currentSetLevelSubject.value),
//                                setSettings: setInfoModel.setSettings
//                            )
//                            setInfoModel.conductor.playEngineAndTracks(
//                                setSettings: setInfoModel.setSettings,
//                                level: Int(setInfoModel.leveling.currentSetLevelSubject.value)
//                            )
//                        }
                    }, color: .green, isSolid: true) {
                        Text(NSLocalizedString("Continue", comment: ""))
                    }
                    .frame(width: geometry.size.width * 0.333)
                    
                }
//                .onAppear{
//                    if stopEngine {
//                        setInfoModel.tapStopAudioEngine()
//                    }
//                }
                .padding()
            }
        }
    }
}
