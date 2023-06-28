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
