//
//  SetListViewModel.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 27/06/2023.
//

import Foundation

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
        return setFiles.filter { $0.fileGroup == group && $0.published == true }
    }
}
