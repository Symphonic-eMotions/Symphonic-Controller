//
//  SessionSettings.swift
//  Symphonic eMotions Intern
//
//  Created by Frans-Jan Wind on 21/10/2022.
//

import Foundation
import SwiftUI

struct StoreSessionSettings: Codable {
    
    var sensitivity: Float
    
    init(sensitivity: Float){
        self.sensitivity = sensitivity
    }
    
    static func writeSessionSettings(fileName: String, storeSessionSettings: StoreSessionSettings){
        
        let directoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let documentURL = (directoryURL.appendingPathComponent(fileName).appendingPathExtension("json"))
        
        print("Store file in: \(String(describing: directoryURL))")
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.sortedKeys]
        let data = try? jsonEncoder.encode(storeSessionSettings)
        do {
            try data?.write(to: documentURL, options: .noFileProtection)
        } catch {
            print("Error...Cannot save data!!!See error:(error.localizedDescription)")
        }
    }
    
    static func readSessionSettings(fileName: String) -> StoreSessionSettings {
        
        //Default settings to be over written by actual values
        var storeSessionSettings: StoreSessionSettings = StoreSessionSettings( sensitivity: 0.0 )

        let pathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = pathURL[0]
        let documentURL = (documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("json"))
        
        if FileManager.default.fileExists(atPath: documentURL.path) {
            
            guard let data = try? Data(contentsOf: documentURL) else { return storeSessionSettings }
            do {
                let decoded = try JSONDecoder().decode(StoreSessionSettings.self, from: data)
                storeSessionSettings.sensitivity = decoded.sensitivity
            }
            catch{
                print("Unexpected error InstrumentsSet withJSON: \(error).")
            }
        }
        else{
            print("FILE NOT AVAILABLE \(documentURL.path)")
        }

        return storeSessionSettings
    }
}

enum SessionDisplay: Hashable {
    
    case home
    case swiftUI
    case setInfo
    case spriteKit
    case editor
    case setEditor
    case calibrator
    case muur
    
    var title: String {
        switch self {
        case .home:
            return "SeM Home"
        case .swiftUI:
            return "Symphonic eMotions Pro"
        case .spriteKit:
            return "Game Skin"
        case .setInfo:
            return "Set information"
        case .editor:
            return "Editor"
        case .setEditor:
            return "Set editor"
        case .calibrator:
            return "Kalibrator!"
        case .muur:
            return "SeM Wall build"
        }
    }
}

class SessionSettings: Identifiable {
    
    var sensitivity: Float
    var activeSkin: InstrumentsSet.Skin
    
    init(
        sensitivity: Float,
        skin: InstrumentsSet.Skin?
    ){
        self.sensitivity = sensitivity
        
        //We go Skinning!
        let instruments:[InstrumentsSet.Skin.Instrument] = [InstrumentsSet.Skin.Instrument(
            shape: .circle,
            name: "Cello",
            image: "Cello",
            color: UIColor(red: 151/255, green: 71/255, blue: 255/255, alpha: 1)
        ),InstrumentsSet.Skin.Instrument(
            shape: .circle,
            name: "Beats",
            image: "DrumKit",
            color: UIColor(red: 124/255, green: 177/255, blue: 255/255, alpha: 1)
        ),InstrumentsSet.Skin.Instrument(
            shape: .circle,
            name: "Bassline",
            image: "Machine",
            color: UIColor(red: 0, green: 207/255, blue: 58/255, alpha: 1)
        ),InstrumentsSet.Skin.Instrument(
            shape: .circle,
            name: "Synth",
            image: "AudioFile1",
            color: UIColor(red: 0, green: 207/255, blue: 58/255, alpha: 1)
        )]
        
        if skin != nil {
            self.activeSkin = skin!
        }
        else {
            self.activeSkin = InstrumentsSet.Skin(name: .growingDots, instruments: instruments)
        }
        
        
        
        print(self.activeSkin)
        
    }
}
