//
//  SetLoadAndPlay.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 23/02/2023.
//

import SwiftUI

struct SetLoadAndPlay: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    
    var body: some View {
        
        HStack {
            Image(systemName: "play.fill")
                .foregroundColor(.white)
                .font(.system(size: 30))
            Text(setInfoModel.setInfoLocalState.setName)
                .foregroundColor(.white)
                .font(.headline)
                .padding(.trailing)
        }
        .padding(.vertical, 10.0)
        .padding(.leading, 10.0)
        .background(Color.accentColor)
        .cornerRadius(10.0)
        
    }
}
