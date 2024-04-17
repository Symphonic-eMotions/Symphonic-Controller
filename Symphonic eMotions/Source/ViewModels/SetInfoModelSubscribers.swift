//
//  SetInfoModelSubscribers.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 19/07/2023.
//

import Foundation

extension SetInfoModel {
    
    func subscribeToLevels() {
        cancellableLevels?.cancel()
        //Reset to prevend memory leak
        cancellableLevels = nil
        cancellableLevels = self.leveling.currentSetLevelSubject.sink { [weak self] value in
            
            guard let self = self else { return }

            let oldLevel = Int(self.setInfoState.currentLevel)
            self.setInfoState.currentLevel = value
            let currentLevel = Int(self.setInfoState.currentLevel)

            //On level change mute and un-mute tracks accordingly
            if oldLevel != currentLevel {
                print("SINK LEVEL CHANGE \(oldLevel) ---> \(currentLevel)")
                
                if oldLevel > currentLevel {
                    for track in self.setSettings.tracks {
                        if track.value.instrumentType == .exsSampler {
                            self.conductor.stopNotesTrackId(for: track.value.trackId)
                        }
                    }
                }
                
                // Mute and unmutes tracks to level settings
                //
                // Switch View logic sits in MainView / PlayView.onReceive
                //
                self.conductor.levelController(
                    level: Int(currentLevel),
                    setSettings: self.setSettings
                )
                
                if(currentLevel == setSettings.levels.count) {
                    
                    //Reset to level 0
                    leveling.currentSetLevelSubject.send(0)
                    
                    if(currentLevel == setSettings.levels.count) {
                        //Reset to level 0
                        leveling.currentSetLevelSubject.send(0)

                        // Set the same vars as in the isSetPlaying block
                        self.onLevelReached?()
                        
                        self.tapStopAudioEngine()
                        userSettings.isSetPlaying = false
                        self.leveling.pauseLevel = false
                    }
                }
            }
        }
    }
    
    func subscribeToImageDifference() {
        
        cancellableImageDifference?.cancel()
        cancellableImageDifference = nil
        
        cancellableImageDifference = self.imageDifference.values.sink { [weak self] values in
            
            guard let self = self else { return }

            DispatchQueue.main.async {
                
                self.setInfoState.values = values
                
                let levelValue = self.conductor.valuesDidChange(
                    // These are the main values for controlling
                    values: values,
                    // Dynamic area's of interest
                    setSettings: self.setSettings,
                    // These 3 are for advanced view monitoring
                    currentSetLevel: self.leveling.currentSetLevelSubject.value,
                    partFeedbackTrackID: self.partFeedback.currentTrackID.value,
                    partFeedbackPartID: self.partFeedback.currentPartID.value
                )
                
                if self.leveling.pauseLevel == false {
                    let newLevel = levelValue
                    let currentLevel = self.leveling.currentSetLevelSubject.value
                    if newLevel != currentLevel {
                        self.leveling.currentSetLevelSubject.send(newLevel)
                    }
                }
            }
        }
    }
    
    func subscribeToPartFeedback() {
        
        cancellablePartFeddback?.cancel()
        cancellablePartFeddback = nil
        
        cancellablePartFeddback = self.conductor.forwardRampedPartFeedback.sink { [weak self] value in
            guard let self = self else { return }
            self.partFeedbackState.ramped = Double(value)
        }
    }
}
