//
//  CalibratorSlider.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 12/03/2023.
//

import SwiftUI

struct OpacitySliderVertical: View {
    
    @Binding var value: Float
    init(
        value: Binding<Float>
    ) { _value = value }
    var body: some View {
        
        Slider(value: $value, in: 0...1)
            .foregroundColor(.secondary)
            .foregroundColor(.white)
            .font(.subheadline)
    }
}

//TODO: Make vertical
struct OpacitySlider: View {
    
    @Binding var value: Float
    
    var body: some View {
        GeometryReader { geometry in
            
        }
    }
}

struct CalibratorSlider: View {
    
    @Binding var value: Float
    init(
        value: Binding<Float>
    ) { _value = value }
    var body: some View {
        
        Slider(value: $value, in: 0...1)
            .foregroundColor(.secondary)
            .foregroundColor(.white)
            .font(.subheadline)
    }
}

struct CalibratorView: View {
    
    @ObservedObject var mainViewModel: MainViewModel
    @ObservedObject var playViewModel: PlayViewModel
    
    var body: some View {
        
        OpacitySliderVertical(value: Binding(
            get: {playViewModel.playViewState.displayOpacity},
            set: { (newval) in
                self.playViewModel.playViewState.displayOpacity = newval
                
            }
        ))
        .frame(width: 200, height: 20)
        .padding(.bottom, 2)
        .zIndex(100)
        
    }
}
