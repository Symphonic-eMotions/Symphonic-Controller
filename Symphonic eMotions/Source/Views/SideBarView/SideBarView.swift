//
//  SideBarView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 25/04/2023.
//

import SwiftUI

struct SideBarView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var fileController: FileController
    @ObservedObject var setInfoModel: SetInfoModel

    @Binding var sessionDisplay: SessionDisplay
    @Binding var sidebarItems: [(name: String, setName: String, fileGroup: FileGroup, sessionDisplay: SessionDisplay)]
    
    @StateObject private var viewModel = SetListViewModel()
    @State private var selectedSet: SetFile?
    @State private var showingAlert = false
    @State var fileGroup: FileGroup = .none
    
    @State private var selectedMainItem: SessionDisplay = .none
    @State private var showDisabled: Bool = false
    
    init(
        setInfoModel: SetInfoModel,
        sessionDisplay: Binding<SessionDisplay>,
        sidebarItems: Binding<[(name: String, setName: String, fileGroup: FileGroup, sessionDisplay: SessionDisplay)]>
        
    ) {
        self.setInfoModel = setInfoModel
        _sessionDisplay = sessionDisplay
        _sidebarItems = sidebarItems
        
    }
    
    //Connection between the current view and the files type connected to tham
    private func changeFileGroupAndSessionDisplay(
        _ item: (name: String, setName: String, fileGroup: FileGroup, sessionDisplay: SessionDisplay)
    ) {
        self.fileGroup = item.fileGroup
        self.sessionDisplay = item.sessionDisplay
        //Show difference also in the side bar header
        setInfoModel.setInfoLocalState.sideBarHead = item.name
        setInfoModel.setInfoLocalState.setName = item.setName
    }
    
    // This function converts sessionDisplay to fileGroup
    // This, what files to show on what navigation item
    private func getFileGroup(for session: SessionDisplay) -> FileGroup {
        switch session {
        case .pro:
            return .pro
        case .playlists:
            return .none
        case .creator:
            return .template
        case .demo:
            return .demo
        default:
            return .none
        }
    }
    
    var body: some View {
        
        NavigationView {
            List {
                //Main menu itemms
                ForEach(sidebarItems, id: \.setName) { item in
                    Button(action: {}) {
                        SidebarItemView(
                            item: item,
                            active: selectedMainItem == item.sessionDisplay,
                            showDisabled: $showDisabled
                        )
                    }
                    .onTapGesture {

                        userSettings.isCapturingRunning = false
                        
                        selectedMainItem = item.sessionDisplay
                        
                        //Let the sysem know what files to show
                        changeFileGroupAndSessionDisplay(item)
                        
                        setInfoModel.setSettings.currentPlaylist = .none
                    }
                }
                
                //Set items
                ForEach(
                    viewModel.getSetFiles(
                        for: getFileGroup(for: selectedMainItem), with: .pro
                    )
                ) { setFile in
                    SetFileButtonView(
                        setFile: setFile,
                        selectedSet: $selectedSet,
                        sessionDisplay: $sessionDisplay,
                        setInfoLocalState: $setInfoModel.setInfoLocalState,
                        setInfoModel: setInfoModel
                    )
                }
            }
            .navigationTitle(setInfoModel.setInfoLocalState.sideBarHead)
        }
        VStack {
            Text(AppUtils.semVersionString()).foregroundColor(.gray)
        }
    }
}




