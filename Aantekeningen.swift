
import SwiftUI
import AudioKit
import Combine

struct PlayView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    @StateObject private var opacityController: CellOpacityController
    @StateObject private var gridModel: GridModel
    @State private var showLevelPlayerFullScreen: Bool = false
    
    init(
        setInfoModel: SetInfoModel,
        sessionDisplay: Binding<SessionDisplay>,
        sessionDisplaySub: Binding<SessionDisplay>
    ){
        self.setInfoModel = setInfoModel
        self._opacityController = StateObject(wrappedValue: CellOpacityController(cellCount: (
                    setInfoModel.setInfoState.currentInstrumentsSet.rows * setInfoModel.setInfoState.currentInstrumentsSet.columns
                )
            )
        )
        self._gridModel = StateObject(wrappedValue:
            GridModel(
                gridRows: setInfoModel.setInfoState.currentInstrumentsSet.rows,
                gridColumns: setInfoModel.setInfoState.currentInstrumentsSet.columns
            )
        )
        self._sessionDisplay = sessionDisplay
        self._sessionDisplaySub = sessionDisplaySub
    }
    
    var body: some View {
           
        VStack {
            
            //Video preview and instrument locations
            GeometryReader { geometry in
                ZStack{
                    
                    LevelPlayer(
                        setInfoModel: setInfoModel,
                        opacityController: opacityController,
                        gridModel: gridModel,
                        showLevelPlayerFullScreen: $showLevelPlayerFullScreen,
                        geometry: geometry
                    )
                    .zIndex(showLevelPlayerFullScreen ? 200 : 0)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    
                    //Video preview View
                }
            }
            .zIndex(110)
        }
        .padding(.horizontal)
        .navigationBarTitleDisplayMode(.inline)
            
         
    }
}

struct LevelPlayer: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var opacityController: CellOpacityController
    @ObservedObject var gridModel: GridModel
    @Binding var showLevelPlayerFullScreen: Bool
    var geometry: GeometryProxy
    
    var body: some View {
        ZStack(alignment: .center) {
            
            //SVG Animation
            ForEach(0..<setInfoModel.setInfoState.currentInstrumentsSet.levels.count, id: \.self) { index in
                SVGImageViewContainer(
                    setInfoModel: setInfoModel,
                    gridModel: gridModel,
                    showLevelPlayerFullScreen: $showLevelPlayerFullScreen,
                    levelFromIndex: index,
                    geometry: geometry
                    
                )
                .onChange(of: setInfoModel.setSettings.maxIndex) { maxIndex in
                    
                    withAnimation(.easeInOut(duration: 1.0)) {
                        gridModel.calculateAnimation(
                            for: index,
                            at: maxIndex,
                            showLevelPlayerFullScreen
                        )
                    }
                }
                .frame(
                    width: showLevelPlayerFullScreen ? UIScreen.main.bounds.width : geometry.size.width,
                    height: showLevelPlayerFullScreen ? UIScreen.main.bounds.height : geometry.size.height
                )
            }
        }
        .frame(
            width: showLevelPlayerFullScreen ? UIScreen.main.bounds.width : geometry.size.width,
            height: showLevelPlayerFullScreen ? UIScreen.main.bounds.height : geometry.size.height
        )
        .background(showLevelPlayerFullScreen ? Color.black : Color.clear)
        .edgesIgnoringSafeArea(showLevelPlayerFullScreen ? .all : .init())
        .zIndex(showLevelPlayerFullScreen ? 201 : 0) // Verhoog de zIndex wanneer fullscreen
    }
}

struct SVGImageViewContainer: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var gridModel: GridModel
    @Binding var showLevelPlayerFullScreen: Bool
    //Also used for storing SVGPositions
    var levelFromIndex: Int
    var geometry: GeometryProxy
    
    
    var body: some View {

        let scaleOpacity = calculateScaleOpacity(for: levelFromIndex)
        // Bereken de offset gebaseerd op originalPosition en lastSVGPosition
        let position = gridModel.svgPositions[levelFromIndex] ?? SVGPosition(originalPosition: .zero, lastSVGPosition: .zero)
        let offsetX = position.lastSVGPosition.x - position.originalPosition.x
        let offsetY = position.lastSVGPosition.y - position.originalPosition.y

        SVGImageView(
            level: levelFromIndex,
            imageName: "level\(setInfoModel.setSettings.setPath)\(levelFromIndex)",
            scale: CGFloat(scaleOpacity.0),
            opacity: CGFloat(scaleOpacity.1)
        )
        .frame(width: showLevelPlayerFullScreen ? UIScreen.main.bounds.width : geometry.size.width, height: showLevelPlayerFullScreen ? UIScreen.main.bounds.height : geometry.size.height)
        .offset(x: offsetX, y: offsetY)
        .onAppear {
            // Update de positie wanneer de view verschijnt of de layout verandert
            let newSVGPosition = geometry.frame(in: .global).origin
            gridModel.updateSVGPosition(
                for: levelFromIndex,
                originalPosition: newSVGPosition, // Pas dit aan indien nodig
                newPosition: newSVGPosition
            )
        }
    }

    //@var (scale Float, Opacity Float)
    private func calculateScaleOpacity(for levelFromIndex: Int) -> (Float,Float) {
        
        //Amount of overlap next over previous level animation
        let overlap: Double = 0.25
        //Initial opcaity value
        var opacityBound: Float = 1
        // All level information
        let allLevelProgress = setInfoModel.leveling.currentSetLevelSubject.value
        // Current level
        let currentLevelValue = allLevelProgress - Double(levelFromIndex)
        
        // De exponent die je wilt gebruiken, dit kan elke waarde zijn die je instelt
        let exponentValue: Double = 0.9 // Voorbeeldwaarde, aanpasbaar naar wens

        // Bereken de waarde verheven tot de macht van de exponent
        let exponentiatedValue = Float(pow(currentLevelValue, exponentValue))
        
        //We starten de animatie op overlap voor 0
        if (allLevelProgress - overlap) > (0 - overlap) {
                
            //is de level reeds geweest? Start 2nd level animation
            if (exponentiatedValue > 1) {
                
                let opacityDouble = Double(exponentiatedValue)
                let opacity = opacityDouble.transform(
                    outputStart: 1,
                    outputEnd: 0.1,
                    inputStart: 1,
                    inputEnd: 1.8,
                    transformationDegree: 0
                )
                opacityBound = Float(max(0,min(1,opacity)))
            }

            return (max(0, exponentiatedValue),opacityBound)
        }
        // De animatie nog niet starten
        else {
            return (0,opacityBound)
        }
    }
}

struct GridCell {
    let index: Int
    var inlineCenter: CGPoint
    var fullscreenCenter: CGPoint
}

struct SVGPosition {
    var originalPosition: CGPoint
    let lastSVGPosition: CGPoint
}

class GridModel: ObservableObject {
    
    @Published var inlineViewCenter: CGPoint = .zero
    @Published var fullscreenViewCenter: CGPoint = .zero
    @Published var cells: [GridCell] = []
    @Published var svgPositions: [Int: SVGPosition] = [:]
    @Published var targetPosition: CGPoint = .zero
    @Published var animationSpeedFactor: CGFloat = 0.5 // Kan variëren van 0 tot 1
    private var gridRows: Int
    private var gridColumns: Int
    
    init(gridRows: Int, gridColumns: Int) {
        self.gridRows = gridRows
        self.gridColumns = gridColumns
        self.initializeCells()
    }
    
    private func initializeViewCenters(inlineSize: CGSize, fullscreenSize: CGSize) {
        inlineViewCenter = CGPoint(x: inlineSize.width / 2, y: inlineSize.height / 2)
        fullscreenViewCenter = CGPoint(x: fullscreenSize.width / 2, y: fullscreenSize.height / 2)
    }
    
    private func initializeCells() {
        // De cellen initialiseren zonder specifieke middelpunten
        let numberOfCells = gridRows * gridColumns
        cells = (0..<numberOfCells).map {
            GridCell(
                index: $0,
                inlineCenter: .zero,
                fullscreenCenter: .zero
            )
        }
    }
  
    public func updateSVGPosition(
        for id: Int,
        originalPosition: CGPoint? = nil,
        newPosition: CGPoint
    ) {
        if let position = svgPositions[id] {
            // Als originalPosition is meegegeven, update deze, anders behoud de huidige
            let updatedPosition = SVGPosition(
                originalPosition: originalPosition ?? position.originalPosition,
                lastSVGPosition: newPosition
            )
            svgPositions[id] = updatedPosition
        } else {
            // Als er geen bestaande positie is, voeg dan een nieuwe toe
            let newPosition = SVGPosition(originalPosition: originalPosition ?? newPosition, lastSVGPosition: newPosition)
            svgPositions[id] = newPosition
        }
    }
    
    private func getTargetForMaxIndex(at index: Int, isFullscreen: Bool) -> CGPoint {
        guard index >= 0 && index < cells.count else {
            return targetPosition
        }
        
        let cell = cells[index]
        let position = isFullscreen ? cell.fullscreenCenter : cell.inlineCenter
        targetPosition = position
        return position
    }
    
    
    public func calculateAnimation(
        for index: Int,
        at maxIndex: Int,
        _ fullScreen: Bool) {
        
        guard let lastPosition = svgPositions[index]?.lastSVGPosition else { return }
        
        print("calculateAnimation for \(index) at \(maxIndex) fullscreen \(fullScreen)")
            
        var target = getTargetForMaxIndex(
            at: maxIndex,
            isFullscreen: fullScreen)
            
            //Movement stops
            if maxIndex == -1 {
                // Animeren naar het midden van de view
                target = fullScreen ? fullscreenViewCenter : inlineViewCenter
            } else {
                // Bestaande logica voor het animeren naar een specifieke cel
                target = getTargetForMaxIndex(at: index, isFullscreen: fullScreen)
            }
            
        // Bereken de geïnterpoleerde positie
        let interpolatedX = lastPosition.x + (target.x - lastPosition.x) * animationSpeedFactor
        let interpolatedY = lastPosition.y + (target.y - lastPosition.y) * animationSpeedFactor

        let newPosition = CGPoint(x: interpolatedX, y: interpolatedY)

        // Update de positie
        updateSVGPosition(
            for: index,
            newPosition: newPosition
        )
    }

    
    public func updateCellCenters(inlineSize: CGSize, fullscreenSize: CGSize) {
        
        let inlineCellWidth = inlineSize.width / CGFloat(gridColumns)
        let inlineCellHeight = inlineSize.height / CGFloat(gridRows)
        let fullscreenCellWidth = fullscreenSize.width / CGFloat(gridColumns)
        let fullscreenCellHeight = fullscreenSize.height / CGFloat(gridRows)
        
        for i in cells.indices {
            let row = i / gridColumns
            let column = i % gridColumns
            
            let inlineCenterX = (CGFloat(column) * inlineCellWidth) + (inlineCellWidth / 2)
            let inlineCenterY = (CGFloat(row) * inlineCellHeight) + (inlineCellHeight / 2)
            cells[i].inlineCenter = CGPoint(x: inlineCenterX, y: inlineCenterY)
            
            let fullscreenCenterX = (CGFloat(column) * fullscreenCellWidth) + (fullscreenCellWidth / 2)
            let fullscreenCenterY = (CGFloat(row) * fullscreenCellHeight) + (fullscreenCellHeight / 2)
            cells[i].fullscreenCenter = CGPoint(x: fullscreenCenterX, y: fullscreenCenterY)
        }
    }
}
