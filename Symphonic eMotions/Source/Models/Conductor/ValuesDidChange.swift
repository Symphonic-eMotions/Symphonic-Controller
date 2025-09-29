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
        var maxScaledValue: Double = -1 // To store the maximum scaled value
        for areaValues in values {
            for value in areaValues {
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

        // Increment AND decrement level
        localCurrentSetLevel = adjustCurrentSetLevel(
            setSettings: setSettings,
            currentSetLevel: currentSetLevel,
            averageMovement: averageForLevelUpdate
        )

        // Find the maximum index (used for variation by position)
        let maxIndexTuple = vDSP.indexOfMaximum(scaledValues)
        let maxIndex = Int(maxIndexTuple.0)

        // LevelPlayer
        // Update maxIndex in SetSettings
        DispatchQueue.main.async {
            if averageForLevelUpdate < 0.08 {
                setSettings.maxIndex = -1
            } else {
                setSettings.maxIndex = maxIndex
            }
        }

        // We iterate through all tracks and its parts
        var trackNr = 0
        var partNr = 0
        for (trackIndex, track) in setSettings.tracks {
            // Reset part per track
            partNr = 0

            // Loop through all parts per track per value
            for (partIndex, part) in track.parts {
                // get current and previous value from values
                let interestIndexes = part.interestIndexes(rows: setSettings.gridRows, columns: setSettings.gridColumns)

                // Map interestIndexes naar waarden, maar controleer eerst de indices
                let valuesMapped = interestIndexes.compactMap { index -> (current: Double, previous: Double)? in
                    if index.row >= 0, index.row < values.count,
                       index.column >= 0, index.column < values[index.row].count {
                        return (current: values[index.row][index.column].scaledValue, previous: values[index.row][index.column].previousScaledValue)
                    } else {
                        // Index is buiten bereik
                        return nil
                    }
                }

                let currentValues = valuesMapped.map { $0.current }
                let previousValues = valuesMapped.map { $0.previous }

                // Find highest value (maximum) with its index
                let maxIndexPartTuple = vDSP.indexOfMaximum(currentValues)
                let maxIndexPart = Int(maxIndexPartTuple.0)
                var value = maxIndexPartTuple.1.isNaN ? 0 : maxIndexPartTuple.1
                let previousValue = previousValues.indices.contains(maxIndexPart) ? previousValues[maxIndexPart] : 0

                // MARK: Timed movement envelope (Replaced ramps and damps)

                if let envelope = timeBasedEnvelopes[partIndex] {
                    // Safe access to custom rates with default value fallback
                    let customDecreaseRate = (rampDown[partIndex] ?? 0.5) * 0.1
                    let customIncreaseRate = (rampUp[partIndex] ?? 0.5) * 0.1

                    // This is the instrument / effect controller
                    value = envelope.updateEnvelope(
                        withMovement: value,
                        previousMovement: previousValue,
                        decreaseRate: customDecreaseRate,
                        increaseRate: customIncreaseRate
                    )

                    if trackNr == 0 && partNr == 0 {
                        OSCMessageSender.shared.sendOSCMessage(
                            ipAddress: userSettings.ipAddress,
                            port: userSettings.port,
                            pattern: userSettings.pattern + "/direct",
                            value: Float(value)
                        )

                        forwardPartFeedback(
                            ramped: value
                        )
                    }
                }

                partNr += 1
            }
            trackNr += 1
        }

        return localCurrentSetLevel
    }
}
