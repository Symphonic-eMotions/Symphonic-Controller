//
//  SideBarFolderView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 25/04/2023.
//

import SwiftUI

struct SetFile: Identifiable, Decodable, Equatable {
    var id = UUID()
    let name: String
    let url: URL
    let published: Bool
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
            
            for fileURL in fileURLs {
                if fileURL.pathExtension == "json" {
                    do {
                        let data = try Data(contentsOf: fileURL)
                        let decodedFile = try decoder.decode(InstrumentsSet.self, from: data)
                        
                        //But only if the set is published
                        if decodedFile.published ?? true {
                            setFiles.append(
                                SetFile(
                                    name: decodedFile.name,
                                    url: fileURL,
                                    published: decodedFile.published ?? true
                                )
                            )
                        }
                    } catch {
                        print("Error decoding JSON file: \(error)")
                    }
                }
            }
        } catch {
            print("Error reading contents of directory: \(error)")
        }
    }
}

struct SideBarFolderView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    @Binding public var setInfoLocalState: SetInfoLocalState
    
    @EnvironmentObject var fileController: FileController
    @Binding var urls: [URL]
    
    
    @StateObject private var viewModel = SetListViewModel()
    @State private var selectedSet: SetFile?
    
    
    //FIXME: select the chosen one
    var isSelected: Bool {
        "false" == setInfoModel.setInfoLocalState.setName
    }
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.setFiles) { setFile in
                    Button(action: {
                        
                        selectedSet = setFile
                        
//                        print("Stop engine")
                        setInfoModel.tapStopAudioEngine()
                        
                        setInfoLocalState.setName = setFile.name
                        setInfoLocalState.setConfig = setFile.url.lastPathComponent
                        sessionDisplay = .setInfo
                        sessionDisplaySub = .none
                        
                        
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Spacer()
                                Text(setFile.name)
                                    .foregroundColor(selectedSet == setFile ? .white : .primary)
                                    .font(.headline)
                                    .padding(.trailing)
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
            .navigationTitle("Sets")
        }
    }
}


