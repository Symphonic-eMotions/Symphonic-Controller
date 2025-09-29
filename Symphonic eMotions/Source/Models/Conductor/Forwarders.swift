//
//  Forwarders.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 17/04/2023.
//

import AudioKit

extension Conductor {
    public func forwardMasterTrackEffect(
        value: Double,
        nodeName: String,
        parameter: String,
        parameterRange: [Double]
    ) {
        let effectType = InstrumentsSet.Track.Effect.EffectType(rawValue: nodeName)

        let effect = set.effect(for: effectType!)

        effect!.targetAndApply(value: value, nodeName: nodeName, parameter: parameter, parameterRange: parameterRange)
    }

    // Forward Part Feedback
    func forwardPartFeedback(ramped: Double) {
        forwardRampedPartFeedback.send(ramped)
    }

    func forwardEffect(
        value: Double,
        for damperTarget: InstrumentsSet.Track.Part.DamperTarget
    ) {
//            print("start forwardEffect \(damperTarget.trackId) \(damperTarget.nodeName) \(damperTarget.parameter)")

        guard let track = set.track(for: damperTarget.trackId) else { return }

        guard let effectType = InstrumentsSet.Track.Effect.EffectType(rawValue: damperTarget.nodeName) else { return }

        guard let effect = track.effect(for: effectType) else { return }

        // inverse value if requested in dampertarget
        let valueToApply = damperTarget.parameterInversed ? 1 - value : value

//            print("APPLY \(valueToApply) to \(damperTarget.trackId) \(damperTarget.nodeName) \(damperTarget.parameter)")
//
        effect.apply(value: valueToApply, with: damperTarget)
    }

    // Forward damper data
    func forward(
        value: Double,
        for damperTarget: InstrumentsSet.Track.Part.DamperTarget,
        currentSetLevel: Double
    ) {
        switch damperTarget.nodeType {
        case .instrument:
            forwardInstrumment(value: value, on: damperTarget.trackId, for: damperTarget.parameter)
        case .sequencer:
            forwardSequencer(
                value: value,
                for: damperTarget,
                currentSetLevel: currentSetLevel
            )
        case .effect:
            forwardEffect(value: value, for: damperTarget)
        case .master:
            return
        }
    }

    func forwardInstrumment(value: Double, on trackId: String, for parameter: String) {
        switch parameter {
        case "volume":
            for track in set.tracks {
                if track.id == trackId {
                    if track.instrumentType == .exsSampler {
                        trackSamplers[trackId]?.volume = AUValue(value)
                    } else {
                        soundModuleVolume[trackId] = value
                    }
                }
            }

        case "amplitude":
            for track in set.tracks {
                if track.id == trackId {
                    let ranged = RangeConverter.valueToRange(range: [-90, 12], value: value)
                    if track.instrumentType == .exsSampler {
                        trackSamplers[trackId]?.amplitude = AUValue(ranged)
                    } else {
                        let ranged = RangeConverter.valueToRange(range: [-40, 40], value: value)
                        soundModuleVolume[trackId] = ranged
                    }
                }
            }

        case "samplerCC9":
            trackSamplers[trackId]?.midiCC(UInt8(9), value: UInt8(value * 127), channel: UInt8(1))

        default:
            print("Instrument damperTarget.parameter Not mapped: \(parameter)")
        }
    }

    func forwardSequencer(
        value: Double,
        for damperTarget: InstrumentsSet.Track.Part.DamperTarget,
        currentSetLevel: Double
    ) {
        // Parameter controllers
        switch damperTarget.parameter {
        case "velocity":
            guard let track = set.track(for: damperTarget.trackId) else { return }

            // Check wether track.id is in current level
            if track.levels.contains(Int(currentSetLevel)) {
                velocities[track.id] = value

            } else { velocities[track.id] = 0 }

        case "soundModuleParam01":
            guard let track = set.track(for: damperTarget.trackId) else { return }
            soundModuleParam01[track.id] = value

        case "soundModuleParam02":
            guard let track = set.track(for: damperTarget.trackId) else { return }
            soundModuleParam02[track.id] = value

        default:
            //                print("Sequencer damperTarget.parameter Not mapped: \(damperTarget.parameter)")
            return
        }
    }
}
