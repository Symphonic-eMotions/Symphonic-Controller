//
//  EMButton.swift
//  EMButton
//
//  Created by Mihai Fratu on 31.07.2021.
//

import SwiftUI

struct EMButton<Content: View>: View {
    var action: () -> Void
    var color: Color
    var isSolid: Bool = true
    var maxWidth: CGFloat? = .infinity
    var height: CGFloat? = 50.0
    @ViewBuilder var label: () -> Content

    var body: some View {
        Button(action: action, label: {
            label()
                .padding(.horizontal)
                .frame(height: height)
                .frame(maxWidth: maxWidth)
                .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(color))
                .font(.system(size: 17).weight(.semibold))
                .foregroundColor(isSolid ? .white : color)
                .background(isSolid ? color : .clear)
                .cornerRadius(8.0)
        })
    }
}

struct EMButtonBig<Content: View>: View {
    var action: () -> Void
    var color: Color
    var isSolid: Bool = true
    var maxWidth: CGFloat? = .infinity
    var height: CGFloat? = 50.0
    @ViewBuilder var label: () -> Content

    var body: some View {
        Button(action: action, label: {
            label()
                .padding()
                .frame(height: height)
                .frame(width: maxWidth)
                .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(color))
                .font(.system(size: 80))
                .foregroundColor(isSolid ? .white : color)
                .background(isSolid ? color : .clear)
                .cornerRadius(8.0)
        })
    }
}
