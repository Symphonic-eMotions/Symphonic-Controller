//
//  LevelSpeed.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 03/04/2023.
//

import SwiftUI

struct LevelSpeed: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    
    var body: some View {
        
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
