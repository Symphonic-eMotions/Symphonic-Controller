//
//  PlaylistViewModel.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 27/06/2023.
//

import Foundation
import SwiftUI

class PlaylistViewModel: ObservableObject {
        
    @Published var urls: [URL] = []
    @Published var removeSetUrl: URL?
    @Published var showRemoveConfirmation: Bool = false
    
    var playlist: BuildSettings.Playlists
    
    var sessionDisplay: SessionDisplay
    
    init(
        playlist: BuildSettings.Playlists,
        sessionDisplay: SessionDisplay
    ) {
        self.playlist = playlist
        self.sessionDisplay = sessionDisplay
        loadPlaylistFolder()
    }

    func loadPlaylistFolder() {
        
        let directoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let playListUrl = directoryURL.appendingPathComponent(playlist.rawValue)
        
        do {
            self.urls = try FileManager.default.contentsOfDirectory(at: playListUrl, includingPropertiesForKeys: nil)
        } catch {
            print(error)
            self.urls = []
        }
    }
    
//    func loadPlaylistFolder(view compareView: SessionDisplay) {
//        
//        let fileManager = FileManager.default
//        let directoryURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//        let playListUrl = directoryURL.appendingPathComponent(playlist.rawValue)
//        
//        do {
//            let fileURLs = try fileManager.contentsOfDirectory(at: playListUrl, includingPropertiesForKeys: nil)
//            
//            // Load and decode the JSON files
//            let decoder = JSONDecoder()
//            
//            for url in fileURLs {
//                do {
//                    let data = try Data(contentsOf: url)
//                    let file = try decoder.decode(InstrumentsSet.self, from: data)
//                    //Check if minimun version number is smaller or the same as file version number
//                    let fileVersion = file.semVersion ?? "1.0.0"
//                    let comparison = AppUtils.compareVersions(
//                        version1: comaptibleSemVersion,
//                        version2: fileVersion )
//                    
//                    if [.orderedSame,.orderedAscending].contains(comparison){
//                        if file.published ?? false {  // Check if the file is published
//                            self.urls.append(url)
//                        }
//                    }
//                    
//                    //In creator mode we want to see all old files to modify
//                    else if comparison == .orderedDescending && compareView == .creator {
//                        self.urls.append(url)
//                    }
//                    
//                } catch {
//                    // If there's an error decoding one file, just print the error and continue with the next one
//                    print("Error decoding file at \(url): \(error)")
//                }
//            }
//        } catch {
//            print(error)
//            self.urls = []
//        }
//    }


    func deleteUrl(_ url: URL) {
        if let index = self.urls.firstIndex(of: url) {
            
            self.urls.remove(at: index)
            
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(at: url)
            } catch {
                print("Failed to delete file: \(error.localizedDescription)")
            }
            
        }
    }
}
