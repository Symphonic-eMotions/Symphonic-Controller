////
////  VersionSetsList.swift
////  Symphonic eMotions Pro
////
////  Created by Frans-Jan Wind on 26/04/2023.
////
//
//import SwiftUI
//
//class VersionListModel: ObservableObject {
//
////    @Published var setFiles: [SetFile] = []
//
//    private var urls: [URL] = []
//
//    func loadVersionFiles(folderName: String) -> [URL] {
//
//        let folderName = (folderName as NSString).deletingPathExtension
//
//        print("LOADVERSIONFILES FOLDERNAME: \(folderName)")
//
//        guard let url = Bundle.main.url(forResource: "Sets/\(folderName)", withExtension: nil) else {
//            print("Failed to find Sets/\(folderName) folder")
//            return [URL("loadVersionFiles")]
//        }
//        do {
//            let fileURLs = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
//            let decoder = JSONDecoder()
//
//            for fileURL in fileURLs {
//                if fileURL.pathExtension == "json" {
//                    do {
//                        let data = try Data(contentsOf: fileURL)
//                        let decodedFile = try decoder.decode(InstrumentsSet.self, from: data)
//
//                        print(" \(decodedFile.name) => \(decodedFile.customName)")
//                        print(fileURL.absoluteString)
//                        urls.append(fileURL)
//
//                    } catch {
//                        print("Error decoding JSON file: \(error)")
//
//                    }
//                }
//            }
//        } catch {
//            print("Error reading contents of directory: \(error)")
//        }
//        return urls
//    }
//}
//
//struct VersionSetsList: View {
//
//    @ObservedObject var setInfoModel: SetInfoModel
//    @Binding public var sessionDisplay: SessionDisplay
//    @Binding public var sessionDisplaySub: SessionDisplay
//    @EnvironmentObject var fileController: FileController
//    @Binding var urls: [URL]
//
//    @StateObject private var viewModel = VersionListModel()
//    @State private var isSharePresented: Bool = false
//    @State var versionUrls: [URL] = []
//    @State var templatePresets: [URL] = []
//
////    @State private var selectedSet: SetFile?
//
//    var body: some View {
//
//        VStack(alignment: .leading){
//
//            Text("Presets")
//                .padding(.leading)
//                .font(.title)
//
//            ForEach( versionUrls, id: \.self ){ versionUrl in
//
//                let filesName = fileController.fileContents(
//                    url: versionUrl,
//                    fileName: fileController.name(url: versionUrl)
//                )
//
//                let _ = print("FILESNAME: \(filesName)")
//
//                HStack(spacing:20){
//
//                    //Play this set
//                    Image(systemName: "play.fill")
//                    .foregroundColor(.white)
//                    .font(.system(size: 18))
//                    .frame(width: 30)
//                    .padding(.vertical, 5.0)
//                    .padding(.horizontal, 5.0)
//                    .background(Color.accentColor)
//                    .cornerRadius(5.0)
//                    .onTapGesture {
//                        //Store chosen url
//                        AppUtils.createSessionFile(
//                            sensitivity: -1,
//                            setURL: versionUrl
//                        )
//
//                        //Load settngs over current
//                        setInfoModel.tapSavedRow(
//                            fileName: filesName
////                                fileController.urlToFileName(
////                                    url: versionUrl
////                                )
//                        )
//                        //Change the View to the selected view
//                        sessionDisplay = setInfoModel.setSettings.defaultSkin
//                    }
//
//                    //Edit this set
//                    Image(systemName: "square.and.pencil")
//                    .foregroundColor(.white)
//                    .font(.system(size: 18))
//                    .frame(width: 30)
//                    .padding(.vertical, 5.0)
//                    .padding(.horizontal, 5.0)
//                    .background(Color.orange)
//                    .cornerRadius(5.0)
//                    .onTapGesture {
//                        //Store chosen url
//                        AppUtils.createSessionFile(
//                            sensitivity: -1,
//                            setURL: versionUrl
//                        )
//
//                        //Load settngs over current
//                        setInfoModel.tapSavedRow(
//                            fileName: filesName)
//                        //Change the View
//                        sessionDisplaySub = .setEditor
//                    }
//
//                    //Sharing
//                    Button( action: {
//                        self.isSharePresented = true
//                    }) {
//                        Image(systemName: "square.and.arrow.up")
//                        .renderingMode(.original)
//                        .foregroundColor(.white)
//                        .font(.system(size: 18))
//                        .frame(width: 30)
//                        .padding(.vertical, 5.0)
//                        .padding(.horizontal, 5.0)
//                        .background(Color.blue)
//                        .cornerRadius(5.0)
//                    }
//                    .sheet(isPresented: $isSharePresented, onDismiss: {
//                        print("Dismiss")
//                    }, content: {
//                        let url = AppUtils.documentDirectory().appendingPathComponent(filesName)
//                        ActivityViewController(activityItems: [url])
//                    })
//
//
//
//                    Spacer()
//
//                    VStack{
//                        HStack{
//                            Text(filesName)
//                                .foregroundColor(Color(.lightGray))
//                                .font(.title3)
//                                .padding(.horizontal)
//                                .frame(minWidth: 400, alignment: .leading)
//
//
//                            Text(fileController.date(url: versionUrl))
//                                .foregroundColor(Color(.lightGray))
//                                .font(.subheadline)
//                                .padding(.horizontal)
//                        }
////                                HStack{
////                                    Spacer()
////                                    Text(fileController.urlToFileName(url: url))
////                                        .foregroundColor(Color(.lightGray))
////                                        .font(.subheadline)
////                                        .padding(.horizontal)
////                                }
//                    }
//
//                    Spacer()
//
//                    Image(systemName: "trash")
//                    .renderingMode(.template)
//                    .foregroundColor(.clear)
//                    .font(.system(size: 18))
//                    .frame(width: 30)
//                    .padding(.vertical, 5.0)
//                    .padding(.horizontal, 5.0)
//                    .background(Color.clear)
//                    .cornerRadius(5.0)
//                }
//                .padding()
//                .fixedSize()
//            }
//        }
//        .onAppear{
//            //Pass the url to gdet the folder name with presets
////            urls = fileController.addDirectoryURLsToController()
//            versionUrls = viewModel.loadVersionFiles(folderName: setInfoModel.setInfoLocalState.setConfig)
//        }
////        .onChange(of: urls) { newValue in
////            versionUrls = viewModel.loadVersionFiles(folderName: setInfoModel.setInfoLocalState.setConfig)
////        }
//    }
//}
