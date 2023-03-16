//
//  EditorView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 14/03/2023.
//

import SwiftUI

struct SetEditLocalState {
    var setName: String
    var setConfig: String
    
    
    init(){
        self.setName = ""
        self.setConfig = ""
    }
}

struct SetEditState {

    let setCollections: Sets
}

final class SetEditModel: ObservableObject {
    
    @Binding var setEditLocalState: SetEditLocalState
    @Published var setEditState: SetEditState
    let currentInstrumentsSetIsChanged: (InstrumentsSet) -> ()
    
    init(
        setEditLocalState: Binding<SetEditLocalState>,
        setEditState: SetEditState,
        currentInstrumentsSetIsChanged: @escaping (InstrumentsSet) -> Void
    ) {
        self._setEditLocalState = setEditLocalState
        self.setEditState = setEditState
        self.currentInstrumentsSetIsChanged = currentInstrumentsSetIsChanged
    }
}

struct EditorView: View {
    
    @ObservedObject var setEditModel: SetEditModel
    @Binding public var sessionDisplay: SessionDisplay
    
    var body: some View {
        Spacer()
        Text("Editor for \(setEditModel.setEditLocalState.setName)")
            .font(.largeTitle)
            .fontWeight(.regular)
        Text("Load default set\nShow list of saves")
        Spacer()
        FilePickerView()
        Spacer()
    }
}
