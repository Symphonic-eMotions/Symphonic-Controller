//
//  SoundSourceView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 15/06/2023.
//

import SwiftUI

struct SoundSourceView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    var trackId: String
    
    //Bindings
    @Binding var showEditorPart: EditorParts
    @Binding var soundSources: [String: InstrumentsSet.Track.InstrumentType]
    
    //States
    @State var soundSource: InstrumentsSet.Track.InstrumentType
    
    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        showEditorPart: Binding<EditorParts>,
        soundSources: Binding<[String : InstrumentsSet.Track.InstrumentType]>
    ) {
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _showEditorPart = showEditorPart
        _soundSources = soundSources
        _soundSource = State(initialValue: soundSources[trackId].wrappedValue ?? .exsSampler)
    }
    
    let columnWidth: CGFloat = 150
    let color: Color = .accentColor
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            Divider()
            
            HStack(){
                
                ZStack {
                    
                    Rectangle()
                        .frame(width: 120, height: 34)
                        .foregroundColor(.clear)
                        .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                        .background( showEditorPart == .sound ? .clear : color )
                    
                    Text("Sound source")
                        .frame(width: 120, height: 34)
                    
                }
                .frame(width: columnWidth, alignment: .leading)
                .onTapGesture {
                    withAnimation {
                        showEditorPart = .sound
                    }
                }
                
                Picker("Select source of sound", selection: $soundSource) {
                    ForEach(InstrumentsSet.Track.InstrumentType.allCases, id: \.self) { type in
                        Text(type.description).tag(type)
                    }
                }
                .pickerStyle(.inline)
                .frame(height: 100)
                .onChange(of: soundSource) { type in
                    withAnimation {
                        //Store to file
                        currentTrack.instrumentType = type
                        //Binding
                        soundSources[trackId] = type
                        //State
                        soundSource = type
                    }
                }
            }
        }
        .padding(.leading)
        .padding(.trailing)
    }
}
