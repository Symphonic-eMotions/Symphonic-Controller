//
//  ColumnOpacityController.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 03/04/2024.
//

import Foundation

class ColumnOpacityController: ObservableObject {
    
    @Published var columnOpacities: [Double]
    private var timers: [Timer?] = []
    private var targetOpacities: [Double]
    private var currentMaxColumn: Int = -1
    private let riseDuration: TimeInterval
    private let fadeDuration: TimeInterval

    init(
        columnCount: Int,
        riseDuration: TimeInterval = 1.4,
        fadeDuration: TimeInterval = 0.8
    ) {
        self.columnOpacities = Array(repeating: 0.0, count: columnCount)
        self.targetOpacities = Array(repeating: 1.0, count: columnCount)
        self.timers = Array(repeating: nil, count: columnCount)
        self.riseDuration = riseDuration
        self.fadeDuration = fadeDuration
    }
    
    // Methode om de opacity van een kolom te triggeren
    func triggerColumnEnvelope(forColumn column: Int) {
        
        if column == -1 {
            if currentMaxColumn >= 0 {
                startFadingColumn(at: currentMaxColumn)
                currentMaxColumn = -1
            }
            return
        }
        
        guard column >= 0 && column < columnOpacities.count else { return }
        
        if column == currentMaxColumn { return }
        
        resetColumnOpacities(except: column)
        currentMaxColumn = column
        
        timers[column]?.invalidate()
        targetOpacities[column] = 1.0
        
        timers[column] = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            if self.columnOpacities[column] < self.targetOpacities[column] {
                self.columnOpacities[column] += 0.02 / self.riseDuration
            } else {
                self.columnOpacities[column] = self.targetOpacities[column]
                timer.invalidate()
            }
        }
    }
    
    private func startFadingColumn(at column: Int) {
        timers[column]?.invalidate()

        timers[column] = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            if self.columnOpacities[column] > 0 {
                self.columnOpacities[column] -= 0.02 / self.fadeDuration
            } else {
                self.columnOpacities[column] = 0
                timer.invalidate()
            }
        }
    }
    
    private func resetColumnOpacities(except column: Int) {
        for i in columnOpacities.indices where i != column {
            timers[i]?.invalidate()
            
            timers[i] = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                
                if self.columnOpacities[i] > 0 {
                    self.columnOpacities[i] -= 0.02 / self.fadeDuration
                } else {
                    self.columnOpacities[i] = 0
                    timer.invalidate()
                }
            }
        }
    }
}

