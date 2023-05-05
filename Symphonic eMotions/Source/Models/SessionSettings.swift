//
//  SessionSettings.swift
//  Symphonic eMotions Intern
//
//  Created by Frans-Jan Wind on 21/10/2022.
//

import Foundation
import SwiftUI

struct ManageSessionSettings: Codable {
    
    var sensitivity: Float
    var setURL: URL?
    
    init(sensitivity: Float, setURL: URL){
        self.sensitivity = sensitivity
        self.setURL = setURL
    }
    
    static func writeSessionSettings(fileName: String, storeSessionSettings: ManageSessionSettings){
        
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
    
    static func readSessionSettings(fileName: String) -> ManageSessionSettings {
        
        //Default settings to be over written by actual values
        let sensitivity: Float = 0.55
        var sessionSettings: ManageSessionSettings = ManageSessionSettings( sensitivity: sensitivity, setURL: URL("readSessionSettings.json") )

        let pathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = pathURL[0]
        let documentURL = (documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("json"))
        
        if FileManager.default.fileExists(atPath: documentURL.path) {
            
            guard let data = try? Data(contentsOf: documentURL) else { return sessionSettings }
            do {
                let decoded = try JSONDecoder().decode(ManageSessionSettings.self, from: data)
                sessionSettings.sensitivity = decoded.sensitivity
                sessionSettings.setURL = decoded.setURL
            }
            catch{
                print("Unexpected error readSessionSettings withJSON: \(error).")
            }
        }
        else{
            print("FILE NOT AVAILABLE \(documentURL.path)")
            print("Sensitivity set to \(sensitivity)")
        }

        return sessionSettings
    }
}

//SessionDisplay is used for navigating the SwiftUI view
//For the editor this same enum is used for SessionDisplaySub navigation
enum SessionDisplay: Hashable, Codable {
    
    case home
    case playlists
    case swiftUI
    case setInfo
    case spriteKit
    case editor
    case setEditor
    case calibrator
    case muur
    case none
    
    var title: String {
        switch self {
        case .home:
            return "SeM Home"
        case .playlists:
            return "Playlists"
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
        case .none:
            return "Nothing"
        }
    }
}

class SessionSettings: Identifiable {
    
    var sensitivity: Float
    var setURL: URL

    init(
        sensitivity: Float,
        setURL: URL

    ){
        self.sensitivity = sensitivity
        self.setURL = setURL
    }
}
