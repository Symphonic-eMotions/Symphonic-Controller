//
//  SideBarView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 25/04/2023.
//

import SwiftUI

struct SetFile: Identifiable, Decodable, Equatable {
    var id = UUID()
    var name: String = ""
    var url: URL = URL("SetFile")
    var published: Bool = false
    
//    init(name: String, url: URL){
//        self.name = name
//        self.url = url
//    }
}

class SetListViewModel: ObservableObject {
    
    @Published var setFiles: [SetFile] = []
    
    init() {
        loadSetFiles()
    }
    
    //Load json files from Sets folder in Bundle
    func loadSetFiles() {
        guard let url = Bundle.main.url(forResource: "Sets", withExtension: nil) else {
            print("Failed to find Sets folder")
            return
        }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            let decoder = JSONDecoder()
            
            var unsortedSetFiles: [SetFile] = []
            
            for fileURL in fileURLs {
                if fileURL.pathExtension == "json" {
                    do {
                        let data = try Data(contentsOf: fileURL)
                        let decodedFile = try decoder.decode(InstrumentsSet.self, from: data)
                        
                        //But only if the set is published
                        if decodedFile.published ?? true {
                            unsortedSetFiles.append(
                                SetFile(
                                    name: decodedFile.name,
                                    url: fileURL,
                                    published: decodedFile.published ?? true
                                )
                            )
                        }
                    } catch {
                        print("Error decoding JSON file: \(fileURL) \(error)")
                    }
                }
            }
            
            // Sort unsortedSetFiles based on the name field
            let sortedSetFiles = unsortedSetFiles.sorted { $0.name < $1.name }
            
            // Append sorted set files to setFiles
            setFiles.append(contentsOf: sortedSetFiles)
            
        } catch {
            print("Error reading contents of directory: \(error)")
        }
    }
}

struct SideBarView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    @Binding public var setInfoLocalState: SetInfoLocalState
    
    @EnvironmentObject var fileController: FileController
    
    @StateObject private var viewModel = SetListViewModel()
    @State private var selectedSet: SetFile?
    
//    var isSelected: Bool {
//        "false" == setInfoModel.setInfoLocalState.setName
//    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach([
                    (name: "Playlists", setName: "playlists"),
                    (name: "SeM Pro", setName: "home")
                ], id: \.setName) { item in
                    Button(action: {
                        
                        if item.setName == "home" {
                            sessionDisplay = .home
                            sessionDisplaySub = .none
                            //We do not want to go to the next set
                            setInfoModel.setSettings.currentPlaylist = .none
                        }
                        else{
                            sessionDisplay = .playlists
                            sessionDisplaySub = .playlists
                        }
                        
                        setInfoLocalState.setName = item.setName
                        setInfoLocalState.sideBarHead = item.name
                        
                        selectedSet = SetFile(name: item.name, url: URL(item.setName), published: false)
                        setInfoModel.tapStopAudioEngine()
                        
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Spacer()
                                Text(item.name)
                                    .foregroundColor(setInfoLocalState.setName == item.setName ? .white : .primary)
                                    .font(.headline)
                                    .padding(.trailing)
                                    .padding(.leading)
                                Spacer()
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4.0)
                        .padding(.leading, 4.0)
                        .background(setInfoLocalState.setName == item.setName ? Color.accentColor : .teal)
                        .cornerRadius(10.0)
                    }
                }
                
                if sessionDisplay != .playlists && sessionDisplaySub != .playlists {
                    ForEach(viewModel.setFiles) { setFile in
                        Button(action: {
                            
                            selectedSet = setFile
                            setInfoModel.tapStopAudioEngine()
                            
                            setInfoLocalState.setName = setFile.name
                            setInfoLocalState.setConfig = setFile.url.lastPathComponent
                            setInfoLocalState.setURL = setFile.url.absoluteString
                            
                            sessionDisplay = .setInfo
                            sessionDisplaySub = .none
                            
                            setInfoLocalState.sideBarHead = "SeM Pro"
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Spacer()
                                    Text(setFile.name)
                                        .foregroundColor(selectedSet == setFile ? .white : .primary)
                                        .font(.headline)
                                        .padding(.trailing)
                                        .padding(.leading)
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
            }
            .navigationTitle(setInfoLocalState.sideBarHead)
        }
    }
}


