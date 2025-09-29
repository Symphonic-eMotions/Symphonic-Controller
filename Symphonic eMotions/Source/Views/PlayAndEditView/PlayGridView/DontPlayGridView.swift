//
//  DontPlayGridView.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 04/04/2022.
//

import SwiftUI

struct DontPlayGridView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7.0)
                .fill(Color.black)
                .overlay(RoundedRectangle(cornerRadius: 7.0).stroke(Color("GridBorderColor")))
                .cornerRadius(7.0)
            Image("LogoGrey")
        }.aspectRatio(1.77777, contentMode: .fit)
    }
}
