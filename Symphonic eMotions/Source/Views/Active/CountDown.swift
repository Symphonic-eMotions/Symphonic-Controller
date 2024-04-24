//
//  CountDown.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 11/05/2023.
//

import SwiftUI

struct CountDown: View {
        
    @EnvironmentObject var userSettings: UserSettings
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    @EnvironmentObject var fileController: FileController
    @State private var counter = 5
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        
        VStack{
            
            Image("LogoColor")
                .resizable()
                .frame(width: 100, height: 100)
                .cornerRadius(10)
            
            Text(NSLocalizedString("Count down to", comment: ""))
                .font(.system(size: 40))
                .padding(.bottom)
            
            Text("\(counter)")
                .font(.system(size: 80))
                .onReceive(timer) { _ in
                    if counter > 1   {
                        counter -= 1
                    } else {
                        
                        AnalyticsAction.nextSetAutomated.logEvent(sessionDisplay: sessionDisplay, fileGroup: setInfoModel.setSettings.fileGroup, setName: setInfoModel.setSettings.setName)
                        
                        print("NEXT SET, end of count down")
                        
                        if let nextUrl = nextURL(
                            currentURL: setInfoModel.setSettings.currentSetInList,
                            currentPlaylist: setInfoModel.setSettings.currentPlaylist
                        ) {
                            
                            print("nextURL: \(nextUrl)")
                            
                            //Remember playlist before overwriting
                            let thisPlaylist = setInfoModel.setSettings.currentPlaylist
                            
                            //Load settngs over current
                            setInfoModel.tapSavedRow(fileName: fileController.urlToPlayListFileName(url: nextUrl)){
                                print("Setting sessionDisplay to .playlist")
                                sessionDisplay = .playlists
                            }
                            
                            //Keep track for next in playlist after loading new set
                            setInfoModel.setSettings.currentSetInList = nextUrl
                            setInfoModel.setSettings.currentPlaylist = thisPlaylist
                        }
                    }
                }
            
            HStack {
                Image(systemName: "play.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 30))
                
                Text(NSLocalizedString("Same song", comment: ""))
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding(.trailing)
            }
            .padding()
            .background(Color.accentColor)
            .cornerRadius(10.0)
            .onTapGesture {
                
                //Remember playlist before overwriting
                let thisPlaylist = setInfoModel.setSettings.currentPlaylist
                let thisSet = setInfoModel.setSettings.currentSetInList
                
                userSettings.currentUrl = setInfoModel.setSettings.currentSetInList.absoluteString
                
                //Load settngs over current
                setInfoModel.tapSavedRow(fileName: fileController.urlToPlayListFileName(url: setInfoModel.setSettings.currentSetInList)){
                    print("Countdown Setting sessionPlaylist to .playlists")
                    sessionDisplay = .playlists
                }
                //Keep track for next in playlist after loading new set
                setInfoModel.setSettings.currentSetInList = thisSet
                setInfoModel.setSettings.currentPlaylist = thisPlaylist
            }
        }
    }
    
    func nextURL(currentURL: URL, currentPlaylist: SeMActive.Playlists) -> URL? {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let minimalFolderURL = documentDirectory.appendingPathComponent(currentPlaylist.rawValue)

        do {
            let directoryContents = try fileManager.contentsOfDirectory(at: minimalFolderURL, includingPropertiesForKeys: [.creationDateKey], options: [])

            // Sort URLs based on creation date
            let sortedURLs = directoryContents.sorted {
                let date0 = try? $0.resourceValues(forKeys: [.creationDateKey]).creationDate
                let date1 = try? $1.resourceValues(forKeys: [.creationDateKey]).creationDate
                return date0 ?? Date.distantPast < date1 ?? Date.distantPast
            }

            // Find the index of the current URL
            if let currentIndex = sortedURLs.firstIndex(of: currentURL) {
                // If it's the last URL, return the first URL. Otherwise, return the next URL.
                if currentIndex == sortedURLs.count - 1 {
                    return sortedURLs.first
                } else {
                    return sortedURLs[currentIndex + 1]
                }
            } else {
                // If the current URL is not in the list, return the first URL (or nil if the list is empty).
                return sortedURLs.first
            }
        } catch {
            print("Error getting directory contents: \(error)")
            return nil
        }
    }
}
