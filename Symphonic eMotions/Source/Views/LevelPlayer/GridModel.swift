//
//  GridModel.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 30/03/2024.
//

import SwiftUI
import Combine

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
    @Published var svgPositions: [Int: SVGPosition] = [:]
    @Published var targetPosition: CGPoint = .zero
    @Published var animationSpeedFactor: CGFloat = 1 // Kan variëren van 0 tot 1
    private var gridRows: Int
    private var gridColumns: Int
    
    init(gridRows: Int, gridColumns: Int) {
        self.gridRows = gridRows
        self.gridColumns = gridColumns
        self.initializeCells()
    }
    
    public func initializeViewCenters(inlineSize: CGSize, fullscreenSize: CGSize) {
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
