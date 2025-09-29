//
//  SVGImageView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 13/03/2024.
//

import SwiftUI

struct SVGImageView: View {
    var level: Int
    var imageName: String
    var scale: CGFloat
    var opacity: CGFloat

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .scaleEffect(scale)
            .opacity(opacity)
    }
}
