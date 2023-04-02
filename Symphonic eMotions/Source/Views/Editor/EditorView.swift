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

struct EditorView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    @EnvironmentObject var fileController: FileController
    
    @State var imported = false
    @State var fileUrl: URL?
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading){
                
                TextField("Custom name", text: $setInfoModel.setSettings.customName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading)
                    .padding(.trailing)
            
                SelectGrid(
                    setInfoModel: setInfoModel,
                    localGridRow: setInfoModel.setSettings.gridRows
                )
                
                SelectSpeed(
                    setInfoModel: setInfoModel
                )
                
                EditTracks(
                    setInfoModel: setInfoModel
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
        .padding(.leading)
        
        Divider()
        
        Text("Editing: \(setInfoModel.setSettings.setURL)")
    }
}
