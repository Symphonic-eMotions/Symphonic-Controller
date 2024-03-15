//
//  SVGImageViewContainer.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 14/03/2024.
//

import SwiftUI

struct SVGImageViewContainer: View {
    
    @ObservedObject var levelPlayerModel: LevelPlayerModel
    var geometry: GeometryProxy
    var level: Int
    var imageName: String
    @Binding var scale: Float
    
    var body: some View {
        
        SVGImageView(
            levelPlayerModel: levelPlayerModel,
            level: level,
            imageName: "level\(level)",
            scale: CGFloat(scale)
        )
        .frame(
            width: geometry.size.width,
            height: geometry.size.height
        )
    }
}
