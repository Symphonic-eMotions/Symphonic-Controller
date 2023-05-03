//
//  InLevelView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 10/04/2023.
//

import SwiftUI

struct InLevelView: View{
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    var trackId: String
    
    let columnWidth: CGFloat = 150
    let color: Color = .accentColor
    
    @State var trackLevels: [Int]
    
    init(setInfoModel: SetInfoModel, currentTrack: TrackSettings, trackId: String){
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _trackLevels = State(initialValue: currentTrack.levels)
    }
    
    var body: some View {
        
        VStack(alignment: .leading){
        
            Divider()
            //Track is presenr in level
            HStack() {
                
                Text("Active in level")
                .frame(width: columnWidth, alignment: .leading)
                
                ForEach(0..<setInfoModel.setSettings.levels.count, id: \.self) { level in
                    
                    let inLevel: Bool = trackLevels.contains(level) ? true : false
                    
                    ZStack {
                        
                        Rectangle()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.clear)
                        .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
//                        .foregroundColor(inLevel ? color : .white)
                        .background(inLevel ? color : .clear)
                    
                        
                        Text("\(level+1)")
                            .foregroundColor(inLevel ? .white : .gray)
                    }
                    .onTapGesture {
                        //For saving
                        setInfoModel.setSettings.updateLevelIndex(trackId: trackId, level: level)
                        //For UI
                        if let i = trackLevels.firstIndex(of: level) {
                            trackLevels.remove(at: i)
                        }
                        else{
                            trackLevels.append(level)
                        }
                    }
                    
                }
            }
            
        }
        .padding(.leading)
    }
}
