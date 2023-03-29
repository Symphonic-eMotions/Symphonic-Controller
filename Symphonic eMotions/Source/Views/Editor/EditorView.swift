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
    
    @State var imported = false
    @State var fileUrl: URL?
    
    var body: some View {
        Spacer()
        Text("Editor for \(setInfoModel.setInfoLocalState.setName)")
            .font(.largeTitle)
            .fontWeight(.regular)
        Text("We need setSettings -> \(setInfoModel.setSettings.setName)")
        Spacer()
        VStack (spacing: 30) {
            Button(action: {imported.toggle()}, label: {
                Text("Import MIDI file")
            })
            if let theUrl = fileUrl {
                Text("file url is \(theUrl.absoluteString)")
            }
        }
        .fileImporter(isPresented: $imported, allowedContentTypes: [.midi]) { res in
            do {
                fileUrl = try res.get()
                print("---> fileUrl: \(String(describing: fileUrl))")
            } catch{
                print ("error reading: \(error.localizedDescription)")
            }
        }
        Spacer()
    }
}
