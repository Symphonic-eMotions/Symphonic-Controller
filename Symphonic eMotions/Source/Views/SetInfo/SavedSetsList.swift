//
//  SavedSetsList.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 28/03/2023.
//

import SwiftUI

struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct SavedSetsList: View {
    
    @AppStorage(UserDefaultsKeys.currentUrl) var currentUrl: String = "SavedSetsList"
    
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplay: SessionDisplay
    @EnvironmentObject var fileController: FileController
    @Binding var userPresets: [URL]
    @State private var isSharePresented: Bool = false
    @State private var isPlaylistsPresented: Bool = false
    
    @State private var showDeleteAlert = false
    @State private var deleteUrl: URL = URL("empty")
    @State private var playlistUrl: URL = URL("empty")
    @State private var shareUrl: IdentifiableURL?
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            HStack{
                Text(NSLocalizedString("User sets", comment: ""))
                    .padding(.leading)
                    .font(.title)
                Spacer()
            }
            //User files documents folder
            ForEach( userPresets, id: \.self ){ url in
                
                //Loop through filtered files in Documents folder
                if fileController.isURLInGroup(
                    url: url,
                    name: setInfoModel.setInfoLocalState.setName
                ) {
                    // Create a closure to capture the current URL and return the button
                    //The same for adding to playlist and share
                    let deleteAction = {
                        showDeleteAlert = true
                        deleteUrl = url
                    }
                    let playlistAction = {
                        isPlaylistsPresented = true
                        playlistUrl = url
                    }
                    let shareAction = {
                        // Setting the share URL
                        shareUrl = IdentifiableURL(url: url)
                    }
                    
                    //The file name and date
                    let filesName = fileController.fileNameOrCustomName(
                        url: url, fileName: fileController.nameFromUrl(url: url)
                    )
                    
                    VStack(alignment: .leading, spacing: 8) { // Verlaag de spacing voor minder ruimte tussen tekst en knoppen
                        // De bestandsnaam en datum
                        VStack(alignment: .leading, spacing: 2) { // Kleine spacing tussen de tekstregels
                            Text(filesName)
                                .font(.title2)
                                .lineLimit(1) // Zorgt ervoor dat de tekst op één regel blijft
                            Text(fileController.date(url: url))
                                .foregroundColor(Color(.lightGray))
                                .font(.subheadline)
                        }
                        .layoutPriority(1)
                        
                        // HStack met knoppen
                        HStack(spacing: 10) { // Pas de spacing aan indien nodig
                            // Play this set
                            Image(systemName: "play.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 18))
                                .frame(width: 30, height: 24)
                                .padding(5)
                                .background(Color.accentColor)
                                .cornerRadius(5.0)
                                .onTapGesture {
                                    currentUrl = url.absoluteString
                                    //Load settngs over current
                                    setInfoModel.tapSavedRow(
                                        fileName: fileController.urlToFileName(
                                            url: url
                                        )
                                    )
                                    setInfoModel.userSettings.isCapturingRunning = true
                                    sessionDisplay = .swiftUI
                                }
                            
                            // Edit this set
                            Image(systemName: "square.and.pencil")
                                .foregroundColor(.white)
                                .font(.system(size: 18))
                                .frame(width: 30, height: 24)
                                .padding(5)
                                .background(Color.green)
                                .cornerRadius(5.0)
                                .onTapGesture {
                                    currentUrl = url.absoluteString
                                                                    
                                    //Load settngs over current
                                    setInfoModel.tapSavedRow(fileName: fileController.urlToFileName(url: url))
                                    
                                    //Change the View
//                                    sessionDisplaySub = .setEditor
                                }
                            
                            // Sharing
                            Button(action: shareAction) {
                                Image(systemName: "square.and.arrow.up")
                                    .renderingMode(.original)
                                    .foregroundColor(.white)
                                    .font(.system(size: 18))
                                    .frame(width: 30, height: 24)
                                    .padding(5)
                                    .background(Color.blue)
                                    .cornerRadius(5.0)
                            }
                            .sheet(item: $shareUrl, onDismiss: {
                                print("Dismiss")
                            }) { identifiableUrl in
                                ActivityViewController(activityItems: [identifiableUrl.url as NSURL])
                            }
                            
                            Spacer() // Zorgt ervoor dat de knoppen aan de linkerkant blijven en de Delete-knop aan de rechterkant
                            
                            // Delete-knop
                            Button(action: deleteAction) {
                                Image(systemName: "trash")
                                    .renderingMode(.template)
                                    .foregroundColor(.white)
                                    .font(.system(size: 18))
                                    .frame(width: 30)
                                    .padding(5)
                                    .background(Color.red)
                                    .cornerRadius(5.0)
                            }
                            .alert(isPresented: $showDeleteAlert) {
                                Alert(
                                    title: Text(NSLocalizedString("Confirm Delete", comment: "")),
                                    message: Text(NSLocalizedString("Are you sure", comment: "")),
                                    primaryButton: .destructive(Text(NSLocalizedString("Delete", comment: ""))) {
                                        // Verwijderactie
                                        userPresets = fileController.deleteFile(url: deleteUrl)
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                        }
                        // Verwijder of verminder de padding om de afstand tussen tekst en knoppen te verkleinen
                        .padding(.top, 5) // Alleen padding aan de bovenkant indien nodig
                    }
                    // Voeg padding toe aan de buitenste VStack voor consistente marges
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    // Voeg een Divider toe om sets van elkaar te scheiden
                    Divider()


                }
            } //End Foreach userPresets -> url
            
        }
        .onAppear{
            userPresets = fileController.addDirectoryURLsToController()
        }
    }
}

struct ActivityViewController: UIViewControllerRepresentable {

    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}
