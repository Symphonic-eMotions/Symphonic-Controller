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
    
    @Binding var showEditorPart: EditorParts
    @Binding var trackLevels: [String: [Int]]
    
    let columnWidth: CGFloat = 150
    let color: Color = .accentColor
    
    var body: some View {
        
        VStack(alignment: .leading){
        
            Divider()
            //Levels
            HStack() {
                
                ZStack {
                    
                    Rectangle()
                        .frame(width: 80, height: 35)
                        .foregroundColor(.clear)
                        .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(Color.primary))
                        .background( showEditorPart == .levels ? .clear : color )
                    
                    Text("Levels")
                        .frame(width: 80, height: 35)
                    
                }
                .frame(width: columnWidth, alignment: .leading)
                .onTapGesture {
                    withAnimation {
                        showEditorPart = .levels
                    }
                }
                
                ForEach(0..<setInfoModel.setSettings.levels.count, id: \.self) { level in
                    
                    let inLevel: Bool = (trackLevels[trackId]?.contains(level) == true)

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
                        if let i = trackLevels[trackId]!.firstIndex(of: level) {
                            trackLevels[trackId]!.remove(at: i)
                        }
                        else{
                            trackLevels[trackId]!.append(level)
                        }
                    }
                }
            }
        }
        .padding(.leading)
    }
}
