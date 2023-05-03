//
//  EditorView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 14/03/2023.
//

import SwiftUI

struct SetEditState {

    let setCollections: Sets
}

enum EditorParts: String, CaseIterable {
    case none
    case set
    case levels
    case source
    case start
    case variation
    case location
    //Lets be compatible with 16 tracks
    case track0
    case track1
    case track2
    case track3
    case track4
    case track5
    case track6
    case track7
    case track8
    case track9
    case track10
    case track11
    case track12
    case track13
    case track14
    case track15
}

struct EditorView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    @EnvironmentObject var fileController: FileController
    
    @State var imported = false
    @State var fileUrl: URL?
    @State var showEditorPart: EditorParts = .none
    let columnWidth: CGFloat = 150
    let headingSize: CGFloat = 20
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading){
                
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
                    
                    let selectableEditorParts: [EditorParts] = setInfoModel.selectableEditorParts()
                    let trackNames: [String:String] = setInfoModel.trackNames()
                    
                    Picker("Select  editor part", selection: $showEditorPart) {
                        ForEach(selectableEditorParts, id: \.self) { part in
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
                    HStack{
                        Text("Publish set")
                            .font(.system(size: headingSize))
                            .padding()
                            .frame(width: columnWidth, alignment: .leading)
                        
                        Toggle("", isOn: $setInfoModel.setSettings.published)
                            .frame(width: 50)
                            .padding(.leading)
                        
                        Spacer()
                    }
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
                        Text("Default skin")
                            .font(.system(size: headingSize))
                            .padding()
                            .frame(width: columnWidth, alignment: .leading)
                        
                        DefaultSkin(
                            setInfoModel: setInfoModel
                        )
                    }
                    HStack{
                        Text("Grid size")
                            .font(.system(size: headingSize))
                            .padding()
                            .frame(width: columnWidth, alignment: .leading)
                        
                        SelectGridSize(
                            setInfoModel: setInfoModel,
                            localGridRow: setInfoModel.setSettings.gridRows
                        )
                    }
                    
                    HStack{
                        Text("BPM")
                            .font(.system(size: headingSize))
                            .padding()
                            .frame(width: columnWidth, alignment: .leading)
                        
                        SelectSpeed(
                            setInfoModel: setInfoModel
                        )
                    }
                    
                    HStack{
                        Text("Level speed")
                            .font(.system(size: headingSize))
                            .padding()
                            .frame(width: columnWidth, alignment: .leading)
                        
                        LevelSpeed(
                            setInfoModel: setInfoModel
                        )
                    }
                    
                    HStack{
                        Text("Nr. of levels")
                            .font(.system(size: headingSize))
                            .padding()
                            .frame(width: columnWidth, alignment: .leading)
                        
                        Levels(
                            setInfoModel: setInfoModel
                        )
                    }
                }
                
                Divider()
                
                EditTracks(
                    setInfoModel: setInfoModel,
                    showEditorPart: $showEditorPart
                )
                
                
        //        Spacer()
        //        VStack (spacing: 30) {
        //            Button(action: {imported.toggle()}, label: {
        //                Text("Import MIDI file")
        //            })
        //            if let theUrl = fileUrl {
        //                Text("file url is \(theUrl.absoluteString)")
        //            }
        //        }
        //        .fileImporter(isPresented: $imported, allowedContentTypes: [.midi]) { res in
        //            do {
        //                fileUrl = try res.get()
        //                print("---> fileUrl: \(String(describing: fileUrl))")
        //            } catch{
        //                print ("error reading: \(error.localizedDescription)")
        //            }
        //        }
                
            }
        }
        Spacer()
        HStack {
            
            EMButton(
                action: {
                    let fileName = AppUtils.createWorkingFile(
                        setSettings: setInfoModel.setSettings,
                        instrumentSet: setInfoModel.setInfoState.currentInstrumentsSet,
                        duplicateLastTrack: false,
                        asNewFile: true
                    )
                    fileController.addSetFileURLToController(fileName: fileName)
                    
                    //Change the View
                    sessionDisplay = .setInfo
                    sessionDisplaySub = .none
                    
                }, color: .orange, isSolid: true, maxWidth: 130, height: 35
            ){ Text("New Set") }
            .frame(width: 130)
            
            if setInfoModel.setSettings.setURL.absoluteString != "dontOverWrite" {
                EMButton(
                    action: {
                        let fileName = AppUtils.createWorkingFile(
                            setSettings: setInfoModel.setSettings,
                            instrumentSet: setInfoModel.setInfoState.currentInstrumentsSet,
                            duplicateLastTrack: false,
                            asNewFile: false
                        )
                        fileController.addSetFileURLToController(fileName: fileName)
                        
                        //Change the View
                        sessionDisplay = .setInfo
                        sessionDisplaySub = .none
                        
                    }, color: .red, isSolid: true, maxWidth: 130, height: 35
                ){ Text("Save") }
                .frame(width: 130)
            }
        }
        .padding()
        
//        Text("Editing: \(setInfoModel.setSettings.setURL)")
    }
}
