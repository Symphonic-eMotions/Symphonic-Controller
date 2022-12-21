//
//  SidebarTracksView.swift
//  Symphonic eMotions
//
//  Created by Çağatay Emekci on 17.03.2022.
//

/*
    !IMPORTANT!
 
    Because We disabled the `Edit Mode`, we didn't refactor this views.
    AppState should be removed and smaller subStates should be created and used
 

import SwiftUI

struct SidebarTracksView: View {
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Tracks")
                .font(.largeTitle)
            
            ForEach(appState.currentInstrumentsSet.tracks) { track in
                SidebarTrackView(track: track)
                    .onTapGesture {
                        appState.currentTrackPart = nil
                        appState.currentTrack = track
                    }
            }
        }
    }
}

struct SidebarTrackView: View {
    
    @EnvironmentObject var appState: AppState
    
    var track: InstrumentsSet.Track
    var isSelected: Bool {
        guard appState.currentTrackPart == nil else { return false }
        return appState.currentTrack?.id == track.id
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "guitars")
                    .frame(width: 26.0, height: 26.0)
                    .foregroundColor(isSelected ? .white : .primary)
                Text(track.instrumentName)
                    .foregroundColor(isSelected ? .white : .primary)
                    .font(.headline)
                Spacer()
            }
            .frame(height: 44.0)
            .padding(.leading, 8.0)
            .background(isSelected ? Color.accentColor : .secondary)
            .cornerRadius(10.0)
            
            if isSelected || track.parts.first(where: { appState.currentTrackPart?.id == $0.id }) != nil {
                
                ForEach(track.parts) { part in
                    SidebarTrackPartView(part: part)
                        .onTapGesture {
                            appState.currentTrackPart = part
                        }
                }
                .padding(.leading, 32.0)
                Spacer()
            }
        }
    }
}

struct SidebarTrackPartView: View {
    
    @EnvironmentObject var appState: AppState
    
    var part: InstrumentsSet.Track.Part
    var isSelected: Bool {
        appState.currentTrackPart?.id == part.id
    }
    
    var body: some View {
        HStack {
            Image(systemName: "square.grid.3x3.topleft.fill")
                .frame(width: 26.0, height: 26.0)
                .foregroundColor(isSelected ? .white : .primary)
            Text(part.instrumentPartName)
                .foregroundColor(isSelected ? .white : .primary)
                .font(.headline)
            Spacer()
        }
        .frame(height: 44.0)
        .padding(.leading, 8.0)
        .background(isSelected ? Color.accentColor : .secondary)
        .cornerRadius(10.0)
    }
    
}
 */

/*
struct SidebarTrackSliderView: View {
    
    var label: LocalizedStringKey
    @Binding var value: Float
    
    var minValue: Float = 0
    var maxValue: Float = 1
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(label)
                            .font(.headline)
                        Text("\(value)")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                    Spacer()
                    Slider(value: $value, in: minValue...maxValue)
                        .foregroundColor(.accentColor)
                        .frame(width: geometry.size.width * 0.8)
                }
                .padding(.horizontal)
                
                Rectangle()
                    .fill(Color.secondary)
                    .frame(height: 1.0)
            }
        }
        .frame(height: 60.0)
    }
}
*/
