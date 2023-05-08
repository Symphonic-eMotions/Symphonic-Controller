//
//  AreaOfInterestView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 05/05/2023.
//

import SwiftUI

struct AreaOfInterestView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    
    @Binding var areaOfInterest: [String:[Int]]
    @State var areaOfInterestColorLocal: [String:[Color]]
    
    //This is a 1 track View
    @State var trackId: String
    
    let columnWidth: CGFloat = 150
    
    init(
        setInfoModel:SetInfoModel,
        currentTrack:TrackSettings,
        trackId: String,
        areaOfInterest: Binding<[String:[Int]]>
    ){
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _areaOfInterest = areaOfInterest
        
        var tmpAreaOfColorInterest: [String:[Color]] = [:]
        for part in currentTrack.parts {
            tmpAreaOfColorInterest[part.value.partId] = part.value.areaOfInterestColor
        }
        _areaOfInterestColorLocal = State(initialValue: tmpAreaOfColorInterest)
    }
    
    //Grid interface per Part
    func activeAreasView(for part: PartSettings, gridRows: Int, gridColumns: Int) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<gridRows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<gridColumns, id: \.self) { column in
                        let cellIndex =  row * gridColumns + column
                        ZStack {
                            Rectangle()
                            .frame(width: 50, height: 50)
                            .foregroundColor(areaOfInterestColorLocal[part.partId]?[cellIndex])
                            .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                            .onTapGesture {
                                tapOnCell(cellIndex: cellIndex,partId: part.partId)
                                
                                print("\(cellIndex) \(areaOfInterestColorLocal[part.partId]![cellIndex])")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func tapOnCell(cellIndex: Int, partId: String){
        
        //Update areaOfInterest and areaOfInterestColor for storage
        if currentTrack.parts[partId]!.areaOfInterest[cellIndex] == 1 {
            currentTrack.parts[partId]!.areaOfInterest[cellIndex] = 0
            currentTrack.parts[partId]!.areaOfInterestColor[cellIndex] = .white.opacity(0.01)
        }
        else {
            currentTrack.parts[partId]!.areaOfInterest[cellIndex] = 1
            currentTrack.parts[partId]!.areaOfInterestColor[cellIndex] = currentTrack.instrumentColor
        }
        
        //Update local for interface
        areaOfInterestColorLocal[partId] = currentTrack.parts[partId]!.areaOfInterestColor
        
        //Get new connection with clip positions, for live update
        currentTrack.loopsToGridMapped = AppUtils.areaOfInterestGridMapped(
            areaOfInterest: currentTrack.parts[partId]!.areaOfInterest,
            cellsToGrid: currentTrack.loopsToGrid)
        
        //Get new connections with note positions, for live update
        currentTrack.notesToGridMapped = AppUtils.areaOfInterestGridMapped(
            areaOfInterest: currentTrack.parts[partId]!.areaOfInterest,
            cellsToGrid: currentTrack.notesToGrid)
    }
    
    struct RangeSlider: View {
        @Binding var lowerValue: Double
        @Binding var upperValue: Double
        
        var body: some View {
            GeometryReader { geometry in
                let trackWidth = geometry.size.width - 20
                let trackHeight: CGFloat = 4
                let thumbSize: CGFloat = 20
                
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray)
                        .frame(width: trackWidth, height: trackHeight)
                    Capsule()
                        .fill(Color.blue)
                        .frame(width: CGFloat(upperValue - lowerValue) * trackWidth, height: trackHeight)
                        .offset(x: CGFloat(lowerValue) * trackWidth)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: thumbSize, height: thumbSize)
                        .shadow(radius: 2)
                        .offset(x: CGFloat(lowerValue) * trackWidth - thumbSize/2)
                        .gesture(DragGesture()
                                    .onChanged { gestureValue in
                                        let newLowerValue = Double(min(max(0, gestureValue.location.x/trackWidth), upperValue))
                                        lowerValue = newLowerValue
                                    }
                        )
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: thumbSize, height: thumbSize)
                        .shadow(radius: 2)
                        .offset(x: CGFloat(upperValue) * trackWidth - thumbSize/2)
                        .gesture(DragGesture()
                                    .onChanged { gestureValue in
                                        let newUpperValue = Double(min(max(lowerValue, gestureValue.location.x/trackWidth), 1))
                                        upperValue = newUpperValue
                                    }
                        )
                }
                .frame(height: thumbSize)
            }
        }
    }
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            Divider()
            
            HStack(){
                
                Text("Active areas")
                    .frame(width: columnWidth, alignment: .leading)
                
                let gridRows: Int = setInfoModel.setSettings.gridRows
                let gridColumns: Int = setInfoModel.setSettings.gridColumns
                
                HStack(spacing: 20) {
                    
                    ForEach(Array(currentTrack.parts.enumerated()), id: \.offset ){ index, part in
                        
                        VStack {
                            
                            //Name of the Part shown
                            Text(part.value.partName)
                                .padding()
                            
                            //The gridinterface
                            activeAreasView(for: part.value, gridRows: gridRows, gridColumns: gridColumns)
                            
                            Text(part.value.damperTarget.nodeName)
                            Text(part.value.damperTarget.parameter)
                            Text(part.value.damperTarget.parameterRange.map{String($0)}.joined(separator: ","))
                        }
                    }
                }
            }
        }
        .padding(.leading)
    }
}
