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
    
    init(sensitivity: Float){
        self.sensitivity = sensitivity
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
        var sessionSettings: ManageSessionSettings = ManageSessionSettings( sensitivity: sensitivity )

        let pathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = pathURL[0]
        let documentURL = (documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("json"))
        
        if FileManager.default.fileExists(atPath: documentURL.path) {
            
            guard let data = try? Data(contentsOf: documentURL) else { return sessionSettings }
            do {
                let decoded = try JSONDecoder().decode(ManageSessionSettings.self, from: data)
                sessionSettings.sensitivity = decoded.sensitivity
            }
            catch{
                print("Unexpected error InstrumentsSet withJSON: \(error).")
            }
        }
        else{
            print("FILE NOT AVAILABLE \(documentURL.path)")
            print("Sensitivity set to \(sensitivity)")
        }

        return sessionSettings
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
        let instruments = [InstrumentsSet.Skin.Instrument(
            shape: "circle",
            name: "AudioA",
            image: "AudioFile1",
            color: .white
            //UIColor(red: 151/255, green: 71/255, blue: 255/255, alpha: 1)
        ),InstrumentsSet.Skin.Instrument(
            shape: "circle",
            name: "AudioB",
            image: "AudioFile1",
            color: .white
            //UIColor(red: 124/255, green: 177/255, blue: 255/255, alpha: 1)
        ),InstrumentsSet.Skin.Instrument(
            shape: "circle",
            name: "AudioC",
            image: "AudioFile1",
            color: .white
            //UIColor(red: 0, green: 207/255, blue: 58/255, alpha: 1)
        ),InstrumentsSet.Skin.Instrument(
            shape: "circle",
            name: "AudioD",
            image: "AudioFile1",
            color: .white
            //UIColor(red: 0, green: 207/255, blue: 58/255, alpha: 1)
        )]
        
        if skin != nil {
            self.activeSkin = skin!
        }
        else {
            self.activeSkin = InstrumentsSet.Skin(name: "noname", instruments: instruments)
        }
    }
    
    //This needs to go to InstrumentSet?
    func getInstrumentColors(instrumentsSet: InstrumentsSet) -> [UIColor]{
        
        var instrumentColors: [UIColor] = []
        
        for track in instrumentsSet.tracks {
            
            instrumentColors.append(track.instrumentColor.toUIColor())
        }
        
        return instrumentColors
    }
}
