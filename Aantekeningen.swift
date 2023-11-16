//
//  Aantekeningen.swift
//  Symphonic eMotions MVP
//
//  Created by Frans-Jan Wind on 16/11/2023.
//


import SwiftUI


struct SideBarView: View {
    
    @AppStorage(UserDefaultsKeys.isSetPlaying) var isSetPlaying: Bool = false
    
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding var sessionDisplay: SessionDisplay
    @Binding var sessionDisplaySub: SessionDisplay

    init(
        setInfoModel: SetInfoModel
        
    ) {
        self.setInfoModel = setInfoModel
        
    }
    
    var body: some View {
        
        NavigationView {
            List {
                
                ForEach(viewModel.getSetFiles(for: getFileGroup(for: selectedMainItem))) { setFile in
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
            //Defaultnavigation behaviour
            else{
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
