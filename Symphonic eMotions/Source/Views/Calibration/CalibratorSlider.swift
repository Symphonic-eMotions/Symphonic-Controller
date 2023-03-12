//
//  CalibratorSlider.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 12/03/2023.
//

import SwiftUI

struct CalibratorSlider: View {
    
    @ObservedObject var mainViewModel: MainViewModel
    @ObservedObject var playViewModel: PlayViewModel
    
    var body: some View {
        
        OpacitySlider(value: Binding(
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
