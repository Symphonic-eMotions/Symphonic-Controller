//
//  PlayListsView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 04/05/2023.
//

import SwiftUI

struct PlayListsView: View {
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.gray)
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity / 2)
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.gray)
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity / 2)
        }
        .padding(10)
    }
}
