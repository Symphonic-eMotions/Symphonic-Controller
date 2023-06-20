//
//  StartTypeView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 18/04/2023.
//

import SwiftUI

struct StartTypeView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    var trackId: String
    
    //Bindings
    
    @Binding var showEditorPart: EditorParts
    @Binding var startTypes: [String: StartType]
    
    //State
    @State var startType: StartType
    
    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        showEditorPart: Binding<EditorParts>,
        startTypes: Binding<[String: StartType]>
    ) {
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _showEditorPart = showEditorPart
        _startTypes = startTypes
        _startType = State(initialValue: startTypes[trackId].wrappedValue!)
    }
    
    let columnWidth: CGFloat = 150
    let color: Color = .accentColor
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            Divider()
            
            HStack(){
                
                ZStack {
                    
                    Rectangle()
                        .frame(width: 130, height: 34)
                        .foregroundColor(.clear)
                        .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                        .background( showEditorPart == .sound ? .clear : color )
                    
                    Text("Start type")
                        .frame(width: 130, height: 34)
                    
                }
                .frame(width: columnWidth, alignment: .leading)
                .onTapGesture {
                    withAnimation {
                        showEditorPart = .start
                    }
                }
                
                Picker("Select starting type", selection: $startType) {
                    ForEach(StartType.allCases, id: \.self) { type in
                        Text(type.description).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: startType) { type in
                    withAnimation {
                        
                        //Store to file
                        currentTrack.startType = type
                        //Bindings
                        startTypes[trackId] = type
                        //State
                        startType = type
                    }
                }
            }
        }
        .padding(.leading)
        .padding(.trailing)
    }
}
