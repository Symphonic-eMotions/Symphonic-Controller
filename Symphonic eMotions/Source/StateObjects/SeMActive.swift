//
//  SeMActive.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 15/09/2022.
//

import SwiftUI

struct SeMActive {
    enum Playlists: String, CaseIterable {
        case none
        case minimal
        case person
//        case group
//        case nature

        var color: Color {
            switch self {
            case .none:
                return .clear
            case .minimal:
                return Color("InstrumentColor100")
            case .person:
                return Color("InstrumentColor200")
//            case .group:
//                return Color("InstrumentColor300")
//            case .nature:
//                return Color("InstrumentColor702")
            }
        }
    }
}
