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
        values: [[AreaValues]],
        setSettings: SetSettings,
        currentSetLevel: Double,
        partFeedbackTrackID _: String,
        partFeedbackPartID _: String
    ) -> Double {
        // Levels updaten (ongewijzigd)
        var localCurrentSetLevel: Double = currentSetLevel

        var sum = 0.0, count = 0
        var scaledValues: [Double] = []
        scaledValues.reserveCapacity(values.count * (values.first?.count ?? 0))

        var maxScaledValue: Double = -1
        for row in values {
            for v in row {
                sum += v.average
                count += 1
                let s = v.scaledValue
                scaledValues.append(s)
                if s > maxScaledValue { maxScaledValue = s }
            }
        }

        let averageForLevelUpdate = sum / Double(max(count, 1))

        localCurrentSetLevel = adjustCurrentSetLevel(
            setSettings: setSettings,
            currentSetLevel: currentSetLevel,
            averageMovement: averageForLevelUpdate
        )

        let maxIndex = Int(vDSP.indexOfMaximum(scaledValues).0)

        // Alleen updaten als het verandert (minder main-thread churn)
        let newMax = (averageForLevelUpdate < 0.08) ? -1 : maxIndex
        if setSettings.maxIndex != newMax {
            DispatchQueue.main.async {
                setSettings.maxIndex = newMax
            }
        }

        // ✅ OSC: één message per track, met alle part-waarden als floats
        let ip = userSettings.ipAddress
        let port = userSettings.port
        guard !ip.isEmpty, (1...65535).contains(port) else {
            print("Conductor: geen geldige OSC endpoint (ip=\(ip), port=\(port))")
            return localCurrentSetLevel
        }

        var trackNr = 0
        for (_, track) in setSettings.tracks {
            // 1) Bepaal pattern
            let trackAddr = "/\(track.trackId)"
            // 2) Verzamel per part de genormaliseerde waarde (in volgorde)
            var floatArgs: [Float] = []
            floatArgs.reserveCapacity(track.parts.count)

            var partNr = 0
            for (partIndex, part) in track.parts {
                // AOI → waardes (bounds-safe)
                let idxs = part.interestIndexes(rows: setSettings.gridRows, columns: setSettings.gridColumns)
                let mapped = idxs.compactMap { idx -> (cur: Double, prev: Double)? in
                    guard idx.row >= 0, idx.row < values.count,
                          idx.column >= 0, idx.column < values[idx.row].count else { return nil }
                    return (values[idx.row][idx.column].scaledValue,
                            values[idx.row][idx.column].previousScaledValue)
                }

                let currents = mapped.map { $0.cur }
                let previous = mapped.map { $0.prev }

                let maxTuple = vDSP.indexOfMaximum(currents)
                let peakIdx  = Int(maxTuple.0)
                var value    = maxTuple.1.isNaN ? 0 : maxTuple.1
                let prevVal  = previous.indices.contains(peakIdx) ? previous[peakIdx] : 0

                if let env = timeBasedEnvelopes[partIndex] {
                    let dec = (rampDown[partIndex] ?? 0.5) * 0.1
                    let inc = (rampUp[partIndex] ?? 0.5) * 0.1
                    value = env.updateEnvelope(
                        withMovement: value,
                        previousMovement: prevVal,
                        decreaseRate: dec,
                        increaseRate: inc
                    )

                    // normaliseren [0,1] (+ invert indien nodig)
                    let clamped = max(0, min(1, value))
                    let norm = part.parametersInversed ? (1 - clamped) : clamped
                    floatArgs.append(Float(norm))

                    // behoud je bestaande feedback voor eerste track/part
                    if trackNr == 0 && partNr == 0 {
                        forwardPartFeedback(ramped: value)
                    }
                } else {
                    // Geen envelope -> beschouw als 0 om arity consistent te houden
                    floatArgs.append(0)
                }
                partNr += 1
            }

            // 3) Verstuur één message: /stapX [f f f f ...]
            if !floatArgs.isEmpty {
                OSCMessageSender.shared.sendOSCMessage(
                    ipAddress: ip,
                    port: port,
                    pattern: trackAddr,
                    values: floatArgs
                )
                // Debug:
                // print("OSC \(ip) \(trackAddr) \(floatArgs)")
            }

            trackNr += 1
        }

        return localCurrentSetLevel
    }
}
