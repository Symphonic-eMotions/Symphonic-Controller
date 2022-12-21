//
//  FeedbackObjectsView.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 19/07/2022.
//

import SwiftUI

struct FeedbackObjectsView: View {
    
    @ObservedObject var playViewModel: PlayViewModel
    
    var body: some View {
        
        Text("Suns!")
        Image("FullPlayFarmSun")
    }
}
