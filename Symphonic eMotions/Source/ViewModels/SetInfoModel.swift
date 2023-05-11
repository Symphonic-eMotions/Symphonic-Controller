//
//  SetInfoModel.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 23/02/2023.
//

import SwiftUI

struct SetInfoState {

//    let setCollections: Sets
    var currentInstrumentsSet: InstrumentsSet
}

final class SetInfoModel: ObservableObject {
    
    @Binding var setInfoLocalState: SetInfoLocalState
    @Binding var setSettings: SetSettings
    @Published var setInfoState: SetInfoState
    let currentInstrumentsSetIsChanged: (InstrumentsSet) -> ()
    var conductor: Conductor
    
    init(
        setInfoLocalState: Binding<SetInfoLocalState>,
        setSettings: Binding<SetSettings>,
        setInfoState: SetInfoState,
        currentInstrumentsSetIsChanged: @escaping (InstrumentsSet) -> Void,
        conductor: Conductor
    ) {
        self._setInfoLocalState = setInfoLocalState
        self._setSettings = setSettings
        self.setInfoState = setInfoState
        self.currentInstrumentsSetIsChanged = currentInstrumentsSetIsChanged
        self.conductor = conductor
    }
    
    
    func selectableEditorParts() -> [EditorParts] {
        var selectableEditorParts: [EditorParts] = [.none,.set,.levels,.source,.start,.variation,.location]
        
        for track in setSettings.tracks {
            let trackIndex = track.value.trackIndex
            let enumFromString = EditorParts(rawValue: "track\(trackIndex)")
            selectableEditorParts.append(enumFromString ?? .none)
        }
        
        return selectableEditorParts
    }
    
    func trackNames() -> [String: String] {
        var trackNames: [String: String] = [:]
        for track in setSettings.tracks {
            trackNames["track\(track.value.trackIndex)"] = track.value.trackName
        }
        return trackNames
    }
    
    func tapSetRow(filePath: String) {
        
        let instrumentSet = AppUtils.loadInstrumentSet(json: filePath)
        currentInstrumentsSetIsChanged(instrumentSet)
    }
    
    func tapSavedRow(fileName: String) {
                
        let instrumentSet = AppUtils.loadSavedInstrumentSet(fileName: fileName)
        currentInstrumentsSetIsChanged(instrumentSet!)
    }
    
    func tapStopAudioEngine(){
        conductor.pauzeEngineAndStopTracks(setSettings: self.setSettings)
    }
    
    func tapSetTempoBPMPlus(){
        self.setSettings.bpm -= 1
    }
    
    func tapSetTempoBPMMin(){
        self.setSettings.bpm += 1
    }
}
