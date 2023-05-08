//
//  SavedSetsList.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 28/03/2023.
//

import SwiftUI

struct AddToPlaylistView: View{
    
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Text(NSLocalizedString("Add to playlist", comment: "String"))
                .font(.largeTitle)
            
            ForEach(BuildSettings.Playlists.allCases, id: \.self) { playlist in
                EMButton(action: {
                    print("Add this file to the folder \(playlist)")
                }, color: .primary, isSolid: false, maxWidth: 250, height: 35
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

struct SavedSetsList: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    @EnvironmentObject var fileController: FileController
    @Binding var userPresets: [URL]
    @State private var isSharePresented: Bool = false
    @State private var isPlaylistsPresented: Bool = false
    
    @State private var showAlert = false
    @State private var deleteUrl: URL = URL("empty")
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            HStack{
                Text("User sets")
                    .padding(.leading)
                    .font(.title)
                Spacer()
            }
            //User files documents fomder
            ForEach( userPresets, id: \.self ){ url in
                
                //Loop through filtered files in Documents folder
                if fileController.isURLInGroup(
                    url: url,
                    name: setInfoModel.setInfoLocalState.setName
                ) {
                    // Create a closure to capture the current URL and return the button
                    let deleteAction = {
                        showAlert = true
                        deleteUrl = url
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
                                AppUtils.createSessionFile(
                                    sensitivity: -1,
                                    setURL: url)
                                
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
                                //Store chosen url
                                AppUtils.createSessionFile(
                                    sensitivity: -1,
                                    setURL: url)
                                
                                //Load settngs over current
                                setInfoModel.tapSavedRow(fileName: fileController.urlToFileName(url: url))
                                //Change the View
                                sessionDisplaySub = .setEditor
                            }
                        
                        //Sharing
                        Button( action: {
                            self.isSharePresented = true
                        }) {
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
                        .sheet(isPresented: $isSharePresented, onDismiss: {
                            print("Dismiss")
                        }, content: {
                            let fileName = setInfoModel.setSettings.setURL.lastPathComponent
                            let url = AppUtils.documentDirectory().appendingPathComponent(fileName)
                            ActivityViewController(activityItems: [url])
                        })
                        
                        //Add to playlist
                        Button( action: {
                            self.isPlaylistsPresented = true
                        }) {
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
                            AddToPlaylistView(isPresented: $isPlaylistsPresented)
                        }
                        
                        //The file name and date
                        let filesName = fileController.fileContents(url: url, fileName: fileController.name(url: url))
                        
                        VStack(alignment: .leading){
                            Text(filesName)
                                .font(.title2)
                            
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
                            .alert(isPresented: $showAlert) {
                                Alert(title: Text("Confirm Delete"), message: Text("Are you sure you want to delete this item?"), primaryButton: .destructive(Text("Delete")) {
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


//struct ActivityViewController: UIViewControllerRepresentable {
//
//    var jsonFile: URL
//
//    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
//        let jsonData = try! Data(contentsOf: jsonFile)
//        let jsonDict = ["data": jsonData, "type": "public.json"] as [String : Any]
//        let controller = UIActivityViewController(activityItems: [jsonDict], applicationActivities: nil)
//        return controller
//    }
//
//    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
//}
