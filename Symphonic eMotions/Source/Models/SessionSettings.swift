//
//  SessionSettings.swift
//  Symphonic eMotions Intern
//
//  Created by Frans-Jan Wind on 21/10/2022.
//

import Foundation

struct StoreSessionSettings: Codable {
    
    var imageMax: Int
    var imageMaxLightPart: Int
    var imageFeedback: Float
    
    init(imageMax: Int, imageMaxLightPart: Int, imageFeedback: Float){
        self.imageMax = imageMax
        self.imageMaxLightPart = imageMaxLightPart
        self.imageFeedback = imageFeedback
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
        var storeSessionSettings: StoreSessionSettings = StoreSessionSettings(
            imageMax: 40, imageMaxLightPart: 0,  imageFeedback: 0.4)

        let pathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = pathURL[0]
        let documentURL = (documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("json"))
        
        if FileManager.default.fileExists(atPath: documentURL.path) {
            
            guard let data = try? Data(contentsOf: documentURL) else { return storeSessionSettings }
            do {
                let decoded = try JSONDecoder().decode(StoreSessionSettings.self, from: data)
                
                storeSessionSettings.imageMax = storeSessionSettings.imageMax + decoded.imageMaxLightPart
                storeSessionSettings.imageMaxLightPart = decoded.imageMaxLightPart
                storeSessionSettings.imageFeedback = decoded.imageFeedback
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

class SessionSettings: Identifiable {
    
    //End value imageMax to imageDifference
    var imageMax: Int
    
    //User input light buttons
    //Increment or decrement imageMaxLightPart with this value
    var imageMaxStepSizeLight: Int
    //How many steps in both way from zero can be made
    var imageMaxStepAmountLight: Int
    //final light value to be added to end value
    var imageMaxLightPart: Int
    
    //End value imageFeedback to imageDifference
    var imageFeedback: Float
    //Movement / distance buttons fill these
    var imageFeedbackDisctancePart: Float
    
    //How many steps does the part meter show
    var calibrationPartMeterSteps: Int
    
    init(
        imageMax: Int,
        imageMaxStepSizeLight: Int,
        imageMaxStepAmountLight: Int,
        imageMaxLightPart: Int,
        imageFeedback: Float,
        imageFeedbackDisctancePart: Float,
        calibrationPartMeterSteps: Int
    ){
        self.imageMax = imageMax
        self.imageMaxStepSizeLight = imageMaxStepSizeLight
        self.imageMaxStepAmountLight = imageMaxStepAmountLight
        self.imageMaxLightPart = imageMaxLightPart
        self.imageFeedback = imageFeedback
        self.imageFeedbackDisctancePart = imageFeedbackDisctancePart
        self.calibrationPartMeterSteps = calibrationPartMeterSteps
    }
}
