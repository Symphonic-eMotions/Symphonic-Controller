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
    @Binding var trackLevels: [String: [Int]]
    @Binding var noteNumbersLevels: [String: [Int]]
    @Binding var midiClipsLevels: [String: [Int]]
    @State private var levels: [Int]
    
    let headingSize: CGFloat = 20
    let columnWidth: CGFloat = 150
    
    init(
        setInfoModel: SetInfoModel,
        trackLevels: Binding<[String: [Int]]>,
        noteNumbersLevels: Binding<[String: [Int]]>,
        midiClipsLevels: Binding<[String: [Int]]>
    ){
        self.setInfoModel = setInfoModel
        _levels = State(initialValue: setInfoModel.setSettings.levels)
        _trackLevels = trackLevels
        _noteNumbersLevels = noteNumbersLevels
        _midiClipsLevels = midiClipsLevels
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
                        
                        for key in $trackLevels.wrappedValue.keys {
                            if var value = $trackLevels.wrappedValue[key], !value.isEmpty {
                                value.removeLast()
                                $trackLevels.wrappedValue[key] = value
                            }
                        }
                        for key in $noteNumbersLevels.wrappedValue.keys {
                            if var value = $noteNumbersLevels.wrappedValue[key], !value.isEmpty {
                                value.removeLast()
                                $noteNumbersLevels.wrappedValue[key] = value
                            }
                        }
                        for key in $midiClipsLevels.wrappedValue.keys {
                            if var value = $midiClipsLevels.wrappedValue[key], !value.isEmpty {
                                value.removeLast()
                                $midiClipsLevels.wrappedValue[key] = value
                            }
                        }
                    }
                }
                .disabled(setInfoModel.setSettings.levels.count == 1)
                .font(.system(size: 45))
                
                Button("+") {
                    setInfoModel.setSettings.levels.append(1)
                    let _ = print(setInfoModel.setSettings.levels.count)
                    levels.append(1)
                    
                    for key in $trackLevels.wrappedValue.keys {
                        if var value = $trackLevels.wrappedValue[key] {
                            value.append($trackLevels.wrappedValue.count)
                            $trackLevels.wrappedValue[key] = value
                        }
                    }
                    for key in $noteNumbersLevels.wrappedValue.keys {
                        if var value = $noteNumbersLevels.wrappedValue[key] {
                            value.append(0)
                            $noteNumbersLevels.wrappedValue[key] = value
                        }
                    }
                    for key in $midiClipsLevels.wrappedValue.keys {
                        if var value = $midiClipsLevels.wrappedValue[key] {
                            value.append(0)
                            $midiClipsLevels.wrappedValue[key] = value
                        }
                    }
                }
                .font(.system(size: 45))
            }
            
            ForEach(0..<levels.count, id: \.self) { index in
                LevelBox(value: index)
            }
        }
        .padding()
    }
}
