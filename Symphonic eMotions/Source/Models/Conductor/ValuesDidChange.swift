//
//  ValuesDidChange.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 17/04/2023.
//

import Accelerate
import AudioKit

extension Conductor {
    func valuesDidChange(
        // Values for movement calculations
        values: [[AreaValues]],
        // Dynamic area's of interest
        setSettings: SetSettings,
        // Is track present in current level
        currentSetLevel: Double,
        // Do we want to show this part in part feedback visualisation
        partFeedbackTrackID _: String,
        partFeedbackPartID _: String
    ) -> Double {
        // Levels are updated with movement
        var localCurrentSetLevel: Double = currentSetLevel
        
        // Flatten the 2D list and compute the sum, count and maximum in a single pass
        var sum = 0.0
        var count = 0
        var scaledValues: [Double] = []
        var maxScaledValue: Double = -1
        for areaValues in values {
            for value in areaValues {
                sum += value.average
                count += 1
                scaledValues.append(value.scaledValue)
                if value.scaledValue > maxScaledValue {
                    maxScaledValue = value.scaledValue
                }
            }
        }
        
        // Compute average
        let averageForLevelUpdate = sum / Double(count)
        
        // Increment AND decrement level
        localCurrentSetLevel = adjustCurrentSetLevel(
            setSettings: setSettings,
            currentSetLevel: currentSetLevel,
            averageMovement: averageForLevelUpdate
        )
        
        // Find the maximum index (used for variation by position)
        let maxIndexTuple = vDSP.indexOfMaximum(scaledValues)
        let maxIndex = Int(maxIndexTuple.0)
        
        // LevelPlayer - Update maxIndex in SetSettings
        DispatchQueue.main.async {
            if averageForLevelUpdate < 0.08 {
                setSettings.maxIndex = -1
            } else {
                setSettings.maxIndex = maxIndex
            }
        }
        
        // Iterate through all tracks and their parts
        var trackNr = 0
        var partNr = 0
        for (_, track) in setSettings.tracks {
            partNr = 0
            
            for (partIndex, part) in track.parts {
                // Map area-of-interest indices -> values (safe bounds)
                let interestIndexes = part.interestIndexes(rows: setSettings.gridRows, columns: setSettings.gridColumns)
                let valuesMapped = interestIndexes.compactMap { index -> (current: Double, previous: Double)? in
                    if index.row >= 0, index.row < values.count,
                       index.column >= 0, index.column < values[index.row].count {
                        return (
                            current: values[index.row][index.column].scaledValue,
                            previous: values[index.row][index.column].previousScaledValue
                        )
                    } else {
                        return nil
                    }
                }
                
                let currentValues = valuesMapped.map { $0.current }
                let previousValues = valuesMapped.map { $0.previous }
                
                // Highest value in this part
                let maxIndexPartTuple = vDSP.indexOfMaximum(currentValues)
                let maxIndexPart = Int(maxIndexPartTuple.0)
                var value = maxIndexPartTuple.1.isNaN ? 0 : maxIndexPartTuple.1
                let previousValue = previousValues.indices.contains(maxIndexPart) ? previousValues[maxIndexPart] : 0
                
                // Timed movement envelope (replaces ramps/damps)
                if let envelope = timeBasedEnvelopes[partIndex] {
                    let customDecreaseRate = (rampDown[partIndex] ?? 0.5) * 0.1
                    let customIncreaseRate = (rampUp[partIndex] ?? 0.5) * 0.1
                    
                    value = envelope.updateEnvelope(
                        withMovement: value,
                        previousMovement: previousValue,
                        decreaseRate: customDecreaseRate,
                        increaseRate: customIncreaseRate
                    )
                    
                    // 🔁 Nieuw: stuur ALTIJD per track/part door naar OSC-variant
                    // (IP/poort en pattern mapping gebeuren in valuesDidChangeToOSC)
                    self.valuesDidChangeToOSC(
                        part: part,
                        normalizedValue: Float(value)
                    )
                    
                    // Behoud je bestaande part feedback voor de "eerste" (zoals voorheen)
                    if trackNr == 0 && partNr == 0 {
                        forwardPartFeedback(ramped: value)
                    }
                }
                
                partNr += 1
            }
            trackNr += 1
        }
        
        return localCurrentSetLevel
    }
    
    func valuesDidChangeToOSC(
        part: PartSettings,
        normalizedValue: Float
    ) {
        // 4) Bepaal OSC-pattern (bijv. "/instrumentX/partY")
        let pattern = part.damperTarget.parameter // verwacht String zoals "/instrA/part1"
        guard pattern.isEmpty == false else {
            print("Conductor: leeg OSC pattern voor partId: \(part.partId) partName: \(part.partName)")
            return
        }
        
        // 5) Waarde mappen [0,1] → range (optioneel inverse)
        let clamped = max(0, min(1, normalizedValue))
        let inverted = part.parametersInversed
        
        let norm = inverted ? (1 - clamped) : clamped
        let mappedValue: Float
        mappedValue = norm
        
        guard let ip = UserDefaults.standard.string(forKey: "oscIPAddress"),
              let port = UserDefaults.standard.integer(forKey: "oscPort") as Int?,
              port > 0 else {
            print("Conductor: geen geldige OSC IP/port in UserDefaults")
            return
        }
        
        OSCMessageSender.shared.sendOSCMessage(
            ipAddress: ip,
            port: port,
            pattern: pattern,
            value: mappedValue
        )
        
    }
}
