//
//  SavedSetsList.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 28/03/2023.
//

import SwiftUI

struct SavedSetsList: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    @EnvironmentObject var fileController: FileController
    @Binding var urls: [URL]
    @State private var isSharePresented: Bool = false
    @State private var showAlert = false
    @State private var deleteUrl: URL = URL("empty")
    
    //FIXME: select the chosen one
    var isSelected: Bool {
         "false" == setInfoModel.setInfoLocalState.setName
    }
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading){
                
                ForEach( urls, id: \.self ){ url in
                    
                    //Loop through filtered files in Documents folder
                    if fileController.isURLInGroup(
                        url: url,
                        name: setInfoModel.setInfoLocalState.setName
                    )
                    {
                        // Create a closure to capture the current URL and return the button
                        let deleteAction = {
                            showAlert = true
                            deleteUrl = url
                        }
                        
                        HStack(spacing:0){
                            
                            //Play this set
                            Image(systemName: "play.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                            .frame(width: 30)
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
                            
                            Spacer().frame(width: 20)
                            
                            //Edit this set
                            Image(systemName: "square.and.pencil")
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                            .frame(width: 30)
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
                            Spacer().frame(width: 20)
                            
                            //Sharing
                            Button( action: {
                                self.isSharePresented = true
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                .renderingMode(.original)
                                .foregroundColor(.white)
                                .font(.system(size: 18))
                                .frame(width: 30)
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
                            
                            let filesName = fileController.fileContents(url: url, fileName: fileController.name(url: url))
                            VStack{
                                HStack{
                                    Text(filesName)
                                        .foregroundColor(isSelected ? Color(.lightGray) : .primary)
                                        .font(.title3)
                                        .padding(.horizontal)
                                        .frame(minWidth: 400, alignment: .leading)
                                
                               
                                    Text(fileController.date(url: url))
                                        .foregroundColor(isSelected ? Color(.lightGray) : .primary)
                                        .font(.subheadline)
                                        .padding(.horizontal)
                                }
//                                HStack{
//                                    Spacer()
//                                    Text(fileController.urlToFileName(url: url))
//                                        .foregroundColor(isSelected ? Color(.lightGray) : .primary)
//                                        .font(.subheadline)
//                                        .padding(.horizontal)
//                                }
                            }
                            Spacer()
                            
                            //Delete
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
                                    urls = fileController.deleteFile(url: deleteUrl)
                                }, secondaryButton: .cancel())
                            }
                        }
                        .padding()
                        .fixedSize()
                    }
                } //End Foreach urls -> url
            }
        }
        .onAppear{
            urls = fileController.addDirectoryURLsToController()
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
