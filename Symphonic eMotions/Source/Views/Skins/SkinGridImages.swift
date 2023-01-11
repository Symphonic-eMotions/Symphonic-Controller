//
//  SkinGridImages.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 11/01/2023.
//

import SwiftUI

struct SkinGridImages: View {
    
    @ObservedObject var playViewModel: PlayViewModel
    @ObservedObject var mainViewModel: MainViewModel
    
    var body: some View {
        
        /*
         
         Run through the grid once to find instrument locations
         
         Place images based on cell to geometry conversion
         
         */
        
        Text("Hello SkinGridImages")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
