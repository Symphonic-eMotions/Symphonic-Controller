//
//  SetListViewModel.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 27/06/2023.
//

import Foundation
import SwiftUI

class SetListViewModel: ObservableObject {
    
    @Published var setFiles: [SetFile] = []
    
    lazy private var fileCache: FileCache = {
        FileCache(setFiles: setFiles)
    }()
    
    init() {
        loadSetFiles()
    }
    
    func invalidateCache() {
        fileCache.invalidateCache()
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
                    
                    unsortedSetFiles.append(
                        SetFile(
                            name: decodedFile.name,
                            url: fileURL,
                            published: decodedFile.published ?? true, 
                            semVersion: decodedFile.semVersion ?? "1.0.0",
                            fileGroup: decodedFile.fileGroup ?? .none
                        )
                    )
                } catch {
                    print("Error decoding JSON file: \(fileURL) \(error)")
                }
            }
            
            setFiles = unsortedSetFiles.sorted { $0.name < $1.name }
            fileCache = FileCache(setFiles: setFiles)

            
        } catch {
            print("Error reading contents of directory: \(error)")
        }
    }
    
    func getSetFiles(for group: FileGroup, with compareView: SessionDisplay) -> [SetFile] {
        return fileCache.getSetFiles(for: group, with: compareView)
    }
}
