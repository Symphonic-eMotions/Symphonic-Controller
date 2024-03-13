//
//  PlaylistView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 27/06/2023.
//

import SwiftUI

struct PlaylistView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    
    @EnvironmentObject var fileController: FileController
    
    @ObservedObject var viewModel: PlaylistViewModel
    
    var body: some View {
        ZStack {
            //Background
            RoundedRectangle(cornerRadius: 20)
                .fill(viewModel.playlist.color)
            
            //Content
            VStack(alignment: .leading) {
                
                //Playlist name
                HStack{
                    Spacer()
                    HStack {
                        Image(systemName: "play.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 30))
                        
                        Text(NSLocalizedString(viewModel.playlist.rawValue, comment: ""))
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding(.trailing)
                    }
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(10.0)
                    .onTapGesture {
                        
                        if let url = viewModel.urls.first {
                            
                            userSettings.currentUrl = url.absoluteString
                            
                            print("Load Header Playlist file \(url.absoluteString)")
                            
                            setInfoModel.tapSavedRow(fileName: fileController.urlToPlayListFileName(url: url))
                            
                            //Keep track for next in playlist after loading new set
                            setInfoModel.setSettings.currentSetInList = url
                            setInfoModel.setSettings.currentPlaylist = viewModel.playlist
                            
                            //Change the View to the selected view
                            sessionDisplay = setInfoModel.setSettings.defaultSkin
                        }
                    }
                    Spacer()
                }
                .padding(.bottom)
                    
                //Files in Playlist
                ScrollView(.vertical) {
                    
                    ForEach(viewModel.urls.indices, id: \.self) { index in
                                        
                        let url = viewModel.urls[index]
                        
                        HStack(spacing:15){
                            
                            Group{
                                
                                //Play this set
                                Image(systemName: "play.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18))
                                    .frame(width: 30, height: 24)
                                    .padding(.vertical, 5.0)
                                    .padding(.horizontal, 5.0)
                                    .background(Color.accentColor)
                                    .cornerRadius(5.0)
                                    
                                //The file name and date
                                let filesName = fileController.setNameCustomName(url: url)
                                
                                ZStack(alignment: .trailing) {
                                    
                                    HStack{
                                        Text(filesName)
                                            .font(.title2)
                                        Spacer()
                                    }
                                    
                                    HStack{
                                        Spacer()
                                        //Remove set
                                        Button("-") {
                                            viewModel.removeSetUrl = url
                                            viewModel.showRemoveConfirmation = true
                                        }
                                        .font(.system(size: 45))
                                        .foregroundColor(viewModel.urls.count == 1 ? .gray : .red)
                                        .padding(.trailing)
                                        .disabled(viewModel.urls.count == 1)
                                        .alert(isPresented: $viewModel.showRemoveConfirmation) {
                                            Alert(
                                                title: Text(NSLocalizedString("Remove Set", comment: "")),
                                                message: Text(""),
                                                primaryButton: .destructive(Text("Remove")) {
                                                    
                                                    if let url = viewModel.removeSetUrl {
                                                        viewModel.deleteUrl(url)
                                                    }
                                                },
                                                secondaryButton: .cancel()
                                            )
                                        }
                                    }
                                }
                            }
                            .onTapGesture {
                                
                                //App storage
                                userSettings.currentUrl = url.absoluteString
                                
                                print("Load Playlist file \(url)")
                                
                                //Load settngs over current
                                setInfoModel.tapSavedRow(fileName: fileController.urlToPlayListFileName(url: url))
                                
                                //Keep track for next in playlist after loading new set
                                setInfoModel.setSettings.currentSetInList = url
                                setInfoModel.setSettings.currentPlaylist = viewModel.playlist
                                
                                //Change the View to the view in the skin settings
                                sessionDisplay = setInfoModel.setSettings.defaultSkin
                                
                            }
                            .onLongPressGesture {
                                
                                //Edit file
                                userSettings.currentUrl = url.absoluteString
                                
                                //Load settings over current
                                setInfoModel.tapSavedRow(fileName: fileController.urlToPlayListFileName(url: url))
                                
                                //Change the View
                                sessionDisplay = .setInfo
                                sessionDisplaySub = .playListEditor
                            }
                            
                            
                        }
                        .frame(height: 55)
                    }
                }
            }
            .padding()
        }
    }
}
