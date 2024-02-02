//
//  SetFile.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 31/01/2024.
//

import SwiftUI

struct SetFile: Identifiable, Decodable, Equatable {
    let id: UUID? = UUID()
    let name: String
    let url: URL
    let published: Bool
    let semVersion: String
    let smootherVersion: Int
    let fileGroup: FileGroup

    private enum CodingKeys: String, CodingKey {
        case name, url, published, semVersion, smootherVersion, fileGroup
    }
    
    func isCompatibleWithVersion() -> ComparisonResult {
        let staticVersion = "2.7.0"
        return AppUtils.compareVersions(version1: semVersion, version2: staticVersion)
    }
}
