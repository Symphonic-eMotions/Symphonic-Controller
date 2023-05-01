//
//  SidebarView.swift
//  SidebarView
//
//  Created by Mihai Fratu on 29.07.2021.
//

import SwiftUI

struct SidebarViewState {
    let currentInstrumentsSetName: String
    let currentInstrumentSet: InstrumentsSet
    let buildSettings: BuildSettings
}

final class SidebarViewModel: ObservableObject {
    
    @Published var state: SidebarViewState
    var currentInstrumentsSetIsChanged: (InstrumentsSet) -> Void
    
    init(
        state: SidebarViewState,
        currentInstrumentsSetIsChanged: @escaping (InstrumentsSet) -> Void
    ) {
        self.state = state
        self.currentInstrumentsSetIsChanged = currentInstrumentsSetIsChanged
    }
}

struct SidebarView: View {
    
    @ObservedObject var viewModel: MainViewModel
    
    @ObservedObject var sidebarViewModel: SidebarViewModel
    
    @EnvironmentObject var fileController: FileController
    
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    
    @Binding public var setInfoLocalState: SetInfoLocalState
    
//    @Binding public var setEditLocalState: SetEditLocalState

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                                
                SidebarSetsView(
                    viewModel: viewModel,
                    sideBarSetsViewModel: SideBarSetsViewModel(
                            state: SideBarSetsViewState(
//                                setCollections: sidebarViewModel.setCollections,
                                currentInstrumentsSetName: sidebarViewModel.state.currentInstrumentsSetName,
                                currentInstrumentSet: sidebarViewModel.state.currentInstrumentSet,
                                buildSettings: sidebarViewModel.state.buildSettings
                            )
                        ),
                    sessionDisplay: $sessionDisplay,
                    sessionDisplaySub: $sessionDisplaySub,
                    setInfoLocalState: $setInfoLocalState

                )
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

/*
struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
    }
}
*/
