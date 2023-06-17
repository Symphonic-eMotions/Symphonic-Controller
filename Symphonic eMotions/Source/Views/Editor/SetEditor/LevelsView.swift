//
//  Levels.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 05/04/2023.
//

import SwiftUI

struct LevelBox: View {
    
    var value: Int
    
    var body: some View {
        ZStack {
            
            Rectangle()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray)
                .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
            Text("\(value+1)")
                .foregroundColor(.primary)
        }
    }
}

struct LevelsView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @State private var levels: [Int]
    
    let headingSize: CGFloat = 20
    let columnWidth: CGFloat = 150
    
    init(setInfoModel: SetInfoModel){
        self.setInfoModel = setInfoModel
        _levels = State(initialValue: setInfoModel.setSettings.levels)
    }
    
    var body: some View {
        
        HStack() {
                
            Text("Nr. of levels")
                .font(.system(size: headingSize))
                .padding()
                .frame(width: columnWidth, alignment: .leading)
            
            HStack{
                Button("-") {
                    if setInfoModel.setSettings.levels.count > 1 {
                        setInfoModel.setSettings.levels.removeLast()
                        levels.removeLast()
                        setInfoModel.setSettings.updateTrackClipInLevel()
                    }
                }
                .disabled(setInfoModel.setSettings.levels.count == 1)
                .font(.system(size: 45))
                
                Button("+") {
                    setInfoModel.setSettings.levels.append(1)
                    let _ = print(setInfoModel.setSettings.levels.count)
                    levels.append(1)
                    setInfoModel.setSettings.updateTrackClipInLevel()
                }
                .font(.system(size: 45))
            }
            
            ForEach(0..<levels.count, id: \.self) { index in
                LevelBox(value: index)
            }
        }
        .padding()
        .onAppear{
            setInfoModel.setSettings.updateTrackClipInLevel()
        }
    }
}
