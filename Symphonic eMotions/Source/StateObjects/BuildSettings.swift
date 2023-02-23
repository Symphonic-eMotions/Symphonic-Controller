//
//  BuildSettings.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 15/09/2022.
//

import Foundation

struct BuildSettings {
    
    public enum MainSetting {
        case zorg
        case muur
    }
    
    public enum ActiveView: String {
        case homeView
        case playView
        case calibration
        case dynamicView
    }
    
    //Main theme setting
    public var mainSettings: MainSetting
    //Switching between fulls screen views
    public var activeView: ActiveView
    //Show settings
    public var isAdvanced: Bool
    //Show visual feedback per part
    public var instrumentPartEditor: Bool
    //Show master track
    public var isMasterTrack: Bool
    
    init(
        mainSettings: MainSetting,
        activeView: ActiveView,
        isAdvanced: Bool,
        instrumentPartEditor: Bool,
        isMasterTrack: Bool
    ){
        self.mainSettings = mainSettings
        self.activeView = activeView
        self.isAdvanced = isAdvanced
        self.instrumentPartEditor = instrumentPartEditor
        self.isMasterTrack = isMasterTrack
    }
}
