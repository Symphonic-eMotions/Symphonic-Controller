//
//  DisplayModes.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 04/04/2022.
//

import Foundation
import SwiftUI

enum DisplayModes {
    case off
    case video
    case instruments
    case both
    case refresh
    
    var title: String {
        switch self {
        case .off:
            return "Uit"
        case .video:
            return "Video"
        case .instruments:
            return "Instrumenten"
        case .both:
            return "Beiden"
        case .refresh:
            return "Refresh"
        }
    }
    
    var icon: Image {
        switch self {
        case .off:
            return Image(systemName: "multiply")
        case .video:
            return Image(systemName: "display")
        case .instruments:
            return Image(systemName: "rectangle.grid.3x2")
        case .both:
            return Image(systemName: "2.circle.fill")
        case .refresh:
            return Image(systemName: "hourglass.bottomhalf.filled")
        }
    }
}
