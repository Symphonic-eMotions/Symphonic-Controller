//
//  LevelSpeed.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 03/04/2023.
//

import SwiftUI

struct LevelSpeedView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    
    let columnWidth: CGFloat = 150
    let headingSize: CGFloat = 20
    
    var body: some View {
        
        HStack{
            Text("Level speed")
                .font(.system(size: headingSize))
                .padding()
                .frame(width: columnWidth, alignment: .leading)
            
            HStack {
                Slider(value: $setInfoModel.setSettings.levelSpeed, in: 0...1)
                    .foregroundColor(.accentColor)
                
                Text("\(setInfoModel.setSettings.levelSpeed, specifier: "%.4f")")
                    .foregroundColor(.white)
                    .font(.subheadline)
            }
            .padding()
        }
    }
}
