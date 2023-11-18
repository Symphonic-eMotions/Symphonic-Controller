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
    let semVersion: String
    let fileGroup: FileGroup

    private enum CodingKeys: String, CodingKey {
        case name, url, published, semVersion, fileGroup
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
    case .creator:
        return .template
    case .demo:
        return .demo
    default:
        return .none
    }
}

struct SideBarView: View {
    
    @AppStorage(UserDefaultsKeys.isSetPlaying) var isSetPlaying: Bool = false
    
    @EnvironmentObject var fileController: FileController
    @ObservedObject var setInfoModel: SetInfoModel

    @Binding var sessionDisplay: SessionDisplay
    @Binding var sessionDisplaySub: SessionDisplay
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
        sessionDisplaySub: Binding<SessionDisplay>,
        sidebarItems: Binding<[(name: String, setName: String, fileGroup: FileGroup, sessionDisplay: SessionDisplay)]>
        
    ) {
        self.setInfoModel = setInfoModel
        _sessionDisplay = sessionDisplay
        _sessionDisplaySub = sessionDisplaySub
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
    
    var body: some View {
        
        NavigationView {
            List {
                ForEach(sidebarItems, id: \.setName) { item in
                    Button(action: {}) {
                        SidebarItemView(
                            item: item,
                            active: selectedMainItem == item.sessionDisplay,
                            showDisabled: $showDisabled
                        )
                    }
                    .onTapGesture {
                        
                        //Deactivate navigation when sessionDisplaySub in these views
                        if [.setEditor,.playListEditor,.playing].contains(sessionDisplaySub) {
                            AnalyticsAction.sideBarNavigationProductLevelDisabled.logEvent(sessionDisplay: item.sessionDisplay)
                            withAnimation {
                                // Fade to red and back
                                let fadeDur = 0.25
                                withAnimation(.easeInOut(duration: fadeDur)) {
                                    self.showDisabled = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + fadeDur) {
                                    withAnimation(.easeInOut(duration: fadeDur)) {
                                        self.showDisabled = false
                                    }
                                }
                            }
                        }
                        //Default navigation behaviour
                        else {
                            AnalyticsAction.sideBarNavigationProductLevelDisabled.logEvent(sessionDisplay: item.sessionDisplay)
                            selectedMainItem = item.sessionDisplay
                            
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
                            //Pro
                            else if item.sessionDisplay == .pro {
                                sessionDisplaySub = .stopped
                            }
                            //SpriteKit
                            else if item.sessionDisplay == .pro {
                                sessionDisplaySub = .stopped
                            }
                            
                            //Default
                            else{
                                sessionDisplaySub = sessionDisplay
                            }
                            
                            setInfoModel.setSettings.currentPlaylist = .none
                        }
                    }
                }
                
                ForEach(
                    viewModel.getSetFiles(
                        for: getFileGroup(for: selectedMainItem),
                        with: sessionDisplaySub)) { setFile in
                    SetFileButtonView(
                        setFile: setFile,
                        selectedSet: $selectedSet,
                        sessionDisplay: $sessionDisplay,
                        sessionDisplaySub: $sessionDisplaySub,
                        setInfoLocalState: $setInfoModel.setInfoLocalState,
                        setInfoModel: setInfoModel
                    )
                }
            }
            .navigationTitle(setInfoModel.setInfoLocalState.sideBarHead)
        }
        VStack {
            Text(semVersionString()).foregroundColor(.gray)
        }
    }
    
    func semVersionString() -> String {
        var infoString = ""

        if let bundleID = Bundle.main.bundleIdentifier {
            let bundleIDComponents = bundleID.split(separator: ".")
            if let lastComponent = bundleIDComponents.last {
                infoString += "\(lastComponent) "
            }
        }

        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let versionNumber = appVersion.split(separator: " ").last {
            infoString += "\(versionNumber) "
        }

        if let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
           let buildNumberValue = buildNumber.split(separator: " ").last {
            infoString += "(\(buildNumberValue))"
        }

        return infoString
    }
}

struct SidebarItemView: View {
    let item: (name: String, setName: String, fileGroup: FileGroup, sessionDisplay: SessionDisplay)
    let active: Bool
    @Binding var showDisabled: Bool
    
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
        .background(showDisabled ? Color.red.opacity(0.5) : (active ? Color.accentColor : .teal))
        .cornerRadius(10.0)
    }
}

struct SetFileButtonView: View {
    let setFile: SetFile
    @Binding var selectedSet: SetFile?
    @Binding var sessionDisplay: SessionDisplay
    @Binding var sessionDisplaySub: SessionDisplay
    @Binding var setInfoLocalState: SetInfoLocalState
    @State private var showDisabled: Bool = false
    var setInfoModel: SetInfoModel
    var body: some View {
        Button(action: {}) {
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
            .background( showDisabled ? Color.red.opacity(0.5) : (selectedSet == setFile ? Color.accentColor : .secondary))
            .cornerRadius(10.0)
        }
        .onTapGesture {
            
            //Deactivate navigation when sessionDisplaySub in these views
            if [.setEditor,.playListEditor,.playing].contains(sessionDisplaySub) {
                AnalyticsAction.sideBarNavigationSetLevelDisabled.logEvent(sessionDisplay: sessionDisplay, fileGroup: selectedSet?.fileGroup, setName: selectedSet?.name)
                withAnimation {
                    // Fade to red and back
                    let fadeDur = 0.25
                    withAnimation(.easeInOut(duration: fadeDur)) {
                        self.showDisabled = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + fadeDur) {
                        withAnimation(.easeInOut(duration: fadeDur)) {
                            self.showDisabled = false
                        }
                    }
                }
            }
            //Select a set file
            else{
                AnalyticsAction.sideBarNavigationSetLevel.logEvent(sessionDisplay: sessionDisplay, fileGroup: selectedSet?.fileGroup, setName: selectedSet?.name)
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
            }
        }
    }
}
