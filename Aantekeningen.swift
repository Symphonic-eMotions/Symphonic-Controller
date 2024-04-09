//Aantekeningen
struct PlayView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    @ObservedObject var setInfoModel: SetInfoModel
    @EnvironmentObject var fileController: FileController
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    @StateObject private var columnOpacityController: ColumnOpacityController
    @StateObject private var gridModel: GridModel
    @State private var presentSettingSheet = false
    @State private var showMasterTrack: Bool = false
    @Binding public var showLevelPlayerFullScreen: Bool
    
    init(
        setInfoModel: SetInfoModel,
        sessionDisplay: Binding<SessionDisplay>,
        sessionDisplaySub: Binding<SessionDisplay>,
        showLevelPlayerFullScreen: Binding<Bool>
    ){
        self.setInfoModel = setInfoModel
        self._columnOpacityController = StateObject(wrappedValue: ColumnOpacityController(count:(setInfoModel.setInfoState.currentInstrumentsSet.columns))
        )
        self._gridModel = StateObject(wrappedValue:
            GridModel(
                levelCount: setInfoModel.setSettings.levels.count,
                levelSubject: setInfoModel.leveling.currentSetLevelSubject,
                gridRows: setInfoModel.setInfoState.currentInstrumentsSet.rows,
                gridColumns: setInfoModel.setInfoState.currentInstrumentsSet.columns
            )
        )
        self._sessionDisplay = sessionDisplay
        self._sessionDisplaySub = sessionDisplaySub
        self._showLevelPlayerFullScreen = showLevelPlayerFullScreen
    }
    
    var body: some View {
            
        //Video preview and instrument locations
        GeometryReader { geometry in
            
            LevelPlayer(
                setInfoModel: setInfoModel,
                columnOpacityController: columnOpacityController,
                gridModel: gridModel,
                showLevelPlayerFullScreen: $showLevelPlayerFullScreen,
                geometry: geometry
            )
            .zIndex(showLevelPlayerFullScreen ? 200 : 0)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onTapGesture {
                presentSettingSheet.toggle()
            }
            .sheet(isPresented: $presentSettingSheet) {
                SettingsSheetView(
                    userSettings: userSettings,
                    setInfoModel: setInfoModel,
                    showingSheet: $presentSettingSheet
                )
            }
        }
    }
}

struct LevelPlayer: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var columnOpacityController: ColumnOpacityController
    @ObservedObject var gridModel: GridModel
    @Binding var showLevelPlayerFullScreen: Bool
    var geometry: GeometryProxy
    
    var body: some View {
        ZStack(alignment: .center) {
            
            if setInfoModel.setSettings.userViews.contains(.columnView) {
                
                ColumnView(
                    setInfoModel: setInfoModel,
                    columnOpacityController: columnOpacityController,
                    rows: setInfoModel.setInfoState.currentInstrumentsSet.rows,
                    columns: setInfoModel.setInfoState.currentInstrumentsSet.columns,
                    width: showLevelPlayerFullScreen ? UIScreen.main.bounds.width : geometry.size.width,
                    height: showLevelPlayerFullScreen ? UIScreen.main.bounds.height - 20 : geometry.size.height
                )
                .frame(
                    width: showLevelPlayerFullScreen ? UIScreen.main.bounds.width : geometry.size.width,
                    height: showLevelPlayerFullScreen ? UIScreen.main.bounds.height : geometry.size.height
                )
                .position(
                    x: showLevelPlayerFullScreen ? UIScreen.main.bounds.width / 2 : geometry.size.width / 2,
                    y: showLevelPlayerFullScreen ? UIScreen.main.bounds.height / 2 : geometry.size.height / 2
                )
                .onAppear {
                    // Inline en fullscreen grootte bepalen en doorgeven
                    let inlineSize = CGSize(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    let fullscreenSize = UIScreen.main.bounds.size
                    gridModel.updateCellCenters(inlineSize: inlineSize, fullscreenSize: fullscreenSize)
                    
                    gridModel.initializeViewCenters(
                        inlineSize: CGSize(width: geometry.size.width, height: geometry.size.height),
                        fullscreenSize: UIScreen.main.bounds.size // Of een andere logica voor het bepalen van de fullscreen grootte
                    )
                }
            }
            else if setInfoModel.setSettings.userViews.contains(.gridView){
                
                GridView(
                    setInfoModel: setInfoModel,
                    opacityController: columnOpacityController,
                    rows: setInfoModel.setInfoState.currentInstrumentsSet.rows,
                    columns: setInfoModel.setInfoState.currentInstrumentsSet.columns,
                    width: showLevelPlayerFullScreen ? UIScreen.main.bounds.width : geometry.size.width,
                    height: showLevelPlayerFullScreen ? UIScreen.main.bounds.height : geometry.size.height
                )
                .frame(
                    width: showLevelPlayerFullScreen ? UIScreen.main.bounds.width : geometry.size.width,
                    height: showLevelPlayerFullScreen ? UIScreen.main.bounds.height : geometry.size.height
                )
                .position(
                    x: showLevelPlayerFullScreen ? UIScreen.main.bounds.width / 2 : geometry.size.width / 2,
                    y: showLevelPlayerFullScreen ? UIScreen.main.bounds.height / 2 : geometry.size.height / 2
                )
                .onAppear {
                    // Inline en fullscreen grootte bepalen en doorgeven
                    let inlineSize = CGSize(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    let fullscreenSize = UIScreen.main.bounds.size
                    gridModel.updateCellCenters(inlineSize: inlineSize, fullscreenSize: fullscreenSize)
                    
                    gridModel.initializeViewCenters(
                        inlineSize: CGSize(width: geometry.size.width, height: geometry.size.height),
                        fullscreenSize: UIScreen.main.bounds.size // Of een andere logica voor het bepalen van de fullscreen grootte
                    )
                }
            }
        }
    }
}

