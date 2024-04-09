//Aantekeningen
NavigationView {
    
    SideBarView(
        setInfoModel: setInfoModel,
        sessionDisplay: $sessionDisplay,
        sessionDisplaySub: $sessionDisplaySub,
        sidebarItems: $sidebarItems
    )
    .environmentObject(fileController)
    .onAppear {
        // Update `isCreator` based on the `userCode`
        isCreator = userSettings.userCode == .creator
        
        //Main navigation
        var items = [
            (name: "Home", setName: "home", fileGroup: FileGroup.home, sessionDisplay: SessionDisplay.home),
            //                        (name: "Active", setName: "playlists", fileGroup: FileGroup.playlists, sessionDisplay: SessionDisplay.playlists),
            (name: "Pro", setName: "pro", fileGroup: FileGroup.pro, sessionDisplay: SessionDisplay.pro)
        ]
        
        //Add creator navigation item
        if isCreator {
            items.append((name: "Creator", setName: "creator", fileGroup: FileGroup.template, sessionDisplay: SessionDisplay.creator))
        }
        
        sidebarItems = items
    }
    
    //SeM Pro interface with interaction editor
    if sessionDisplay == .swiftUI {
        
        ZStack{
            PlayView(
                setInfoModel: setInfoModel,
                sessionDisplay: $sessionDisplay,
                sessionDisplaySub: $sessionDisplaySub
            )
            .environmentObject(fileController)
            .navigationBarHidden(false)
            //It's not called PlayView for nothing
            .onAppear{
                sessionDisplaySub = .playing
                viewModel.conductor.playEngineAndTracks(
                    setSettings: viewModel.mainState.setSettings,
                    level: 0
                )
                viewModel.conductor.levelController(
                    level: 0,
                    setSettings: viewModel.mainState.setSettings
                )
            }
            .onDisappear{
                sessionDisplaySub = .stopped
                viewModel.conductor.pauzeEngineAndStopTracks(
                    setSettings: viewModel.mainState.setSettings,
                    resetLevels: true
                )
            }
            
            //If levels are completed go to count down view
            .onReceive(viewModel.leveling.currentSetLevelSubject){ currentSetLevel in
                if viewModel.mainState.setSettings.currentPlaylist != .none {
                    if currentSetLevel >= Double(viewModel.mainState.setSettings.levels.count) {
                        self.sessionDisplay = .countDown
                    }
                }
            }
        }
    }
}





















import SwiftUI

struct SetEditorView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding var editorParts: [EditorParts]
    @Binding var showEditorPart: EditorParts
    @Binding var trackLevels: [String: [Int]]
    @Binding var noteNumbersLevels: [String: [Int]]
    @Binding var midiClipsLevels: [String: [Int]]
    
    @Binding var gridRow: Int
    @Binding var noteNumbersPositions: [String: [Int]]
    @Binding var midiClipPositions: [String: [Int]]
    
    let columnWidth: CGFloat = 150
    let headingSize: CGFloat = 20
    
    var body: some View {
        
        //Instant selector
        HStack{
            
            Group{
                Image("track")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
                    .padding(4)
                    .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
            }
            .padding(.leading)
            
            Text("Set settings")
                .font(.system(size: 20))
                .padding()
            
            Spacer()
            
            let trackNames: [String:String] = setInfoModel.trackNames()
            
            Picker("Select editor part", selection: $showEditorPart) {
                ForEach(editorParts, id: \.self) { part in
                    if trackNames.contains(where: {$0.key == part.rawValue}) {
                        Text(trackNames[part.rawValue] ?? "Unnamed track").tag(part)
                    }
                    else if part == .none || part == .set {
                        Text(part.rawValue.capitalized).tag(part)
                    }
                    else {
                        Text("\(part.rawValue.capitalized) all tracks").tag(part)
                    }
                    
                }
            }
            .pickerStyle(.inline)
            .frame(height: 100)
        }
        .onTapGesture {
            withAnimation {
                if showEditorPart == .set { showEditorPart = .none}
                else { showEditorPart = .set }
            }
        }
        
        if showEditorPart == .set {

            HStack{
                Text("Name")
                    .font(.system(size: headingSize))
                    .padding()
                    .frame(width: columnWidth, alignment: .leading)
                
                TextField("Custom name", text: $setInfoModel.setSettings.customName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading)
                    .padding(.trailing)
                    
            }
            HStack{
                Text("Interactive Views")
                    .font(.system(size: headingSize))
                    .padding()
                    .frame(width: columnWidth, alignment: .leading)
                
                SelectUserViews(
                    setInfoModel: setInfoModel
                )
                .frame(height: 300)
            }
        }
    }
}
