//
//  DebugView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 01/07/2023.
//

import SwiftUI

struct DebugView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    @State var trackId: String

    //Binding
    @Binding var trackLevels: [String: [Int]]
    @Binding var noteNumbersLevels: [String: [Int]]
    @Binding var noteNumbersClips: [String: [Int]]
    @Binding var noteNumbers: [String: [Int]]
    
    var body: some View {
        
        if let array = noteNumbersClips[trackId] {
            Text(array.map(String.init).joined(separator: ", "))
        } else {
            Text("No values for key: \(trackId)")
        }
        
        
    }
}
