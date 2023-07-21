//
//  ValueAndRange.swift
//  eMotion
//
//  Created by Mihai Fratu on 01.10.2021.
//

import Foundation
import AudioKit

struct ValueAndRange: Codable {
    
    static var zero: ValueAndRange { .init(value: 0, range: [0, 1]) }
    
    var value: AUValue
    var range: [Double]
}

extension ValueAndRange {
    
    enum CodingKeys: String, CodingKey {
        case value
        case range
    }
}
