//
//  ProgressBarButton.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 14/03/2024.
//

import SwiftUI

struct ProgressBarButton: View {
    @Binding var value: Float
    var level: Int
    var action: (Int) -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(.secondary)

                Rectangle().frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(.accentColor)
            }.cornerRadius(30.0)
                .onTapGesture {
                    self.action(level)
                }
        }
    }
}
