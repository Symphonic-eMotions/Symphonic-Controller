//
//  Aantekeningen.swift
//  Symphonic eMotions MVP
//
//  Created by Frans-Jan Wind on 16/11/2023.
//

import AudioKit
import Accelerate

extension Conductor {
    
    internal var timeBasedEnvelopes: [String: TimeBasedEnvelope] = [:]
    
    internal func valuesDidChange(
        //Values for movement calculations
        values: [[AreaValues]],
        //Dynamic area's of interest
        setSettings: SetSettings,
        //Is track present in current level
        currentSetLevel: Double,
        //Do we want to show this part in part feedback visualisation
        partFeedbackTrackID: String,
        partFeedbackPartID: String
    ) -> Double {
        
        //Levels are updated with movement
        var localCurrentSetLevel: Double = currentSetLevel

        // Flatten the 2D list and compute the sum, count and maximum in a single pass
        var sum = 0.0
        var count = 0
        var scaledValues: [Double] = []
        var maxScaledValue: Double = -1  // To store the maximum scaled value
        values.forEach { areaValues in
            areaValues.forEach { value in
                sum += value.average
                count += 1
                scaledValues.append(value.scaledValue)
                
                // Update maxScaledValue if it's either nil or smaller than the current scaledValue
                if value.scaledValue > maxScaledValue {
                    maxScaledValue = value.scaledValue
                }
            }
        }

        // Compute average
        let averageForLevelUpdate = sum / Double(count)
        
        // Update the current level
        localCurrentSetLevel = getAndOrIncreaseCurrentSetLevel(currentSetLevel: currentSetLevel, value: averageForLevelUpdate)
        

        // Find the maximum index (used for variation by position)
        let maxIndexTuple = vDSP.indexOfMaximum(scaledValues)
        let maxIndex = Int(maxIndexTuple.0)
        
        //We iterate through all tracks and its parts
        var trackNr: Int = 0
        var partNr: Int = 0
        setSettings.tracks.forEach { (trackIndex,track) in
            
            //Reset part per track
            partNr = 0
            
            //Loop through all parts per track per value
            track.parts.forEach { (partIndex,part) in
                
                print("partIndex: \(partIndex)");
                
                //We get the value from the areas of interest
                let valuesMapped = part.interestIndexes(
                    rows: setSettings.gridRows,
                    columns: setSettings.gridColumns).map {
                        values[$0.row][$0.column].scaledValue
                }
                
                //Find highest value (maximum) with it's index
                let maxIndexPartTupple = vDSP.indexOfMaximum(valuesMapped)
                                
                //Have a var for MaxIndex to number of MidiClips range
                let maxIndexPart = Int(maxIndexPartTupple.0)
                
                //MaxMapped (highest value found in all of AreaOfInterest) value to work with
                var value = maxIndexPartTupple.1
                if value.isNaN {
                    value = 0
                }
                
                //MARK: Timed movement envelope
                let partIdentifier = "\(trackNr)-\(partNr)"
                let envelope = timeBasedEnvelopes[partIdentifier] ?? TimeBasedEnvelope()
                
                // Haal de custom rates op, met standaardwaarden als fallback
//                let customDecreaseRate = rampDown[partIdentifier] ?? 0.1 // Standaard decreaseRate
//                let customIncreaseRate = rampUp[partIdentifier] ?? 0.2 // Standaard increaseRate
                let customDecreaseRate =  0.05 // Standaard decreaseRate
                let customIncreaseRate = 0.05 // Standaard increaseRate
                
                // Pas de logica aan voor previousMovement
                valueTimeBased = envelope.updateEnvelope(
                    withMovement: value,
                    previousMovement: valuePrevious,
                    decreaseRate: customDecreaseRate,
                    increaseRate: customIncreaseRate
                )
                
                //All parts
                //Forward to target
                forward(
                    value: valueTimeBased,
                    for: part.damperTarget,
                    currentSetLevel: localCurrentSetLevel
                )
                
                partNr += 1
            }
            trackNr += 1
        }
        
        return localCurrentSetLevel
    }
}


//
//struct SideBarView: View {
//    
//    @AppStorage(UserDefaultsKeys.isSetPlaying) var isSetPlaying: Bool = false
//    
//    @ObservedObject var setInfoModel: SetInfoModel
//    @Binding var sessionDisplay: SessionDisplay
//    @Binding var sessionDisplaySub: SessionDisplay
//
//    init(
//        setInfoModel: SetInfoModel
//        
//    ) {
//        self.setInfoModel = setInfoModel
//        
//    }
//    
//    var body: some View {
//        
//        NavigationView {
//            List {
//                
//                ForEach(viewModel.getSetFiles(for: getFileGroup(for: selectedMainItem))) { setFile in
//                    SetFileButtonView(
//                        setFile: setFile,
//                        selectedSet: $selectedSet,
//                        sessionDisplay: $sessionDisplay,
//                        sessionDisplaySub: $sessionDisplaySub,
//                        setInfoLocalState: $setInfoModel.setInfoLocalState,
//                        setInfoModel: setInfoModel
//                    )
//                }
//            }
//            .navigationTitle(setInfoModel.setInfoLocalState.sideBarHead)
//        }
//        VStack {
//            Text(semVersionString()).foregroundColor(.gray)
//        }
//    }
//    
//}
//
//struct SidebarItemView: View {
//    let item: (name: String, setName: String, fileGroup: FileGroup, sessionDisplay: SessionDisplay)
//    let active: Bool
//    @Binding var showDisabled: Bool
//    
//    var body: some View {
//        
//        HStack {
//            VStack(alignment: .leading) {
//                Spacer()
//                Text(item.name)
//                    .foregroundColor(active ? .white : .primary)
//                    .font(.headline)
//                    .padding(.horizontal)
//                Spacer()
//            }
//            Spacer()
//        }
//        .padding(.vertical, 4.0)
//        .padding(.leading, 4.0)
//        .background(showDisabled ? Color.red.opacity(0.5) : (active ? Color.accentColor : .teal))
//        .cornerRadius(10.0)
//    }
//}
//
//struct SetFileButtonView: View {
//    let setFile: SetFile
//    @Binding var selectedSet: SetFile?
//    @Binding var sessionDisplay: SessionDisplay
//    @Binding var sessionDisplaySub: SessionDisplay
//    @Binding var setInfoLocalState: SetInfoLocalState
//    @State private var showDisabled: Bool = false
//    var setInfoModel: SetInfoModel
//    var body: some View {
//        Button(action: {}) {
//            HStack {
//                VStack(alignment: .leading) {
//                    Spacer()
//                    Text(setFile.name)
//                        .foregroundColor(selectedSet == setFile ? .white : .primary)
//                        .font(.headline)
//                        .padding(.horizontal)
//                    Spacer()
//                }
//                Spacer()
//            }
//            .padding(.vertical, 4.0)
//            .padding(.leading, 4.0)
//            .background( showDisabled ? Color.red.opacity(0.5) : (selectedSet == setFile ? Color.accentColor : .secondary))
//            .cornerRadius(10.0)
//        }
//        .onTapGesture {
//            //Deactivate navigation when sessionDisplaySub in these views
//            if [.setEditor,.playListEditor,.playing].contains(sessionDisplaySub) {
//                withAnimation {
//                    // Fade to red and back
//                    let fadeDur = 0.25
//                    withAnimation(.easeInOut(duration: fadeDur)) {
//                        self.showDisabled = true
//                    }
//                    DispatchQueue.main.asyncAfter(deadline: .now() + fadeDur) {
//                        withAnimation(.easeInOut(duration: fadeDur)) {
//                            self.showDisabled = false
//                        }
//                    }
//                }
//            }
//            //Defaultnavigation behaviour
//            else{
//                selectedSet = setFile
//                setInfoModel.tapStopAudioEngine()
//                
//                setInfoLocalState.setName = setFile.name
//                setInfoLocalState.setConfig = setFile.url.lastPathComponent
//                setInfoLocalState.setURL = setFile.url.absoluteString
//                
//                if sessionDisplay == .pro {
//                    sessionDisplaySub = .pro
//                }
//                if sessionDisplay == .creator {
//                    sessionDisplaySub = .creator
//                }
//                
//                sessionDisplay = .setInfo
//            }
//        }
//    }
//}
