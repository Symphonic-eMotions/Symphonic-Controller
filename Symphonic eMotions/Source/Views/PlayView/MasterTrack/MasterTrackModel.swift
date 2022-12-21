//
//  MasterView.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 27/09/2022.
//

import Foundation
import OrderedCollections

struct MasterTrackEffect: Identifiable, Hashable {
    var id: String { effectName }
    var effectName: String
    var parameters: [Parameter]?
}

struct Parameter: Identifiable, Hashable {
    var id: String { name }
    var name: String
    var value: Double
    var range: [Double]
}

struct MasterViewState {
    var currentInstrumentsSet: InstrumentsSet
}

final class MasterViewModel: ObservableObject {
    
    var conductor: Conductor
    @Published var playViewState: PlayViewState
    
    init(
        playViewState: PlayViewState,
        conductor: Conductor
    ) {
        self.playViewState = playViewState
        self.conductor = conductor
    }
}
