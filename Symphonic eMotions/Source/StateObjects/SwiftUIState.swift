//
//  SwiftUIState.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 23/02/2023.
//

import Foundation

class SwiftUIState: ObservableObject {
    
    //Show settings
    public var isAdvanced: Bool
    //Show visual feedback per part
    public var instrumentPartEditor: Bool
    //Show master track
    public var isMasterTrack: Bool
    //What camera view
    public var displayMode: DisplayModes
    
    init(
        isAdvanced: Bool,
        instrumentPartEditor: Bool,
        isMasterTrack: Bool,
        displayMode: DisplayModes
    ){
        self.isAdvanced = isAdvanced
        self.instrumentPartEditor = instrumentPartEditor
        self.isMasterTrack = isMasterTrack
        self.displayMode = displayMode
    }
}
