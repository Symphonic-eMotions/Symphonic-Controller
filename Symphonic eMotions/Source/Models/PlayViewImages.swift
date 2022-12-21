//
//  PlayViewImages.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 13/07/2022.
//

import SwiftUI

extension InstrumentsSet {
    
    struct PlayViewImages: Decodable {
        
        private enum PlayViewImagesKeys: String, CodingKey {
            case backButtonBackground
            case backButton
            case background
            case foreground
            case playViewFeedback
            case instruments
        }
        
//        enum PlayViewFeedback: String, CodingKey {
//            case sunLevel
//            case cameraInstrumenten
//            //FIXME: view toevoegen
//            case camera
//            case instrumenten
//        }
        
        let backButtonBackground: String
        let backButton: String
        let background: String
        let foreground: String
        let playViewFeedback: String?
        let instruments: [String]
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: PlayViewImagesKeys.self)
            backButtonBackground = try container.decode(String.self, forKey: .backButtonBackground)
            backButton = try container.decode(String.self, forKey: .backButton)
            background = try container.decode(String.self, forKey: .background)
            foreground = try container.decode(String.self, forKey: .foreground)
            playViewFeedback = try container.decodeIfPresent(String.self, forKey: .playViewFeedback)
            instruments = try container.decode([String].self, forKey: .instruments)
        }
    }
}

extension InstrumentsSet.PlayViewImages: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PlayViewImagesKeys.self)
        try container.encode(backButtonBackground, forKey: .backButtonBackground)
        try container.encode(backButton, forKey: .backButton)
        try container.encode(background, forKey: .background)
        try container.encode(foreground, forKey: .foreground)
        try container.encode(playViewFeedback, forKey: .playViewFeedback)
        try container.encode(instruments, forKey: .instruments)
    }
}
