//
//  Grids.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 02/04/2023.
//

import Foundation

enum Grids: CaseIterable {
    case empty
    case oneByOne
    case twoByTwo
    case threeByThree
    case fourByFour
    case fiveByFive
    
    init?(rows: Int) {
        switch rows {
        case 0:
            self = .empty
        case 1:
            self = .oneByOne
        case 2:
            self = .twoByTwo
        case 3:
            self = .threeByThree
        case 4:
            self = .fourByFour
        case 5:
            self = .fiveByFive
        default:
            return nil
        }
    }
    
    init(){
        self = Grids.empty
    }
    
    //There's just one clip in the MIDI file zo all regions trigger 0
    var oneClip: [Int] {
        switch self {
        case .empty:
            return []
        case .oneByOne:
            return [0]
        case .twoByTwo:
            return [0,0,0,0]
        case .threeByThree:
            return [0,0,0,0,0,0,0,0,0]
        case .fourByFour:
            return [
                0,0,0,0,
                0,0,0,0,
                0,0,0,0,
                0,0,0,0
            ]
        case .fiveByFive:
            return [
                0,0,0,0,0,
                0,0,0,0,0,
                0,0,0,0,0,
                0,0,0,0,0
            ]
        }
    }
}
