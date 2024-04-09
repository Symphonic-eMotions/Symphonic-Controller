//
//  UserViews.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 05/04/2024.
//

enum UserView: String, Codable, CaseIterable, Identifiable {
    
    case playView = "PlayView"
    case levelPlayer = "LevelPlayer"
    case gridView = "GridView"
    case columnView = "ColumnView"
    case homeView = "Home"
    
    var id: Self { self }
    
    var readableName: String {
        switch self {
        case .playView:
            return "Speelweergave"
        case .levelPlayer:
            return "Niveauspeler"
        case .gridView:
            return "Rasterweergave"
        case .columnView:
            return "Kolomweergave"
        case .homeView:
            return "Home/Introductie"
        }
    }
}
