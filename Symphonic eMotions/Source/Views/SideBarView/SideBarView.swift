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

class SetListViewModel: ObservableObject {
    @Published var setFiles: [SetFile] = []
    
    init() {
        loadSetFiles()
    }
    
    func loadSetFiles() {
        guard let url = Bundle.main.url(forResource: "Sets", withExtension: nil) else {
            print("Failed to find Sets folder")
            return
        }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            let decoder = JSONDecoder()
            
            var unsortedSetFiles: [SetFile] = []
            
            for fileURL in fileURLs where fileURL.pathExtension == "json" {
                do {
                    let data = try Data(contentsOf: fileURL)
                    let decodedFile = try decoder.decode(InstrumentsSet.self, from: data)
                    
                    unsortedSetFiles.append(SetFile(name: decodedFile.name, url: fileURL, published: decodedFile.published ?? true, fileGroup: decodedFile.fileGroup ?? .none))
                } catch {
                    print("Error decoding JSON file: \(fileURL) \(error)")
                }
            }
            
            setFiles = unsortedSetFiles.sorted { $0.name < $1.name }
            
        } catch {
            print("Error reading contents of directory: \(error)")
        }
    }
    
    func getSetFiles(for group: FileGroup) -> [SetFile] {
        return setFiles.filter { $0.fileGroup == group }
    }
}

struct SideBarView: View {
    @EnvironmentObject var fileController: FileController
    @ObservedObject var setInfoModel: SetInfoModel
    
    @Binding var sessionDisplay: SessionDisplay
    @Binding var sessionDisplaySub: SessionDisplay
    @Binding var setInfoLocalState: SetInfoLocalState
    
    @StateObject private var viewModel = SetListViewModel()
    @State private var selectedSet: SetFile?
    @State private var showingAlert = false
    @State var fileGroup: FileGroup = .none
    
    let sidebarItems = [
        (name: "Home", setName: "home", fileGroup: FileGroup.home, sessionDisplay: SessionDisplay.home),
        (name: "Demo", setName: "demo", fileGroup: FileGroup.demo, sessionDisplay: SessionDisplay.demo),
        (name: "Active", setName: "playlists", fileGroup: FileGroup.playlists, sessionDisplay: SessionDisplay.playlists),
        (name: "Pro", setName: "pro", fileGroup: FileGroup.pro, sessionDisplay: SessionDisplay.pro),
        (name: "Creator", setName: "creator", fileGroup: FileGroup.template, sessionDisplay: SessionDisplay.creator)
    ]
    
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
                        if [.setEditor, .playListEditor].contains(sessionDisplaySub) {
                            self.showingAlert = true
                        } else {
                            setInfoModel.tapStopAudioEngine()
                            changeFileGroupAndSessionDisplay(item)                            
                            if item.sessionDisplay == .playlists {
                                sessionDisplaySub = .playlists
                            }
                            else if item.sessionDisplay == .home {
                                sessionDisplaySub = .page01
                            }
                            else{
                                sessionDisplaySub = .none
                            }
                            setInfoModel.setSettings.currentPlaylist = .none
                        }
                    }) {
                        SidebarItemView(item: item, active: setInfoLocalState.setName == item.setName)
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("Editor open"), message: Text("Save set to continue"), dismissButton: .default(Text("Will do!")))
                    }
                }
                
                //Show sets within group
                if [.pro,.setInfo,.swiftUI,.creator,.demo].contains(sessionDisplay) && [.none,.setEditor].contains(sessionDisplaySub) {
                    ForEach(viewModel.getSetFiles(for: fileGroup)) { setFile in
                        if setFile.fileGroup == fileGroup {
                            SetFileButtonView(setFile: setFile, selectedSet: $selectedSet, sessionDisplay: $sessionDisplay, sessionDisplaySub: $sessionDisplaySub, setInfoLocalState: $setInfoLocalState, setInfoModel: setInfoModel)
                        }
                    }
                }
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
            
            sessionDisplay = .setInfo
            sessionDisplaySub = .none
            
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
