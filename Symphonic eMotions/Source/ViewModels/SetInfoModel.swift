//
//  SetInfoModel.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 23/02/2023.
//

import SwiftUI
import OrderedCollections

struct SetInfoState {
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
    
    func addTrack() -> TrackSettings? {
        
        //New track
        var trackId = "New track \(self.setSettings.tracks.count + 1)"
        var nameExists = true
        var counter = 0
        while nameExists {
            if let _ = self.setSettings.tracks[trackId] {
                // Track name already exists, modify the trackId
                counter += 1
                trackId = "New track \(self.setSettings.tracks.count + counter)"
            } else {
                // Track name doesn't exist, break the loop
                nameExists = false
            }
        }
        
        //New part
        let partId: String = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        //Amount of cells in grid
        let cells = self.setSettings.gridRows * self.setSettings.gridColumns
        //Defaut midi note number
        let noteNumber: Int = 48
        
        //New nodeSetting
        let newNodeSetting = InstrumentsSet.Track.Part.DamperTarget.NodeSettings(
            minimalLevel: 0.1,
            rampSpeed: 0.15,
            rampSpeedDown: 0.14
        )
        
        //New damperTarget
        let newDamperTarget = InstrumentsSet.Track.Part.DamperTarget(
            trackId: trackId,
            nodeType: .sequencer,
            nodeName: "",
            parameter: "velocity",
            parameterRange: [0,1],
            midiData: nil,
            nodeSettings: newNodeSetting,
            dampMode: .easeInCubic
        )
        
        //Calculate number of cells and create new Part
        let newPart = PartSettings(
            partId: partId,
            partName: "Velocity",
            partNumber: 1,
            rampUp: newNodeSetting.rampSpeed!,
            rampDown: newNodeSetting.rampSpeedDown!,
            minimalLevel: newNodeSetting.minimalLevel!,
            areaOfInterest: Array(repeating: 1, count: cells),
            areaOfInterestColor: Array(repeating: Color("InstrumentColor000"), count: cells),
            damperTarget: newDamperTarget,
            dontDrawVisual: false
        )
        
        //Create new Track
        let newTrack = TrackSettings(
            trackId: trackId,
            trackIndex: 0,
            trackName: trackId,
            noteSource: .noteNumbers,
            startType: .oneShot,
            variationType: .variationByPosition,
            instrumentType: .audioBuffer,
            exsFile: ExsFiles(rawValue: "trigger")!,
            audioFiles: [],
            instrumentVolume: 0,
            instrumentColor: Color("InstrumentColor000"),
            midiFile: "trigger",
            midiGroup: [noteNumber],
            notesToGrid: Array(repeating: noteNumber, count: cells),
            notesToGridMapped: AppUtils.areaOfInterestGridMapped(
                areaOfInterest: Array(repeating: 1, count: cells),
                cellsToGrid: Array(repeating: noteNumber, count: cells)
            ),
            notesToLevel: Array(repeating: noteNumber, count: self.setSettings.levels.count),
            notesSequenceType: .nextForward,
            loopLength: [16],
            loopsToLevel: [],
            loopsToGrid: [],
            loopsToGridMapped: [],
            levels: (0...self.setSettings.levels.count-1).map { $0 },
            parts: [partId: newPart]
        )
        
        return newTrack
    }
    
    func addVelocityPart(velocitySensitive: Bool, trackId: String) -> PartSettings? {
        
        var returnPart: PartSettings?
        
        let numberOfParts = self.setSettings.tracks[trackId]?.parts.count ?? 0
        
        if velocitySensitive {
            
            //add velocity part
            let partId: String = UUID().uuidString.replacingOccurrences(of: "-", with: "")
            
            let newNodeSetting = InstrumentsSet.Track.Part.DamperTarget.NodeSettings(
                minimalLevel: 0.1,
                rampSpeed: 0.15,
                rampSpeedDown: 0.14
            )
            
            let newDamperTarget = InstrumentsSet.Track.Part.DamperTarget(
                trackId: trackId,
                nodeType: .sequencer,
                nodeName: "",
                parameter: "velocity",
                parameterRange: [0,1],
                midiData: nil,
                nodeSettings: newNodeSetting,
                dampMode: .easeInCubic
            )
            
            let cells = self.setSettings.gridRows * self.setSettings.gridColumns
            
            let newPart = PartSettings(
                partId: partId,
                partName: "Velocity",
                partNumber: numberOfParts + 1,
                rampUp: newNodeSetting.rampSpeed!,
                rampDown: newNodeSetting.rampSpeedDown!,
                minimalLevel: newNodeSetting.minimalLevel!,
                areaOfInterest: Array(repeating: 1, count: cells),
                areaOfInterestColor: Array(repeating: Color("InstrumentColor000"), count: cells),
                damperTarget: newDamperTarget,
                dontDrawVisual: false
            )
            
            returnPart = newPart
        }
        //
//        else{
//            
//            if numberOfParts > 1 {
//                
//                if let track = self.setSettings.tracks[trackId] {
//                    
//                    var updatedParts = OrderedDictionary<String, PartSettings>()
//                    for (partId, part) in track.parts {
//                        if part.damperTarget.parameter != "velocity" {
//                            updatedParts[partId] = part
//                        }
//                    }
//                    self.setSettings.tracks[trackId]?.parts = updatedParts
//                }
//            }
//        }
        
        return returnPart
    }
    
    func trackNames() -> [String: String] {
        var trackNames: [String: String] = [:]
        for track in setSettings.tracks {
            //translate EditorPart track name by its enum case (i.e. track15)
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
    
//    func loadMidiFile(midiFile: URL, trackId: String){
//        self.conductor.trackSequencers[trackId]?.loadMIDIFile(fromURL: midiFile)
//    }
}
