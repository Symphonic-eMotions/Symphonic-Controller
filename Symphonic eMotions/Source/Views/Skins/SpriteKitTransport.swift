//
//  SpriteKitTransport.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 07/02/2023.
//

import SwiftUI

struct SpriteKitTransport: View {
    
    @ObservedObject var mainViewModel: MainViewModel
    let transportHeigth: CGFloat
    
    init(mainViewModel: MainViewModel, transportHeigth: CGFloat) {
        self.mainViewModel = mainViewModel
        self.transportHeigth = transportHeigth
    }
    
    var body: some View {
        
        HStack{
            
            Text("Back")
                .frame(width: 150, height: transportHeigth)
                .font(.headline)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1.0))
                .zIndex(101)
                .onTapGesture {
                    mainViewModel.backButton()
                }
            
            VolumeSlider()
                .frame(width: 300, height: 20)
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
                .zIndex(100)
        }
    }
}
