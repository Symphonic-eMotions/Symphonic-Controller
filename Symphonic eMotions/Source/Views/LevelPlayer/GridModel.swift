//
//  GridModel.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 30/03/2024.
//

import Combine
import SwiftUI

struct GridCell {
    let index: Int
    var inlineCenter: CGPoint
    var fullscreenCenter: CGPoint
}

struct SVGPosition {
    var originalPosition: CGPoint
    let lastSVGPosition: CGPoint
//    let lastMaxIndexPosition: CGPoint
}

class GridModel: ObservableObject {
    @Published var inlineViewCenter: CGPoint = .zero
    @Published var fullscreenViewCenter: CGPoint = .zero
    @Published var cells: [GridCell] = []

    // Published properties om SwiftUI te laten reageren op de veranderingen
    @Published var xOffset: CGFloat = 0
    @Published var yOffset: CGFloat = 0

    var levelCount: Int

    private var radius: CGFloat {
        // Stel dat de maximale straal 100 is; pas dit aan naar jouw behoeften
        return 5 * CGFloat(currentLevel / Double(levelCount))
    }

    var currentLevel: Double = 0 {
        didSet {
//            updateOffsets()
        }
    }

    private var angle: CGFloat = 0
    private var subscriptions = Set<AnyCancellable>()

    // Deze methode wordt aangeroepen elke keer als `currentLevel` verandert
    private func updateOffsets() {
        // Update de hoek gebaseerd op de framesnelheid of andere triggers
        // Deze voorbeeldcode laat de hoek constant toenemen; pas aan naar je behoefte
        angle += .pi / 100 // Voorbeeldwaarde, pas dit aan naar jouw logica

        // Bereken nieuwe offsets
        xOffset = radius * cos(angle)
        yOffset = radius * sin(angle)
    }

    private var gridRows: Int
    private var gridColumns: Int

    init(
        levelCount: Int,
        levelSubject: CurrentValueSubject<Double, Never>,
        gridRows: Int,
        gridColumns: Int
    ) {
        self.levelCount = levelCount
        self.gridRows = gridRows
        self.gridColumns = gridColumns
        initializeCells()
        levelSubject
            .receive(on: RunLoop.main)
            .assign(to: \.currentLevel, on: self)
            .store(in: &subscriptions)
    }

    func initializeViewCenters(inlineSize: CGSize, fullscreenSize: CGSize) {
        inlineViewCenter = CGPoint(x: inlineSize.width / 2, y: inlineSize.height / 2)
        fullscreenViewCenter = CGPoint(x: fullscreenSize.width / 2, y: fullscreenSize.height / 2)
    }

    private func initializeCells() {
        // De cellen initialiseren zonder specifieke middelpunten
        let numberOfCells = gridRows * gridColumns
        cells = (0 ..< numberOfCells).map {
            GridCell(
                index: $0,
                inlineCenter: .zero,
                fullscreenCenter: .zero
            )
        }
    }

    func updateCellCenters(inlineSize: CGSize, fullscreenSize: CGSize) {
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
