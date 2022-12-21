//
//  Genres.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 19/11/2021.
//

import Foundation

struct Genre: Decodable {
    
    static func withJSON(_ fileName: String) -> Genre? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: "Sets") else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        do {
            let decoded = try JSONDecoder().decode(Genre.self, from: data)
            return decoded
        }
        catch{
            print("Unexpected error InstrumentsSet withJSON: \(error).")
        }
        return nil
    }
    
    private enum CodingKeys: String, CodingKey {
        case name = "genreName"
    }
    
    let name: String
}

