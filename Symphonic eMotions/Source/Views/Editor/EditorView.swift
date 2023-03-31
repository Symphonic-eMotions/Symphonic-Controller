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

       
        TextField("Custom name", text: $setInfoModel.setSettings.customName)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
    
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
                    
                    
                }, color: .orange, isSolid: true, maxWidth: 130, height: 35
            ){
                Text("New file")
            }.frame(width: 130)
            
            let isDisabled = setInfoModel.setSettings.setURL.absoluteString == "dontOverWrite"
            
            EMButton(
                action: {
                    
                    let fileName = AppUtils.createWorkingFile(
                        setSettings: setInfoModel.setSettings,
                        instrumentSet: setInfoModel.setInfoState.currentInstrumentsSet,
                        duplicateLastTrack: false,
                        asNewFile: false
                    )
                    fileController.addSetFileURLToController(fileName: fileName)
                    
                    
                }, color: .red, isSolid: true, maxWidth: 130, height: 35
            ){
                Text("Overwrite")
            }
            .frame(width: 130)
            .disabled(isDisabled)
        }
        
        Spacer()
        Text("Editing: \(setInfoModel.setSettings.setURL)")
    }
}
