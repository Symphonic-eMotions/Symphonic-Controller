//
//  PlaylistViewModel.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 27/06/2023.
//

import Foundation

class PlaylistViewModel: ObservableObject {
    
    @Published var urls: [URL] = []
    @Published var removeSetUrl: URL?
    @Published var showRemoveConfirmation: Bool = false
    
    var playlist: BuildSettings.Playlists

    init(playlist: BuildSettings.Playlists) {
        self.playlist = playlist
        loadPlaylistFolder()
    }

//    func loadPlaylistFolder() {
//        
//        let directoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//        let playListUrl = directoryURL.appendingPathComponent(playlist.rawValue)
//        
//        do {
//            self.urls = try FileManager.default.contentsOfDirectory(at: playListUrl, includingPropertiesForKeys: nil)
//        } catch {
//            print(error)
//            self.urls = []
//        }
//    }
    
    func loadPlaylistFolder() {
        let fileManager = FileManager.default
        let directoryURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let playListUrl = directoryURL.appendingPathComponent(playlist.rawValue)
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: playListUrl, includingPropertiesForKeys: nil)
            
            // Load and decode the JSON files
            let decoder = JSONDecoder()
            
            for url in fileURLs {
                do {
                    let data = try Data(contentsOf: url)
                    let file = try decoder.decode(InstrumentsSet.self, from: data)
                    if file.published ?? false {  // Check if the file is published
                        self.urls.append(url)
                    }
                } catch {
                    // If there's an error decoding one file, just print the error and continue with the next one
                    print("Error decoding file at \(url): \(error)")
                }
            }
        } catch {
            print(error)
            self.urls = []
        }
    }


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
