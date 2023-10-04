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
    
    func tapSavedRow(fileName: String) {
                
        let instrumentSet = AppUtils.loadSavedInstrumentSet(fileName: fileName)
        currentInstrumentsSetIsChanged(instrumentSet!)
    }

    func reloadSet(fileName: String) {
                
        let instrumentSet = AppUtils.loadSavedInstrumentSet(fileName: fileName)
        currentInstrumentsSetIsChanged(instrumentSet!)
        
        setSettings = AppUtils.setSettings(
            instrumentSet: instrumentSet!
        )
    }
}
