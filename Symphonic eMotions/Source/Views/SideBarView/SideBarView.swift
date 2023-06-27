//
//  SideBarView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 25/04/2023.
//

import SwiftUI

struct SetFile: Identifiable, Decodable, Equatable {
    let id: UUID? = UUID()
    let name: String
    let url: URL
    let published: Bool
    let fileGroup: FileGroup

    private enum CodingKeys: String, CodingKey {
        case name, url, published, fileGroup
    }
}

// This function converts sessionDisplay to fileGroup
func getFileGroup(for session: SessionDisplay) -> FileGroup {
    // This logic should be based on your mapping
    switch session {
    case .pro:
        return .pro
    case .playlists:
        return .none
    case .setInfo:
        return .pro
//    case .swiftUI:
//        return .pro
    case .creator:
        return .template
    case .demo:
        return .demo
    default:
        return .none
    }
}

struct SideBarView: View {

    @EnvironmentObject var fileController: FileController
    @ObservedObject var setInfoModel: SetInfoModel

    @Binding var sessionDisplay: SessionDisplay
    @Binding var sessionDisplaySub: SessionDisplay
    @Binding var setInfoLocalState: SetInfoLocalState
    @Binding var sidebarItems: [(name: String, setName: String, fileGroup: FileGroup, sessionDisplay: SessionDisplay)]
    
    @StateObject private var viewModel = SetListViewModel()
    @State private var selectedSet: SetFile?
    @State private var showingAlert = false
    @State var fileGroup: FileGroup = .none
    
    @State private var selectedMainItem: SessionDisplay = .none

    
    init(
        setInfoModel: SetInfoModel,
        sessionDisplay: Binding<SessionDisplay>,
        sessionDisplaySub: Binding<SessionDisplay>,
        setInfoLocalState: Binding<SetInfoLocalState>,
        sidebarItems: Binding<[(name: String, setName: String, fileGroup: FileGroup, sessionDisplay: SessionDisplay)]>
        
    ) {
        self.setInfoModel = setInfoModel
        _sessionDisplay = sessionDisplay
        _sessionDisplaySub = sessionDisplaySub
        _setInfoLocalState = setInfoLocalState
        _sidebarItems = sidebarItems
        
    }
    
    private func changeFileGroupAndSessionDisplay(_ item: (name: String, setName: String, fileGroup: FileGroup, sessionDisplay: SessionDisplay)) {
        self.fileGroup = item.fileGroup
        self.sessionDisplay = item.sessionDisplay
        setInfoLocalState.sideBarHead = item.name
        setInfoLocalState.setName = item.setName
    }
    
    var body: some View {
        
        NavigationView {
            List {
                ForEach(sidebarItems, id: \.setName) { item in
                    Button(action: {
                        //Editor open?
                        if [.setEditor, .playListEditor].contains(sessionDisplaySub) {
                            self.showingAlert = true
                        } else {
                            //Stop audio
                            setInfoModel.tapStopAudioEngine()
                            //Let the sysem know what files to show
                            changeFileGroupAndSessionDisplay(item)
                            
                            //Playlist and sub
                            if item.sessionDisplay == .playlists {
                                sessionDisplaySub = .playlists
                            }
                            //Home and sub
                            else if item.sessionDisplay == .home {
                                sessionDisplaySub = .page01
                            }
                            //Default
                            else{
                                sessionDisplaySub = sessionDisplay
                            }
                            
                            setInfoModel.setSettings.currentPlaylist = .none
                            
                            selectedMainItem = item.sessionDisplay
                        }
                    }) {
//                        SidebarItemView(item: item, active: setInfoLocalState.setName == item.setName)
                        SidebarItemView(item: item, active: selectedMainItem == item.sessionDisplay)
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("Editor open"), message: Text("Save set to continue"), dismissButton: .default(Text("Will do!")))
                    }
                }
                
                // Show sets within group
//                if [.pro, .setInfo, .swiftUI, .creator, .demo].contains(sessionDisplay) && [.none, .setEditor].contains(sessionDisplaySub) {
                
                let _ = print(sessionDisplaySub)
                
//                if [.pro, .setInfo, .swiftUI, .creator, .demo].contains(sessionDisplay) {
                    
                    
                    
                    ForEach(viewModel.getSetFiles(for: getFileGroup(for: sessionDisplaySub))) { setFile in
                        if setFile.fileGroup == getFileGroup(for: sessionDisplaySub) {
                            SetFileButtonView(
                                setFile: setFile,
                                selectedSet: $selectedSet,
                                sessionDisplay: $sessionDisplay,
                                sessionDisplaySub: $sessionDisplaySub,
                                setInfoLocalState: $setInfoLocalState,
                                setInfoModel: setInfoModel
                            )
                        }
                    }
//                }
            }
            .navigationTitle(setInfoLocalState.sideBarHead)
        }
    }
}

struct SidebarItemView: View {
    let item: (name: String, setName: String, fileGroup: FileGroup, sessionDisplay: SessionDisplay)
    let active: Bool
    
    var body: some View {
        
        
        
        HStack {
            VStack(alignment: .leading) {
                Spacer()
                Text(item.name)
                    .foregroundColor(active ? .white : .primary)
                    .font(.headline)
                    .padding(.horizontal)
                Spacer()
            }
            Spacer()
        }
        .padding(.vertical, 4.0)
        .padding(.leading, 4.0)
        .background(active ? Color.accentColor : .teal)
        .cornerRadius(10.0)
    }
}

struct SetFileButtonView: View {
    let setFile: SetFile
    @Binding var selectedSet: SetFile?
    @Binding var sessionDisplay: SessionDisplay
    @Binding var sessionDisplaySub: SessionDisplay
    @Binding var setInfoLocalState: SetInfoLocalState
    var setInfoModel: SetInfoModel
    var body: some View {
        Button(action: {
            selectedSet = setFile
            setInfoModel.tapStopAudioEngine()
            
            setInfoLocalState.setName = setFile.name
            setInfoLocalState.setConfig = setFile.url.lastPathComponent
            setInfoLocalState.setURL = setFile.url.absoluteString
            
            if sessionDisplay == .pro {
                sessionDisplaySub = .pro
            }
            if sessionDisplay == .creator {
                sessionDisplaySub = .creator
            }
            
            sessionDisplay = .setInfo
            
        }) {
            HStack {
                VStack(alignment: .leading) {
                    Spacer()
                    Text(setFile.name)
                        .foregroundColor(selectedSet == setFile ? .white : .primary)
                        .font(.headline)
                        .padding(.horizontal)
                    Spacer()
                }
                Spacer()
            }
            .padding(.vertical, 4.0)
            .padding(.leading, 4.0)
            .background(selectedSet == setFile ? Color.accentColor : .secondary)
            .cornerRadius(10.0)
        }
    }
}
