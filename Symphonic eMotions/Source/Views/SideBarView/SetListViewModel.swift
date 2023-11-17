//
//  SetListViewModel.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 27/06/2023.
//

import Foundation
import SwiftUI

class SetListViewModel: ObservableObject {
    
    @AppStorage(UserDefaultsKeys.comaptibleSemVersion) var comaptibleSemVersion: String = "2.7.0"
    
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
            
        } catch {
            print("Error reading contents of directory: \(error)")
        }
    }
    
    func getSetFiles(for group: FileGroup, with comapareView: SessionDisplay) -> [SetFile] {
        
        return setFiles.filter { setFile in
            
            // Check if the file belongs to the specified group
            let isPartOfGroup = setFile.fileGroup == group

            // Check if the file is published
            let isPublished = setFile.published
            
            //Check if file is new enough for app version
            let comparison = AppUtils.compareVersions(version1: comaptibleSemVersion, version2: setFile.semVersion)
            
            //In creator mode we want to see all old files to modify
            var isOldVersionInCreator: Bool = false;
            if comparison == .orderedDescending && comapareView == .creator {
                isOldVersionInCreator = true
            }
            
            // Print for debugging
            print("comaptibleSemVersion \(comaptibleSemVersion) fileVersion \(setFile.semVersion) => \(comparison)")
            
            // Return true if both conditions are met
            return ((isPartOfGroup && isPublished && [.orderedSame,.orderedAscending].contains(comparison)) || isOldVersionInCreator)
        }
    }
}
