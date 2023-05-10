//
//  AddToPlaylistView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 08/05/2023.
//

import SwiftUI

struct AddToPlaylistView: View{
    
    @Binding var isPresented: Bool
    @Binding var sandBoxUrl: URL

    var body: some View {
        
        VStack {
            
            Text(NSLocalizedString("Add to playlist", comment: "String"))
                .font(.largeTitle)
            
            let lists = BuildSettings.Playlists.allCases
            let partOfList = lists.filter({$0 != .none})
            
            ForEach(partOfList, id: \.self) { playlist in
                
                EMButton(action: {
                    
                    let to = sandBoxUrl.deletingLastPathComponent()
                        .appendingPathComponent(playlist.rawValue)
                        .appendingPathComponent(sandBoxUrl.lastPathComponent)
                    
                    do {
                        try AppUtils.copyOverwriteFile(from:sandBoxUrl, to: to)
                        print("Added to playlist")
                    } catch {
                        print("Error adding to playlist: \(error)")
                        print(to)
                    }
                    dismiss()
                    
                }, color: .blue, isSolid: true, maxWidth: 250, height: 35
                ){
                    Text(NSLocalizedString(playlist.rawValue, comment: "This is the name of the playlist"))
                }
            }
            .padding()
            
            EMButton(
                action: {
                    dismiss()
                }, color: .orange, isSolid: true, maxWidth: 150, height: 35
            ){
                Text(NSLocalizedString("Cancel", comment: ""))
            }
            .frame(width: 150, height: 50)
        }
    }

    private func dismiss() {
        isPresented = false
    }
}
