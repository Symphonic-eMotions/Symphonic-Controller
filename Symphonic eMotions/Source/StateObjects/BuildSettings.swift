//
//  BuildSettings.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 15/09/2022.
//

import SwiftUI

struct BuildSettings {
    
    public enum MainSetting {
        case one
        case daytime
        case pro
        case composer
    }
    
    public enum ActiveView: String {
        case homeView
        case playView
        case calibration
        case dynamicView
    }
    
    public enum Playlists: String, CaseIterable {
        case none
        case minimal
        case person
        case group
        case nature
        
        
        var color: Color {
            switch self {
            case .none:
                return .clear
            case .minimal:
                return Color("InstrumentColor100")
            case .person:
                return Color("InstrumentColor200")
            case .group:
                return Color("InstrumentColor300")
            case .nature:
                return Color("InstrumentColor702")
            }
        }
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
