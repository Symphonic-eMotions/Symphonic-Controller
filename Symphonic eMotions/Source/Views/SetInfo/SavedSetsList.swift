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
    @State var urls: [URL] = []
    //FIXME: select the chosen one
    var isSelected: Bool {
         "false" == setInfoModel.setInfoLocalState.setName
    }
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading){
                
                ForEach( urls, id: \.self ){ url in
                    
                    if fileController.isURLInGroup(url: url, name: setInfoModel.setInfoLocalState.setName)
                    {
                        HStack(spacing:0){
                            
                            Image(systemName: "play.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                            .frame(width: 30)
                            .padding(.vertical, 5.0)
                            .padding(.horizontal, 5.0)
                            .background(Color.accentColor)
                            .cornerRadius(5.0)
                            .onTapGesture {
                                
                                AppUtils.createSessionFile(
                                    sensitivity: -1,
                                    setURL: url)
                                
                                //Load settngs over current
                                setInfoModel.tapSavedRow(fileName: fileController.urlToFileName(url: url))
                                //Change the View
                                sessionDisplay = setInfoModel.setInfoLocalState.loadSessionDisplay
                            }
                            
                            Spacer().frame(width: 20)
                            
                            Image(systemName: "square.and.pencil")
                                .foregroundColor(.white)
                                .font(.system(size: 18))
                                .frame(width: 30)
                                .padding(.vertical, 5.0)
                                .padding(.horizontal, 5.0)
                                .background(Color.green)
                                .cornerRadius(5.0)
                            .onTapGesture {
                                //Save current URL to disk
                                AppUtils.createSessionFile(
                                    sensitivity: -1,
                                    setURL: url)
                                
                                //Load settngs over current
                                setInfoModel.tapSavedRow(fileName: fileController.urlToFileName(url: url))
                                //Change the View
                                sessionDisplaySub = .setEditor
                            }
                            
                            let filesName = fileController.fileContents(url: url, fileName:  fileController.name(url: url))
                            Text(filesName)
                                .foregroundColor(isSelected ? Color(.lightGray) : .primary)
                                .font(.title3)
                                .padding(.horizontal)
                                .frame(minWidth: 400, alignment: .leading)
    //                            .border(.blue)
                            
                            Text(fileController.date(url: url))
                                .foregroundColor(isSelected ? Color(.lightGray) : .primary)
                                .font(.subheadline)
                                .padding(.horizontal)
    //                            .border(.green)
                            
                            Spacer()
                        }
                        .padding()
                        .fixedSize()
                    }
                }
                
            }
        }
        
        
        .onAppear{
            urls = fileController.addDirectoryURLsToController()
        }
    }
}

