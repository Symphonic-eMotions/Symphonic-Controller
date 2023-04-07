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

struct Levels: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @State private var levels: [Int]
    
    init(setInfoModel: SetInfoModel){
        self.setInfoModel = setInfoModel
        _levels = State(initialValue: setInfoModel.setSettings.levels)
    }
    
    var body: some View {
        HStack() {
            Button("-") {
                if setInfoModel.setSettings.levels.count > 1 {
                    setInfoModel.setSettings.levels.removeLast()
                    let _ = print(setInfoModel.setSettings.levels.count)
                    levels.removeLast()
                }
            }
            .disabled(setInfoModel.setSettings.levels.count == 1)
            .font(.system(size: 30))
            
            ForEach(0..<levels.count, id: \.self) { index in
                LevelBox(value: index)
            }
            
            Button("+") {
                setInfoModel.setSettings.levels.append(1)
                let _ = print(setInfoModel.setSettings.levels.count)
                levels.append(1)
            }
            .font(.system(size: 30))
        }
    }
}
