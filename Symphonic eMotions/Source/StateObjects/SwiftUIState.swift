//
//  SwiftUIState.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 23/02/2023.
//

import Foundation

class SwiftUIState: ObservableObject {
    
    //Show master track
    public var isMasterTrack: Bool
    //What camera view
    public var displayMode: DisplayModes
    
    init(
        isMasterTrack: Bool,
        displayMode: DisplayModes
    ){
        self.isMasterTrack = isMasterTrack
        self.displayMode = displayMode
    }
}
