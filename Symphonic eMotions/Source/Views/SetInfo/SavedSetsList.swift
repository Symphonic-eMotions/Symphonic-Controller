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
    @Binding public var sessionDisplaySub: SessionDisplay
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
                    let deleteAction = {
                        showDeleteAlert = true
                        deleteUrl = url
                    }
                    
                    //The same for adding to playlist and share
                    let playlistAction = {
                        
                        AnalyticsAction.addToPlaylist.logEvent(
                            sessionDisplay: sessionDisplay
                        )
                        
                        isPlaylistsPresented = true
                        playlistUrl = url
                    }
                    
                    let shareAction = {
                        // Log the share action before setting the shareUrl
                        AnalyticsAction.shareSet.logEvent(
                            sessionDisplay: sessionDisplay
                        )

                        // Setting the share URL
                        shareUrl = IdentifiableURL(url: url)
                    }
                    
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
                                currentUrl = url.absoluteString
                                //Load settngs over current
                                setInfoModel.tapSavedRow(fileName: fileController.urlToFileName(url: url))
                                //Change the View to the selected view
                                sessionDisplay = setInfoModel.setSettings.defaultSkin
                            }
                        
                        //Edit this set
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                            .frame(width: 30, height: 24)
                            .padding(.vertical, 5.0)
                            .padding(.horizontal, 5.0)
                            .background(Color.green)
                            .cornerRadius(5.0)
                            .onTapGesture {
                                
                                AnalyticsAction.setEditor.logEvent(
                                    sessionDisplay: .setEditor
                                )
                                
                                //Store chosen url
                                currentUrl = url.absoluteString
                                
                                //Load settngs over current
                                setInfoModel.tapSavedRow(fileName: fileController.urlToFileName(url: url))
                                
                                //Change the View
                                sessionDisplaySub = .setEditor
                                
                            }
                        
                        //Sharing
                        Button(action: shareAction) {
                            Image(systemName: "square.and.arrow.up")
                                .renderingMode(.original)
                                .foregroundColor(.white)
                                .font(.system(size: 18))
                                .frame(width: 30, height: 24)
                                .padding(.vertical, 5.0)
                                .padding(.horizontal, 5.0)
                                .background(Color.blue)
                                .cornerRadius(5.0)
                        }
                        .sheet(item: $shareUrl, onDismiss: {
                            print("Dismiss")
                        }) { identifiableUrl in
                            ActivityViewController(activityItems: [identifiableUrl.url as NSURL])
                        }
                        
                        //Add to playlist
                        Button( action: playlistAction ) {
                            Image(systemName: "list.star")
                                .renderingMode(.original)
                                .foregroundColor(.white)
                                .font(.system(size: 18))
                                .frame(width: 30, height: 24)
                                .padding(.vertical, 5.0)
                                .padding(.horizontal, 5.0)
                                .background(Color.blue)
                                .cornerRadius(5.0)
                        }
                        .sheet(isPresented: $isPlaylistsPresented){
                            AddToPlaylistView(
                                isPresented: $isPlaylistsPresented,
                                sandBoxUrl: $playlistUrl
                            )
                        }
                        
                        //The file name and date
                        let filesName = fileController.fileNameOrCustomName(url: url, fileName: fileController.nameFromUrl(url: url))
                        
                        let smooterVersion = fileController.getSmootherVersion(url: url)
                        
                        VStack(alignment: .leading){
                            HStack{
                                Text(filesName)
                                    .font(.title2)
                                Image(systemName: smooterVersion == 2 ?
                                      "b.circle.fill" : "a.circle.fill")
                                .foregroundColor(smooterVersion == 2 ?
                                    .orange : .clear)
                                .font(.system(size: 24))
                            }
                            Text(fileController.date(url: url))
                                .foregroundColor(Color(.lightGray))
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        //Delete
                        VStack {
                            Spacer()
                            Button( action: deleteAction ) {
                                Image(systemName: "trash")
                                    .renderingMode(.template)
                                    .foregroundColor(.white)
                                    .font(.system(size: 18))
                                    .frame(width: 30)
                                    .padding(.vertical, 5.0)
                                    .padding(.horizontal, 5.0)
                                    .background(Color.red)
                                    .cornerRadius(5.0)
                            }
                            .alert(isPresented: $showDeleteAlert) {
                                Alert(
                                    title: Text(NSLocalizedString("Confirm Delete", comment: "")),
                                    message: Text(NSLocalizedString("Are you sure", comment: "")),
                                    primaryButton: .destructive(Text(NSLocalizedString("Delete", comment: ""))
                                ) {
                                    // Handle delete action
                                    userPresets = fileController.deleteFile(url: deleteUrl)
                                }, secondaryButton: .cancel())
                            }
                        }
                        .padding(.trailing)
                    }
                    .padding()
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
