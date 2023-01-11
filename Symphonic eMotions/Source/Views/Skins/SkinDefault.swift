//
//  SkinDefault.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 10/01/2023.
//

import SwiftUI

struct SkinDefault: View {
    
    @ObservedObject var playViewModel: PlayViewModel
    @ObservedObject var mainViewModel: MainViewModel
    
    var body: some View {
        
        ZStack {
            
            Image(systemName: "arrowshape.backward.fill").resizable().scaledToFit()
                .padding(.all)
                .frame(width: 100, height: 100, alignment: .top)
                .onTapGesture {
                    print("TODO UNLOAD SET")
                    mainViewModel.backButtonSkins()
                }
                .position(x: 40, y: 40)
            
            SkinGridImages(
                playViewModel: playViewModel,
                mainViewModel: mainViewModel
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack{
                Spacer()
                VolumeSlider()
                    .frame(height: 20, alignment: .bottom)
                    .tint(Color.purple)
                   .zIndex(100)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
//            .border(.yellow)
        }
//        .border(.green)
    }
}
