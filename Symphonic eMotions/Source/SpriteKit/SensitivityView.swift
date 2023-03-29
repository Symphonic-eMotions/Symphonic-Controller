//
//  CalibratorSlider.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 12/03/2023.
//

import SwiftUI

struct VerticalSensitivitySlider: View {
    
    @ObservedObject var playViewModel: PlayViewModel
    @Binding var value: Float
    
    init(
        playViewModel: PlayViewModel,
        value: Binding<Float>
    ) {
        _value = value
        self.playViewModel = playViewModel
    }
    var body: some View {
        
        HStack{
            Slider(value: $value, in: 0...1, onEditingChanged: { changed in
                //Only on end of slide change
                if !changed {
                    
                    print("Sensitivity changed and stored to: \(value) \n setURL kept: \(playViewModel.setSettings.setURL)")
                    
                    AppUtils.createSessionFile(
                        sensitivity: value,
                        setURL: playViewModel.setSettings.setURL)
                }
            })
            .foregroundColor(.secondary)
            .foregroundColor(.white)
            .font(.subheadline)
            
            Text("Sensitiviy")
                .foregroundColor(.secondary)
                .foregroundColor(.white)
                .font(.subheadline)
                .scaleEffect(x: -1, y: 1, anchor: .center)
        }
    }
}

struct SensitivityView: View {
    
    @ObservedObject var playViewModel: PlayViewModel
    
    var body: some View {
        
            
            HStack{
                
                Spacer()
//                            VerticalSlider(value: Binding(
//                                get: {playViewModel.playViewState.displayOpacity},
//                                set: { (newval) in
//                                    self.playViewModel.playViewState.displayOpacity = newval
//
//                                }
//                            ))
//                            .frame(width: 450, height: 30)
//                            .padding(.bottom, 2)
//                            .zIndex(100)
                
                VerticalSensitivitySlider(
                    playViewModel: playViewModel,
                    value: Binding(
                        get: {
                            playViewModel.imageDifference.sensitivitySubject.value
                        },
                        set: {
                            playViewModel.imageDifference.sensitivitySubject.send($0)
                            playViewModel.imageDifference.sensitivityToMaxValue(sensitivity: $0)
                            playViewModel.imageDifference.sensitivityToFeedback(sensitivity: $0)
                        }
                    )
                )
                .frame(width: 450, height: 30)
//                .padding(.trailing)
                .zIndex(100)
//                .border(.green)
                .rotationEffect(Angle(degrees: 90))
                .scaleEffect(x: 1, y: -1, anchor: .center)
            }
//            .border(.red)
        }
    
}
