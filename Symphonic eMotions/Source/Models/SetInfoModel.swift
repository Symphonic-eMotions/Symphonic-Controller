//
//  SetInfoModel.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 23/02/2023.
//

import SwiftUI

struct SetInfoState {

    let setCollections: Sets
    var currentInstrumentsSet: InstrumentsSet
}

final class SetInfoModel: ObservableObject {
    
    @Binding var setInfoLocalState: SetInfoLocalState
    @Binding var setSettings: SetSettings
    @Published var setInfoState: SetInfoState
    let currentInstrumentsSetIsChanged: (InstrumentsSet) -> ()
    
    init(
        setInfoLocalState: Binding<SetInfoLocalState>,
        setSettings: Binding<SetSettings>,
        setInfoState: SetInfoState,
        currentInstrumentsSetIsChanged: @escaping (InstrumentsSet) -> Void
    ) {
        self._setInfoLocalState = setInfoLocalState
        self._setSettings = setSettings
        self.setInfoState = setInfoState
        self.currentInstrumentsSetIsChanged = currentInstrumentsSetIsChanged
    }
    
    func tapSetRow(selectedCollection: MusicSet) {
        
        let instrumentSet = AppUtils.loadInstrumentSet(json: selectedCollection.config)
        currentInstrumentsSetIsChanged(instrumentSet)
    }
    
    func tapSavedRow(fileName: String) {
        
        let instrumentSet = AppUtils.loadSavedInstrumentSet(fileName: fileName)
        currentInstrumentsSetIsChanged(instrumentSet!)
    }
    
    func filterSet(setName: String) -> MusicSet {
        
        let filtered = setInfoState.setCollections.sets.filter { set in
            return set.name == setName
        }
        
        return filtered.first!
    }
    
}
