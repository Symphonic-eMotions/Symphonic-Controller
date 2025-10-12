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
        // 1) Level-berekening (zoals voorheen)
        var localCurrentSetLevel = currentSetLevel

        var sum = 0.0, count = 0
        var scaledValues: [Double] = []
        scaledValues.reserveCapacity(values.count * (values.first?.count ?? 0))

        for row in values {
            for v in row {
                sum += v.average
                count += 1
                let s = v.scaledValue
                scaledValues.append(s)
            }
        }

        let averageForLevelUpdate = sum / Double(max(count, 1))
        localCurrentSetLevel = adjustCurrentSetLevel(
            setSettings: setSettings,
            currentSetLevel: currentSetLevel,
            averageMovement: averageForLevelUpdate
        )

        let maxIndex = Int(vDSP.indexOfMaximum(scaledValues).0)
        let newMax = (averageForLevelUpdate < 0.08) ? -1 : maxIndex
        if setSettings.maxIndex != newMax {
            DispatchQueue.main.async { setSettings.maxIndex = newMax }
        }

        // 2) Endpoints check
        let ip = userSettings.ipAddress
        let port = userSettings.port
        guard !ip.isEmpty, (1...65535).contains(port) else {
            print("Conductor: geen geldige OSC endpoint (ip=\(ip), port=\(port))")
            return localCurrentSetLevel
        }

        // 3) Per track één message met alle parts
        var trackNr = 0
        for (_, track) in setSettings.tracks {
            // Adres: "/stapX" o.b.v. trackId
            let trackAddr = track.trackId.hasPrefix("/") ? track.trackId : "/\(track.trackId)"

            var floatArgs: [Float] = []
            floatArgs.reserveCapacity(track.parts.count)

            var partNr = 0
            for (_, part) in track.parts {
                // AOI → waardes
                let idxs = part.interestIndexes(rows: setSettings.gridRows, columns: setSettings.gridColumns)
                let mapped = idxs.compactMap { idx -> (cur: Double, prev: Double)? in
                    guard idx.row >= 0, idx.row < values.count,
                          idx.column >= 0, idx.column < values[idx.row].count else { return nil }
                    return (values[idx.row][idx.column].scaledValue,
                            values[idx.row][idx.column].previousScaledValue)
                }

                // ruwe part-waarde = maximum binnen AOI
                let currents = mapped.map { $0.cur }
                let maxTuple  = vDSP.indexOfMaximum(currents)
                let rawValue  = maxTuple.1.isNaN ? 0.0 : maxTuple.1

                // 4) Smoothing per part met ramps (0…1 → kleine stapgrootte)
                let partId = part.partId
                let key = RampKey.part(track.trackId, partId)

                // Sliderwaarden (0..1), fallback 0.5
                let upSlider   = rampUp[key]   ?? 0.5
                let downSlider = rampDown[key] ?? 0.5

                // Frame-interval (20 fps ≈ 0.05s). Zet dit evt. als property als je framerate variabel is.
                let dt: Double = 1.0 / 20.0

                // Map slider -> tau via omgekeerde log (sneller gevoel aan top)
                // - slider 0.0  => traagste (tauMax)
                // - slider 1.0  => snelste (tauMin)
                func sliderToTau(_ s: Double, tauMin: Double = 0.05, tauMax: Double = 2.0, curve: Double = 1.2) -> Double {
                    // clamp
                    let x = max(0.0, min(1.0, s))
                    // optionele curve voor betere gevoeligheid
                    let t = pow(x, curve)
                    return tauMax + (tauMin - tauMax) * t
                }

                let tauUp   = sliderToTau(upSlider)     // bij 1.0 ~ 0.05s → super responsief
                let tauDown = sliderToTau(downSlider)   // bij 1.0 ~ 0.05s → super responsief

                // Per-frame gain
                let alphaUp   = 1.0 - exp(-dt / tauUp)
                let alphaDown = 1.0 - exp(-dt / tauDown)

                let prev = smoothedPartValues[partId] ?? rawValue
                let alpha = (rawValue >= prev) ? alphaUp : alphaDown

                let smoothed = max(0, min(1, prev + (rawValue - prev) * alpha))

                // 5) Publiceren voor UI feedback
                DispatchQueue.main.async { [weak self] in
                    self?.latestPartValues[partId] = smoothed
                }

                // 6) Inversie + verzamel als float
                let norm = part.parametersInversed ? (1 - smoothed) : smoothed
                floatArgs.append(Float(norm))

                // 7) Smoothing-state bijwerken
                smoothedPartValues[partId] = smoothed

                // bestaande feedback voor eerste track/part
                if trackNr == 0 && partNr == 0 { forwardPartFeedback(ramped: smoothed) }

                partNr += 1
            }

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
