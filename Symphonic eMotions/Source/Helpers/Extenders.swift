//
//  Extenders.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 29/03/2023.
//

import Foundation

extension URL {
    init(_ string: String) {
        self.init(string: "\(string)")!
    }
}

extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
