//
//  SideBarItemView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 31/01/2024.
//

import SwiftUI

struct SidebarItemView: View {
    let item: (name: String, setName: String, fileGroup: FileGroup, sessionDisplay: SessionDisplay)
    let active: Bool
    @Binding var showDisabled: Bool
    
    var body: some View {
        
        HStack {
            VStack(alignment: .leading) {
                Spacer()
                Text(item.name)
                    .foregroundColor(active ? .white : .primary)
                    .font(.headline)
                    .padding(.horizontal)
                Spacer()
            }
            Spacer()
        }
        .padding(.vertical, 4.0)
        .padding(.leading, 4.0)
        .background(showDisabled ? Color.red.opacity(0.5) : (active ? Color.accentColor : .teal))
        .cornerRadius(10.0)
    }
}
