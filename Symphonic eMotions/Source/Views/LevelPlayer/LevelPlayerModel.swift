//
//  LevelPlayerModel.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 15/03/2024.
//

import SwiftUI

class LevelPlayerModel: ObservableObject {
    
    var positions: [Int: CGPoint] = [:]

    func position(for level: Int, in geometry: GeometryProxy) -> CGPoint {
        if let position = positions[level] {
            return position
        } else {
            let newPosition = CGPoint(
                x: CGFloat.random(in: 0.375...0.625) * geometry.size.width,
                y: CGFloat.random(in: 0.375...0.625) * geometry.size.height
            )
            positions[level] = newPosition
            return newPosition
        }
    }
}
