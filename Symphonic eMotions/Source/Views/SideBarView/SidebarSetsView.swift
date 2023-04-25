//
//  SidebarSetsView.swift
//  Symphonic eMotions
//
//  Created by Çağatay Emekci on 17.03.2022.
//

import SwiftUI

struct SideBarSetsViewState {
//    let setCollections: Sets
    let currentInstrumentsSetName: String
    let currentInstrumentSet: InstrumentsSet
    var buildSettings: BuildSettings
}

class SideBarSetsViewModel: ObservableObject {
    
    @Published var state: SideBarSetsViewState
//    let rowSelected: (InstrumentsSet) -> ()
    
    init(
        state: SideBarSetsViewState
//        ,
//        rowSelected: @escaping (InstrumentsSet) -> ()
    ) {
        self.state = state
//        self.rowSelected = rowSelected
    }
    
    func currentSetInfoChanged(selectedCollection: MusicSet) -> MusicSet {
        
        return selectedCollection
    }
    
//    func tapSetRow(selectedCollection: MusicSet) {
//        if selectedCollection.name != state.currentInstrumentsSetName{
//            
//            let instrumentSet = AppUtils.loadInstrumentSet(json: selectedCollection.config)
//            rowSelected(instrumentSet)
//        }
//    }
    
    func tapSavedRow(fileName: String) {
        
//        let instrumentSet = AppUtils.loadSavedInstrumentSet(fileName: fileName)
//        rowSelected(instrumentSet!)
    }
}

struct SidebarSetsView: View {
    
    @ObservedObject var viewModel: MainViewModel
    
    @ObservedObject var sideBarSetsViewModel: SideBarSetsViewModel
    
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    
    @Binding public var setInfoLocalState: SetInfoLocalState
    
//    @Binding public var setEditLocalState: SetEditLocalState
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text(setInfoLocalState.sideBarHead)
                .font(.largeTitle)
                .onTapGesture {
                    sessionDisplay = .home
                    setInfoLocalState.setName = "home"
                    setInfoLocalState.sideBarHead = "Sets"
                }
                
//            ForEach(sideBarSetsViewModel.state.setCollections.sets, id: \.self) { setCollection in
//                
//                SidebarSetCollectionView(
//                    setCollection: setCollection,
//                    setInfoLocalState: $setInfoLocalState
//                ).onTapGesture {
//                    
//                    viewModel.tapStopAudioEngine()
//                    
//                    //Loading for setInfoView
//                    let set = sideBarSetsViewModel.currentSetInfoChanged(selectedCollection: setCollection)
//                    setInfoLocalState.setName = set.name
//                    setInfoLocalState.setConfig = set.config
//                    sessionDisplay = .setInfo
//                    sessionDisplaySub = .none
//                }
//            }
        }
    }
}

struct SidebarSetCollectionView: View {
    
    let setCollection: MusicSet
    @Binding public var setInfoLocalState: SetInfoLocalState
    
    var isSelected: Bool {
        setInfoLocalState.setName == setCollection.name
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Spacer()
                Text(setCollection.name)
                    .foregroundColor(isSelected ? .white : .primary)
                    .font(.headline)
                    .padding(.trailing)
                Spacer()
            }
            Spacer()
        }
        .padding(.vertical, 4.0)
        .padding(.leading, 4.0)
        .background(isSelected ? Color.accentColor : .secondary)
        .cornerRadius(10.0)
    }
}

struct ReloadSetButtton: View {
    
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "arrow.clockwise.circle")
                    .frame(width: 24.0, height: 24.0)
                    .background(RoundedRectangle(cornerRadius: 4.0).fill(Color.accentColor.opacity(0)))
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
    }
}
