//
//  SVGImageView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 13/03/2024.
//

import SwiftUI

struct SVGImageView: View {
    
    @ObservedObject var levelPlayerModel: LevelPlayerModel
    var level: Int
    var imageName: String
    var scale: CGFloat

    var body: some View {
        GeometryReader { geometry in
            Image(imageName)
            .resizable()
            .scaledToFit()
            .scaleEffect(scale)
//            .position(
//                levelPlayerModel.position(
//                    for: level,
//                    in: geometry
//                )
//            )
        }
    }
}
