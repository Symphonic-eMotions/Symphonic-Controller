//
//  SetInfoModelSetLoading.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 19/07/2023.
//

import Foundation

extension SetInfoModel {
    
    func tapSetRow(filePath: String) {
        
        let instrumentSet = AppUtils.loadInstrumentSet(json: filePath)
        currentInstrumentsSetIsChanged(instrumentSet)
    }
    
    func tapSavedRow(fileName: String, completion: (() -> Void)? = nil) {
        do {
            let instrumentSet = try AppUtils.loadSavedInstrumentSet(fileName: fileName)
            currentInstrumentsSetIsChanged(instrumentSet)
        }
        catch {
            print(error)
        }
        completion?()
    }

    func reloadSet(fileName: String) {
        
        do {
            let instrumentSet = try AppUtils.loadSavedInstrumentSet(fileName: fileName)
            currentInstrumentsSetIsChanged(instrumentSet)
            
            setSettings = AppUtils.setSettings(
                instrumentSet: instrumentSet
            )
        }
        catch {
            print(error)
        }
    }
}
