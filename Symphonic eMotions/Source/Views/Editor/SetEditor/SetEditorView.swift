//
//  SetEditorView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 13/06/2023.
//

import SwiftUI

/*
 
 All parameters have 2 values, a local for state and value in setInfoModel
 
 */

struct SetEditorView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding var editorParts: [EditorParts]
    @Binding var showEditorPart: EditorParts
    @Binding var trackLevels: [String: [Int]]
    @Binding var noteNumbersLevels: [String: [Int]]
    @Binding var midiClipsLevels: [String: [Int]]
    
    @Binding var gridRow: Int
    @Binding var noteNumbersPositions: [String: [Int]]
    @Binding var midiClipPositions: [String: [Int]]
    
    let columnWidth: CGFloat = 150
    let headingSize: CGFloat = 20
    
    var body: some View {
        
        HStack{
            
            Group{
                Image("track")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
                    .padding(4)
                    .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
            }
            .padding(.leading)
            
            Text("Set settings")
                .font(.system(size: 20))
                .padding()
            
            Spacer()
            
            let trackNames: [String:String] = setInfoModel.trackNames()
            
            Picker("Select editor part", selection: $showEditorPart) {
                ForEach(editorParts, id: \.self) { part in
                    if trackNames.contains(where: {$0.key == part.rawValue}) {
                        Text(trackNames[part.rawValue] ?? "Unnamed track").tag(part)
                    }
                    else if part == .none || part == .set {
                        Text(part.rawValue.capitalized).tag(part)
                    }
                    else {
                        Text("\(part.rawValue.capitalized) all tracks").tag(part)
                    }
                    
                }
            }
            .pickerStyle(.inline)
            .frame(height: 100)
        }
        .onTapGesture {
            withAnimation {
                if showEditorPart == .set { showEditorPart = .none}
                else { showEditorPart = .set }
            }
        }
        
        if showEditorPart == .set {
//            HStack{
//                Text("Publish set")
//                    .font(.system(size: headingSize))
//                    .padding()
//                    .frame(width: columnWidth, alignment: .leading)
//                
//                Toggle("", isOn: $setInfoModel.setSettings.published)
//                    .frame(width: 50)
//                    .padding(.leading)
//                
//                Spacer()
//            }
            HStack{
                Text("Name")
                    .font(.system(size: headingSize))
                    .padding()
                    .frame(width: columnWidth, alignment: .leading)
                
                TextField("Custom name", text: $setInfoModel.setSettings.customName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading)
                    .padding(.trailing)
                    
            }
            HStack{
                Text("Project folder")
                    .font(.system(size: headingSize))
                    .padding()
                    .frame(width: columnWidth, alignment: .leading)
                
                TextField("Folder name", text: $setInfoModel.setSettings.filesPath)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading)
                    .padding(.trailing)
                    
            }
            HStack{
                Text("PlayViews")
                    .font(.system(size: headingSize))
                    .padding()
                    .frame(width: columnWidth, alignment: .leading)
                
                SelectUserViews(
                    setInfoModel: setInfoModel
                )
                .frame(height: 300)
            }
//            HStack{
//                Text("Skin")
//                    .font(.system(size: headingSize))
//                    .padding()
//                    .frame(width: columnWidth, alignment: .leading)
//                
//                SelectSkinView(
//                    setInfoModel: setInfoModel
//                )
//            }
            HStack{
                Text("Grid size")
                    .font(.system(size: headingSize))
                    .padding()
                    .frame(width: columnWidth, alignment: .leading)
                
                SelectGridSizeView(
                    setInfoModel: setInfoModel,
                    localGridRow: setInfoModel.setSettings.gridRows
                )
            }
            
            HStack{
                Text("BPM")
                    .font(.system(size: headingSize))
                    .padding()
                    .frame(width: columnWidth, alignment: .leading)
                
                BpmView(
                    setInfoModel: setInfoModel
                )
                Text("User controlled")
                    .font(.system(size: headingSize))
                    .padding()
                    .frame(width: columnWidth, alignment: .leading)
                
                Toggle("", isOn: $setInfoModel.setSettings.hasTempo)
                    .frame(width: 50)
                    .padding(.leading)
            }
            LevelsView(
                setInfoModel: setInfoModel,
                trackLevels: $trackLevels,
                noteNumbersLevels: $noteNumbersLevels,
                midiClipsLevels: $midiClipsLevels
            )
        }
    }
}
