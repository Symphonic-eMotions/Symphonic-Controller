//
//  SelectUserViews.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 05/04/2024.
//

import SwiftUI

struct SelectUserViews: View {
    @ObservedObject var setInfoModel: SetInfoModel
    @State private var userViewsLocal: [UserView]

    init(setInfoModel: SetInfoModel) {
        self.setInfoModel = setInfoModel
        _userViewsLocal = State(initialValue: setInfoModel.setSettings.userViews)
    }

    var body: some View {
        List {
            ForEach(UserView.allCases, id: \.self) { viewType in
                HStack {
                    Text(viewType.readableName)
                    Spacer()
                    Checkbox(
                        isChecked: userViewsLocal.contains(viewType),
                        onChanged: { newValue in
                            updateUserViews(viewType, newValue: newValue)
                        }
                    )
                }
            }
        }
    }

    private func updateUserViews(_ viewType: UserView, newValue: Bool) {
        if newValue {
            if !userViewsLocal.contains(viewType) {
                userViewsLocal.append(viewType)
            }
        } else {
            userViewsLocal.removeAll { $0 == viewType }
        }
        setInfoModel.setSettings.userViews = userViewsLocal // Update de externe bron na wijzigingen
    }
}

struct Checkbox: View {
    var isChecked: Bool
    let onChanged: (Bool) -> Void

    var body: some View {
        Image(systemName: isChecked ? "checkmark.square" : "square")
            .onTapGesture {
                self.onChanged(!self.isChecked) // Toggle de isChecked waarde
            }
            .foregroundColor(.blue) // Optioneel: Verandert de kleur voor betere zichtbaarheid
    }
}
