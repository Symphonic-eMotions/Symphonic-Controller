//
//  SavedSettingsView.swift
//  Symphonic eMotions Intern
//
//  Created by Frans-Jan Wind on 26/10/2022.
//

import Foundation
import SwiftUI

struct SavedSettingsView: View {
    
    @ObservedObject var sideBarSetsViewModel: SideBarSetsViewModel
    var currenSetName: String
    let setCollection: MusicSet
    
//    var url: URL
    @State var urls: [URL] = []
    
    @EnvironmentObject var fileController: FileController
    
    var isSelected: Bool {
        currenSetName == setCollection.name
    }
    
    var body: some View {
        
        HStack {
            VStack(alignment: .leading) {
                VStack(alignment: .leading){
                    
                    ForEach( urls, id: \.self ){ url in
                        if fileController.isURLInGroup(url: url, name: currenSetName)
                        {
                            VStack{
                                Spacer()
                                Text(fileController.name(url: url))
                                    .foregroundColor(isSelected ? Color(.lightGray) : .primary)
                                    .font(.title3)
                                    .padding(.horizontal)
                                Text(fileController.date(url: url))
                                    .foregroundColor(isSelected ? Color(.lightGray) : .primary)
                                    .font(.subheadline)
                                    .padding(.horizontal)
                                
                                Spacer()
                            }
                            .onTapGesture {
                                //Load settngs over current
                                sideBarSetsViewModel.tapSavedRow(fileName: fileController.urlToFileName(url: url))
                            }
                        }
                    }
                    
                    Spacer()
                    
                    ReloadSetButtton(action: {
                        urls = fileController.getContentsOfDirectory()})
                }
                
            }
            Spacer()
        }
        .padding(.vertical, 4.0)
        .padding(.leading, 4.0)
        .background(isSelected ? Color(.darkGray) : .secondary)
        .cornerRadius(10.0)
        .onAppear{
            urls = fileController.addDirectoryURLsToController()
        }

        
    }
}
