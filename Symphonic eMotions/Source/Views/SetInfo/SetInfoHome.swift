//
//  SetInfoHome.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 23/02/2023.
//

import SwiftUI
import AVFoundation

struct SetInfoHome: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplay: SessionDisplay
    
    var body: some View {
        VStack{
            Spacer().frame(height:70)
            HStack {
                
                Image("LogoColor")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
                
                
                Text("Symphonic eMotions")
                    .font(.largeTitle)
                    .fontWeight(.regular)
                    .padding(.leading, 40)
                
            }
            Spacer()
        }
    }
}
