//
//  PlayListsView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 04/05/2023.
//

import SwiftUI



struct PlayListsView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    @EnvironmentObject var fileController: FileController

    var body: some View {
        
//        VStack(spacing: 10) {
        HStack(spacing: 10) {
            playlistView(for: BuildSettings.Playlists.minimal)
            playlistView(for: BuildSettings.Playlists.person)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        //Other playlists
//            HStack(spacing: 10) {
//                playlistView(for: BuildSettings.Playlists.group)
//                playlistView(for: BuildSettings.Playlists.nature)
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity / 2)
//        }
        .ignoresSafeArea()
        .padding(10)
    }
    
    func playlistView(for playlist: BuildSettings.Playlists) -> some View {
        
        let urls = loadPlaylistFolder(for: playlist)

        return ZStack {
            
            //Background
            RoundedRectangle(cornerRadius: 20)
                .fill(playlist.color)
            
            //Content
            VStack(alignment: .leading) {
                
                //Playlist name
                HStack{
                    Spacer()
                    HStack {
                        Image(systemName: "play.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 30))
                        
                        Text(NSLocalizedString(playlist.rawValue, comment: ""))
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding(.trailing)
                    }
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(10.0)
                    .onTapGesture {
                        
                        if let url = urls.first {
                            
                            AppUtils.createSessionFile(
                                sensitivity: -1,
                                setURL: url)

                            //Load settngs over current
                            setInfoModel.tapSavedRow(fileName: fileController.urlToFileName(url: url))

                            //Keep track for next in playlist after loading new set
                            setInfoModel.setSettings.currentSetInList = url
                            setInfoModel.setSettings.currentPlaylist = playlist
                            
                            //Change the View
                            sessionDisplay = setInfoModel.setSettings.defaultSkin
                        }
                    }
                    Spacer()
                }
                .padding(.bottom)
                    
                
                ScrollView(.vertical){
                    ForEach(urls, id: \.self) { url in
                        
                        HStack(spacing:20){
                            
                            //Play this set
                            Image(systemName: "play.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                            .frame(width: 30, height: 24)
                            .padding(.vertical, 5.0)
                            .padding(.horizontal, 5.0)
                            .background(Color.accentColor)
                            .cornerRadius(5.0)
                            .onTapGesture {
                                
                                //Store chosen url
                                AppUtils.createSessionFile(
                                    sensitivity: -1,
                                    setURL: url)
                                
                                //Load settngs over current
                                setInfoModel.tapSavedRow(fileName: fileController.urlToFileName(url: url))
                                
                                //Keep track for next in playlist after loading new set
                                setInfoModel.setSettings.currentSetInList = url
                                setInfoModel.setSettings.currentPlaylist = playlist
                                
                                //Change the View to the selected view
                                sessionDisplay = setInfoModel.setSettings.defaultSkin
                            }
    
                            //The file name and date
                            let filesName = fileController.fileNameOrCustomName(url: url, fileName: fileController.name(url: url))
                            
//                            VStack(alignment: .leading){
                                Text(filesName)
                                    .font(.title2)
                                
//                                Text(fileController.date(url: url))
//                                    .foregroundColor(Color(.lightGray))
//                                    .font(.subheadline)
//                            }
                            Spacer()
                        }
                    }
                    Spacer()
                }
            }
            .padding()
        }
    }
    
    func loadPlaylistFolder(for playlist: BuildSettings.Playlists) -> [URL] {
        
        let directoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let playListUrl = directoryURL.appendingPathComponent(playlist.rawValue)
        
        do {
            
            return try FileManager.default.contentsOfDirectory(at: playListUrl, includingPropertiesForKeys: nil)
        } catch {
            print(error)
            return []
        }
    }
}

