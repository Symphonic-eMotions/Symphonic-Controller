//
//  CalibratorSlider.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 12/03/2023.
//

import SwiftUI

struct VerticalSlider: View {
    
    @Binding var value: Float
    init(
        value: Binding<Float>
    ) { _value = value }
    var body: some View {
        
        HStack{
//            Spacer()
            
            Slider(value: $value, in: 0...1)
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
    
    @ObservedObject var mainViewModel: MainViewModel
    @ObservedObject var playViewModel: PlayViewModel
    
    var body: some View {
        
            
            HStack{
                
                Spacer()
//                Spacer()
//
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
                
                VerticalSlider(value: Binding(
                    get: {
                        playViewModel.imageDifference.sensitivitySubject.value
                    },
                    set: {
                        playViewModel.imageDifference.sensitivitySubject.send($0)
                        playViewModel.imageDifference.sensitivityToMaxValue(sensitivity: $0)
                        playViewModel.imageDifference.sensitivityToFeedback(sensitivity: $0)
                    }
                ))
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
