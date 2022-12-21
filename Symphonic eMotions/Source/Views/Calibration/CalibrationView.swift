//
//  CalibrationView.swift
//  Symphonic eMotions Intern
//
//  Created by Frans-Jan Wind on 06/11/2022.
//

import SwiftUI

struct  CalibrationView: View {
     
    @ObservedObject var calibrationModel: CalibrationModel
    @State var updateView: Int = 0
    
    @State var currentTrackID: String
    @State var currentPartID: String
    
    @State var rampUp: Float
    @State var rampDown: Float
    
    var setSettings: SetSettings
    
    @Binding var mainViewUpdate: BuildSettings.ActiveView
    
    init(calibrationModel: CalibrationModel, mainViewUpdate: Binding<BuildSettings.ActiveView>) {
        self.calibrationModel = calibrationModel
        self.setSettings = calibrationModel.setSettings
        self.currentTrackID = setSettings.settingsCurrentTrackID
        self.currentPartID = setSettings.settingsCurrentPartID
        self.rampUp = Float(setSettings.settingsRampUp)
        self.rampDown = Float(setSettings.settingsRampDown)
        self._mainViewUpdate = mainViewUpdate
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            HStack{
                //Light buttons and indicators
                VStack{
                    
//                    Button(role: .none, action: {
//                        self.updateView = calibrationModel.incrementImageMaxLightPart(updateView: updateView)
//                    }) {
//                        Label("", systemImage: "sun.max")
//                    }
//                    .disabled(calibrationModel.calibrationState.sessionSettings.imageMaxLightPart >= (calibrationModel.calibrationState.sessionSettings.imageMaxStepAmountLight*calibrationModel.calibrationState.sessionSettings.imageMaxStepSizeLight))
//                    .padding()
//                    .font(.system(size: 100))
                    
                    
                    EMButtonBig(
                        action: {
                            self.updateView = calibrationModel.incrementImageMaxLightPart(updateView: updateView)
                        },
                        color: .accentColor,
                        isSolid: false,
                        maxWidth: 120,
                        height: 120
                    ){
                        Label("", systemImage: "sun.max")
                    }
                    .disabled(calibrationModel.calibrationState.sessionSettings.imageMaxLightPart >= (calibrationModel.calibrationState.sessionSettings.imageMaxStepAmountLight*calibrationModel.calibrationState.sessionSettings.imageMaxStepSizeLight))
                    .frame(width: 160)
                    .padding(.bottom)
                    
                    
                    CalibrateLightView(
                        calibrationModel: calibrationModel,
                        updateView: self.updateView
                    )
                    .frame(width: 120, height: 180)
                    
                    
                    EMButtonBig(
                        action: {
                            self.updateView = calibrationModel.decrementImageMaxLightPart(updateView: updateView)
                        },
                        color: .accentColor,
                        isSolid: false,
                        maxWidth: 120,
                        height: 120
                    ){
                        Label("", systemImage: "moon")
                    }
                    .disabled(calibrationModel.calibrationState.sessionSettings.imageMaxLightPart <= (0-(calibrationModel.calibrationState.sessionSettings.imageMaxStepAmountLight*calibrationModel.calibrationState.sessionSettings.imageMaxStepSizeLight)))
                    .frame(width: 160)
                    .padding(.top)
                    
                    
                    
//                    Button(role: .none, action: {
//                        self.updateView = calibrationModel.decrementImageMaxLightPart(updateView: updateView)
//                    }) {
//                        Label("", systemImage: "moon")
//                    }
//                    .disabled(calibrationModel.calibrationState.sessionSettings.imageMaxLightPart <= (0-(calibrationModel.calibrationState.sessionSettings.imageMaxStepAmountLight*calibrationModel.calibrationState.sessionSettings.imageMaxStepSizeLight)))
//                    .font(.system(size: 100))
//                    .padding()
                    
                }
                .padding()
                .frame(width: geometry.size.width/3)
                
                //Part meter, Start and save
                VStack{
                    VStack{
                        
                        HStack {
                            
                            EMButton(
                                action: {
                                    
                                    self.calibrationModel.conductor.togglePlayEngineAndTracks(
                                        currentSetLevel: 0,
                                        setSettings: self.setSettings
                                    )
                                    self.updateView += 1
                                    
                                },
                                color: .accentColor,
                                isSolid: self.calibrationModel.conductor.isConductorPlayingSubject.value,
                                maxWidth: 150,
                                height: 50
                            ){
                                Text(self.calibrationModel.conductor.isConductorPlayingSubject.value ? "Stop" : "Start caliberen")
                            }.frame(width: 160)
                            
                            Spacer()
                            
                            EMButton(
                                action: {
                                    
                                    self.calibrationModel.calibrationTotal()
                                    AppUtils.createSessionFile(
                                        imageMax: self.calibrationModel.imageDifference.maxValueSubject.value,
                                        imageMaxLightPart: self.calibrationModel.calibrationState.sessionSettings.imageMaxLightPart,
                                        imageFeedback: self.calibrationModel.imageDifference.feedback.value
                                    )
                                    self.mainViewUpdate = .playView
                                    
                                },
                                color: .accentColor,
                                isSolid: false,
                                maxWidth: 150,
                                height: 50
                            ){
                                Text("Ga door")
                            }
                            .frame(width: 160, height: 80)
                            .disabled(self.calibrationModel.conductor.isConductorPlayingSubject.value)
                            
                        }
                        
                        CalibrateLPartMeterView(
                            calibrationModel: calibrationModel,
                            updateView: self.updateView,
                            value: .init(
                                get: {
                                    let currentMeterLevel = calibrationModel.partFeedbackState.ramped
                                    return Float(max(0, min(1, currentMeterLevel)))
                                },
                                set: { _ in }
                            )
                        )
                        .frame(width: 140)
                        
                        
                    }
                    
                }
                .padding()
                .frame(width: geometry.size.width/3)
                
                VStack{
                    Spacer()
                    
                    EMButtonBig(
                        action: {
                            self.calibrationModel.setImageMaxDistancePart(personButtonValue: 0.6)
                            self.updateView += 1
                        },
                        color: .accentColor,
                        isSolid: false,
                        maxWidth: 120,
                        height: 120
                    ){
                        Label("", systemImage: "hand.wave")
                    }
                    .disabled(self.calibrationModel.calibrationState.sessionSettings.imageFeedbackDisctancePart == 0.6)
                    .frame(width: 160)
                    
                    Spacer()
                    
                    EMButtonBig(
                        action: {
                            self.calibrationModel.setImageMaxDistancePart(personButtonValue: 0.4)
                            self.updateView += 1
                        },
                        color: .accentColor,
                        isSolid: false,
                        maxWidth: 120,
                        height: 120
                    ){
                        Label("", systemImage: "hand.wave")
                            .blur(radius: 3)
                    }
                    .disabled(self.calibrationModel.calibrationState.sessionSettings.imageFeedbackDisctancePart == 0.4)
                    .frame(width: 160)
                    
                    Spacer()
                    
                    EMButtonBig(
                        action: {
                            self.calibrationModel.setImageMaxDistancePart(personButtonValue: 0.2)
                            self.updateView += 1
                        },
                        color: .accentColor,
                        isSolid: false,
                        maxWidth: 120,
                        height: 120
                    ){
                        Label("", systemImage: "hand.wave")
                            .blur(radius: 6)
                    }
                    .disabled(self.calibrationModel.calibrationState.sessionSettings.imageFeedbackDisctancePart == 0.2)
                    .frame(width: 160)
                    
                    Spacer()
                }
                .padding()
                .frame(width: geometry.size.width/3)
            }
            .padding()
        }
        
    }
}
