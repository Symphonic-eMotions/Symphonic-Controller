//
//  Sets.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 19/11/2021.
//

import SwiftUI

struct Sets: Decodable {
    
    static func withJSON(_ fileName: String) -> Sets? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: "Sets") else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        
        do {
            let decoded = try JSONDecoder().decode(Sets.self, from: data)
            
            return decoded
        }
        catch{
            print("Unexpected error Sets withJSON : \(error).")
        }
        
        return nil
    }
    
    let sets: [MusicSet]
}

struct MusicSet: Decodable, Hashable {
    
    private enum CodingKeys: String, CodingKey {
        case name = "setName"
        case image = "imageName"
        case imageBackground = "imageNameBackground"
        case noteNumber = "soundEffectMidiNoteNumer"
        case config = "setConfig"
        case genres = "setGenres"
        case copyright
    }
    
    var id: String { name }
    let name: String
    let image: String?
    let imageBackground: String?
    let noteNumber: Int?
    let config: String
    let genres: [String]
    let copyright: String
}
