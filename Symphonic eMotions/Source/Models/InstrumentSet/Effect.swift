//
//  Effect.swift
//  eMotion
//
//  Created by Mihai Fratu on 30.09.2021.
//

import Foundation
import AudioKit
import SoundpipeAudioKit

protocol EffectProtocol {
    var node: Node? { get set }
    func chain(to input: Node) -> Node
    func apply(value: Double, with damperTarget: InstrumentsSet.Track.Part.DamperTarget)
    func valueAndRange(parameter: String) -> ValueAndRange?
}

extension InstrumentsSet.Track.Effect {
    init() {
        self = .bandPassFilter(BandPassFilterEffect(centerFrequency: .zero, bandwidth: .zero))
    }
}

extension InstrumentsSet.Track {
    
    enum Effect: Decodable {
        
        public enum EffectKeys: String, CodingKey {
            case effectType = "effectName"
            //BandPassFilter
            case centerFrequency
            case bandwidth
            //CostelloReverb
            case cutoffFrequencyCostello
            case feedbackCostello
            case dryWetMixer
            //Compressor effect
            case threshold
            case headRoom
            case attackTime
            case releaseTime
            case masterGain
            //Delay effect
            case time
            case feedback
            case lowPassCutoff
            case dryWetMix
            //Distortion
            case distDelay
            case distDecay
            case distDelayMix
            case distRingModFreq1
            case distRingModFreq2
            case distRingModBalance
            case distRingModMix
            case distDecimation
            case distRounding
            case distDecimationMix
            case distLinearTerm
            case distSquaredTerm
            case distCubicTerm
            case distPolynomialMix
            case distSoftClipGain
            case distFinalMix
            //DynamicRangeCompressor
            case drcAttackDuration
            case drcReleaseDuration
            case drcRatio
            case drcTreshold
            //Expander
            case expansionRatio
            case expansionThreshold
            case expanderAttackTime
            case expanderReleaseTime
            case expanderMasterGain
            //HighPassFilter
            case hpfCutoffFrequency
            case hpfResonance
            //LowPassFilter
            case cutoffFrequency
            case resonance
            //Phaser
            case phaserNotchMinimumFrequency
            case phaserNotchMaximumFrequency
            case phaserNotchWidth
            case phaserNotchFrequency
            case phaserVibratoMode
            case phaserDepth
            case phaserFeedback
            case phaserInverted
            case phaserLfoBPM
            case phaserDryWetMixer
            //PeakingParametricEqualizer
            case ppefCenterFrequency
            case ppefGain
            case ppefQ
            //ResponseReverb
            case respReverbDuration
            case respDryWetMixer
            //Reverb
            case reverbDryWetMix
            case reverbPreset
            //TanhDistortion
            case pregain
            case postgain
            case positiveShapeParameter
            case negativeShapeParameter
            case dryWetTanh
        }
        
        case bandPassFilter(BandPassFilterEffect)
        case costelloReverb(CostelloReverbEffect)
        case compressor(CompressorEffect)
        case delay(DelayEffect)
        case distortion(DistortionEffect)
        case dynamicRangeCompressor(DynamicRangeCompressorEffect)
        case expander(ExpanderEffect)
        case highPassFilter(HighPassFiltereffect)
        case lowPassFilter(LowPassFilterEffect)
        case phaser(PhaserEffect)
        case peakingParametricEqualizerFilter(PeakingParametricEqualizerFilterEffect)
        case responseReverb(ResponseReverbEffect)
        case reverb(Reverbeffect)
        case tanhDistortion(TanhDistortionEffect)
        
        //Init for encoding
        init(
            effectType: EffectType,
            parameters: [ValueAndRange]
        ) {
            let effectType = effectType
            switch effectType {
            case .bandPassFilter:
                self = .bandPassFilter(BandPassFilterEffect(centerFrequency: parameters[0], bandwidth: parameters[1]))
            case .costelloReverb:
                self = .costelloReverb(CostelloReverbEffect(feedback: parameters[0], cutoffFrequency: parameters[1], dryWetMixer: parameters[2]))
            case .compressor:
                self = .compressor(CompressorEffect(threshold: parameters[0], headRoom: parameters[1], attackTime: parameters[2], releaseTime: parameters[3], masterGain: parameters[4]))
            case .delay:
                self = .delay(DelayEffect(time: parameters[0], feedback: parameters[1], lowPassCutoff: parameters[1], dryWetMix: parameters[2]))
            case .distortion:
                self = .distortion(DistortionEffect(distDelay: parameters[0], distDecay: parameters[1], distDelayMix: parameters[2], distRingModFreq1: parameters[3], distRingModFreq2: parameters[4], distRingModBalance: parameters[5], distRingModMix: parameters[6], distDecimation: parameters[7], distRounding: parameters[8], distDecimationMix: parameters[9], distLinearTerm: parameters[10], distSquaredTerm: parameters[11], distCubicTerm: parameters[12], distPolynomialMix: parameters[13], distSoftClipGain: parameters[14], distFinalMix: parameters[15]))
            case .dynamicRangeCompressor:
                self = .dynamicRangeCompressor(DynamicRangeCompressorEffect(drcAttackDuration: parameters[0], drcReleaseDuration: parameters[1], drcRatio: parameters[2], drcTreshold: parameters[3]))
            case .expander:
                self = .expander(ExpanderEffect(expansionRatio: parameters[0], expansionThreshold: parameters[1], expanderAttackTime: parameters[2], expanderReleaseTime: parameters[3], expanderMasterGain: parameters[4]))
            case .highPassFilter:
                self = .highPassFilter(HighPassFiltereffect(hpfCutoffFrequency: parameters[0], hpfResonance: parameters[1]))
            case .lowPassFilter:
                self = .lowPassFilter(LowPassFilterEffect(cutOffFrequency: parameters[0], resonance: parameters[1]))
            case .phaser:
                self = .phaser(PhaserEffect(phaserNotchMinimumFrequency: parameters[0], phaserNotchMaximumFrequency: parameters[1], phaserNotchWidth: parameters[2], phaserNotchFrequency: parameters[3], phaserVibratoMode: parameters[4], phaserDepth: parameters[5], phaserFeedback: parameters[6], phaserInverted: parameters[7], phaserLfoBPM: parameters[8], phaserDryWetMixer: parameters[9]))
            case .peakingParametricEqualizerFilter:
                self = .peakingParametricEqualizerFilter(PeakingParametricEqualizerFilterEffect(ppefCenterFrequency: parameters[0], ppefGain: parameters[1], ppefQ: parameters[2]))
            case .responseReverb:
                self = .responseReverb(ResponseReverbEffect(respReverbDuration: parameters[0], respDryWetMixer: parameters[1]))
            case .reverb:
                self = .reverb(Reverbeffect(reverbDryWetMix: parameters[0], reverbPreset: parameters[1]))
            case .tanhDistortion:
                self = .tanhDistortion(TanhDistortionEffect(pregain: parameters[0], postgain: parameters[1], positiveShapeParameter: parameters[2], negativeShapeParameter: parameters[3], dryWetTanh: parameters[4]))
//            default: fatalError("Not implemented!")
            }
            
        }
        
        init(from decoder: Decoder) throws {
            
            let container = try decoder.container(keyedBy: EffectKeys.self)
            let effectType = try container.decode(Effect.EffectType.self, forKey: .effectType)
            
            switch effectType {
            
            case .bandPassFilter:
                let centerFrequency = try container.decode(ValueAndRange.self, forKey: .centerFrequency)
                let bandwidth = try container.decode(ValueAndRange.self, forKey: .bandwidth)
                self = .bandPassFilter(BandPassFilterEffect(centerFrequency: centerFrequency, bandwidth: bandwidth))
                
            case .costelloReverb:
                let feedbackCostello = try container.decode(ValueAndRange.self, forKey: .feedbackCostello)
                let cutoffFrequencyCostello = try container.decode(ValueAndRange.self, forKey: .cutoffFrequencyCostello)
                let dryWetMixer = try container.decode(ValueAndRange.self, forKey: .dryWetMixer)
                self = .costelloReverb(CostelloReverbEffect(feedback: feedbackCostello, cutoffFrequency: cutoffFrequencyCostello, dryWetMixer: dryWetMixer))
            
            case .compressor:
                let threshold = try container.decode(ValueAndRange.self, forKey: .threshold)
                let headRoom = try container.decode(ValueAndRange.self, forKey: .headRoom)
                let attackTime = try container.decode(ValueAndRange.self, forKey: .attackTime)
                let releaseTime = try container.decode(ValueAndRange.self, forKey: .releaseTime)
                let masterGain = try container.decode(ValueAndRange.self, forKey: .masterGain)
                self = .compressor(CompressorEffect(threshold: threshold, headRoom: headRoom, attackTime: attackTime, releaseTime: releaseTime, masterGain: masterGain))
            
            case .delay:
                let time = try container.decode(ValueAndRange.self, forKey: .time)
                let feedback = try container.decode(ValueAndRange.self, forKey: .feedback)
                let lowPassCutoff = try container.decode(ValueAndRange.self, forKey: .lowPassCutoff)
                let dryWetMix = try container.decode(ValueAndRange.self, forKey: .dryWetMix)
                self = .delay(DelayEffect(time: time, feedback: feedback, lowPassCutoff: lowPassCutoff, dryWetMix: dryWetMix))
            
            case .distortion:
                let distDelay = try container.decode(ValueAndRange.self, forKey: .distDelay)
                let distDecay = try container.decode(ValueAndRange.self, forKey: .distDecay)
                let distDelayMix = try container.decode(ValueAndRange.self, forKey: .distDelayMix)
                let distRingModFreq1 = try container.decode(ValueAndRange.self, forKey: .distRingModFreq1)
                let distRingModFreq2 = try container.decode(ValueAndRange.self, forKey: .distRingModFreq2)
                let distRingModBalance = try container.decode(ValueAndRange.self, forKey: .distRingModBalance)
                let distRingModMix = try container.decode(ValueAndRange.self, forKey: .distRingModMix)
                let distDecimation = try container.decode(ValueAndRange.self, forKey: .distDecimation)
                let distRounding = try container.decode(ValueAndRange.self, forKey: .distRounding)
                let distDecimationMix = try container.decode(ValueAndRange.self, forKey: .distDecimationMix)
                let distLinearTerm = try container.decode(ValueAndRange.self, forKey: .distLinearTerm)
                let distSquaredTerm = try container.decode(ValueAndRange.self, forKey: .distSquaredTerm)
                let distCubicTerm = try container.decode(ValueAndRange.self, forKey: .distPolynomialMix)
                let distPolynomialMix = try container.decode(ValueAndRange.self, forKey: .distSoftClipGain)
                let distSoftClipGain = try container.decode(ValueAndRange.self, forKey: .distSoftClipGain)
                let distFinalMix = try container.decode(ValueAndRange.self, forKey: .distFinalMix)
                self = .distortion(DistortionEffect(distDelay: distDelay, distDecay: distDecay, distDelayMix: distDelayMix, distRingModFreq1: distRingModFreq1, distRingModFreq2: distRingModFreq2, distRingModBalance: distRingModBalance, distRingModMix: distRingModMix, distDecimation: distDecimation, distRounding: distRounding, distDecimationMix: distDecimationMix, distLinearTerm: distLinearTerm, distSquaredTerm: distSquaredTerm, distCubicTerm: distCubicTerm, distPolynomialMix: distPolynomialMix, distSoftClipGain: distSoftClipGain, distFinalMix: distFinalMix))
                
            case .dynamicRangeCompressor:
                let drcAttackDuration = try container.decode(ValueAndRange.self, forKey: .drcAttackDuration)
                let drcReleaseDuration = try container.decode(ValueAndRange.self, forKey: .drcReleaseDuration)
                let drcRatio = try container.decode(ValueAndRange.self, forKey: .drcRatio)
                let drcTreshold = try container.decode(ValueAndRange.self, forKey: .drcTreshold)
                self = .dynamicRangeCompressor(DynamicRangeCompressorEffect(drcAttackDuration: drcAttackDuration, drcReleaseDuration: drcReleaseDuration, drcRatio: drcRatio, drcTreshold: drcTreshold))
            
            case .expander:
                let expansionRatio = try container.decode(ValueAndRange.self, forKey: .expansionRatio)
                let expansionThreshold = try container.decode(ValueAndRange.self, forKey: .expansionThreshold)
                let expanderAttackTime = try container.decode(ValueAndRange.self, forKey: .expanderAttackTime)
                let expanderReleaseTime = try container.decode(ValueAndRange.self, forKey: .expanderReleaseTime)
                let expanderMasterGain = try container.decode(ValueAndRange.self, forKey: .expanderMasterGain)
                self = .expander(ExpanderEffect(expansionRatio: expansionRatio, expansionThreshold: expansionThreshold, expanderAttackTime: expanderAttackTime, expanderReleaseTime: expanderReleaseTime, expanderMasterGain: expanderMasterGain))
                
            case .highPassFilter:
                let hpfCutoffFrequency = try container.decode(ValueAndRange.self, forKey: .hpfCutoffFrequency)
                let hpfResonance = try container.decode(ValueAndRange.self, forKey: .hpfResonance)
                self = .highPassFilter(HighPassFiltereffect(hpfCutoffFrequency: hpfCutoffFrequency, hpfResonance: hpfResonance))
                
            case .lowPassFilter:
                let cutOffFrequency = try container.decode(ValueAndRange.self, forKey: .cutoffFrequency)
                let resonance = try container.decode(ValueAndRange.self, forKey: .resonance)
                self = .lowPassFilter(LowPassFilterEffect(cutOffFrequency: cutOffFrequency, resonance: resonance))
                
            case .phaser:
                let phaserNotchMinimumFrequency = try container.decode(ValueAndRange.self, forKey: .phaserNotchMinimumFrequency)
                let phaserNotchMaximumFrequency = try container.decode(ValueAndRange.self, forKey: .phaserNotchMaximumFrequency)
                let phaserNotchWidth = try container.decode(ValueAndRange.self, forKey: .phaserNotchWidth)
                let phaserNotchFrequency = try container.decode(ValueAndRange.self, forKey: .phaserNotchFrequency)
                let phaserVibratoMode = try container.decode(ValueAndRange.self, forKey: .phaserVibratoMode)
                let phaserDepth = try container.decode(ValueAndRange.self, forKey: .phaserDepth)
                let phaserFeedback = try container.decode(ValueAndRange.self, forKey: .phaserFeedback)
                let phaserInverted = try container.decode(ValueAndRange.self, forKey: .phaserInverted)
                let phaserLfoBPM = try container.decode(ValueAndRange.self, forKey: .phaserLfoBPM)
                let phaserDryWetMixer = try container.decode(ValueAndRange.self, forKey: .phaserDryWetMixer)
                self = .phaser(PhaserEffect(phaserNotchMinimumFrequency: phaserNotchMinimumFrequency, phaserNotchMaximumFrequency: phaserNotchMaximumFrequency, phaserNotchWidth: phaserNotchWidth, phaserNotchFrequency: phaserNotchFrequency, phaserVibratoMode: phaserVibratoMode, phaserDepth: phaserDepth, phaserFeedback: phaserFeedback, phaserInverted: phaserInverted, phaserLfoBPM: phaserLfoBPM, phaserDryWetMixer: phaserDryWetMixer))
            
            case .peakingParametricEqualizerFilter:
                let ppefCenterFrequency = try container.decode(ValueAndRange.self, forKey: .ppefCenterFrequency)
                let ppefGain = try container.decode(ValueAndRange.self, forKey: .pregain)
                let ppefQ = try container.decode(ValueAndRange.self, forKey: .ppefQ)
                self = .peakingParametricEqualizerFilter(PeakingParametricEqualizerFilterEffect(ppefCenterFrequency: ppefCenterFrequency, ppefGain: ppefGain, ppefQ: ppefQ))
            
            case .responseReverb:
                let respReverbDuration = try container.decode(ValueAndRange.self, forKey: .respReverbDuration)
                let respDryWetMixer = try container.decode(ValueAndRange.self, forKey: .respDryWetMixer)
                self = .responseReverb(ResponseReverbEffect(respReverbDuration: respReverbDuration, respDryWetMixer: respDryWetMixer))
                
            case .reverb:
                let reverbDryWetMix = try container.decode(ValueAndRange.self, forKey: .reverbDryWetMix)
                let reverbPreset = try container.decode(ValueAndRange.self, forKey: .reverbPreset)
                self = .reverb(Reverbeffect(reverbDryWetMix: reverbDryWetMix, reverbPreset: reverbPreset))
                
            case .tanhDistortion:
                let pregain = try container.decode(ValueAndRange.self, forKey: .pregain)
                let postgain = try container.decode(ValueAndRange.self, forKey: .postgain)
                let positiveShapeParameter = try container.decode(ValueAndRange.self, forKey: .positiveShapeParameter)
                let negativeShapeParameter = try container.decode(ValueAndRange.self, forKey: .negativeShapeParameter)
                let dryWetTanh = try container.decode(ValueAndRange.self, forKey: .dryWetTanh)
                self = .tanhDistortion(TanhDistortionEffect(pregain: pregain, postgain: postgain, positiveShapeParameter: positiveShapeParameter, negativeShapeParameter: negativeShapeParameter, dryWetTanh: dryWetTanh))
            }
        }
    
        var effectType: EffectType {
            switch self {
                case .bandPassFilter(_): return .bandPassFilter
                case .costelloReverb(_): return .costelloReverb
                case .compressor(_): return .compressor
                case .delay(_): return .delay
                case .distortion(_): return .distortion
                case .dynamicRangeCompressor(_): return .dynamicRangeCompressor
                case .expander(_): return .expander
                case .highPassFilter(_): return .highPassFilter
                case .lowPassFilter(_): return .lowPassFilter
                case .phaser(_): return .phaser
                case .peakingParametricEqualizerFilter(_): return .peakingParametricEqualizerFilter
                case .responseReverb(_): return .responseReverb
                case .reverb(_): return .reverb
                case .tanhDistortion(_): return .tanhDistortion
            }
        }
        
        var effect: EffectProtocol {
            switch self {
                case .bandPassFilter(let effect):
                    return effect
                case .costelloReverb(let effect):
                    return effect
                case .compressor(let effect):
                    return effect
                case .delay(let effect):
                    return effect
                case .distortion(let effect):
                    return effect
                case .dynamicRangeCompressor(let effect):
                    return effect
            case .expander(let effect):
                    return effect
                case .highPassFilter(let effect):
                    return effect
                case .lowPassFilter(let effect):
                    return effect
                case .phaser(let effect):
                    return effect
                case .peakingParametricEqualizerFilter(let effect):
                    return effect
                case .responseReverb(let effect):
                    return effect
                case .reverb(let effect):
                    return effect
                case .tanhDistortion(let effect):
                    return effect
            }
        }
        
        func effectVars(effectType: EffectType) -> [EffectKeys] {
            switch effectType {
            case .bandPassFilter:
                return [.centerFrequency, .bandwidth]
            case .costelloReverb:
                return [.feedbackCostello, .cutoffFrequencyCostello, .dryWetMixer]
            case .compressor:
                return [.threshold, .headRoom, .attackTime, .releaseTime, .masterGain]
            case .delay:
                return [.time, .feedback, .lowPassCutoff, .dryWetMix]
            case .distortion:
                return [.distDelay, .distDecay, .distDelayMix, .distRingModFreq1, .distRingModFreq2, .distRingModBalance, .distRingModMix, .distDecimation, .distRounding, .distDecimationMix, .distLinearTerm, .distSquaredTerm, .distCubicTerm, .distPolynomialMix, .distSoftClipGain, .distFinalMix]
            case .dynamicRangeCompressor:
                return [.drcAttackDuration, .drcReleaseDuration, .drcRatio, .drcTreshold]
            case .expander:
                return [.expansionRatio, .expansionThreshold, .expanderAttackTime, .expanderReleaseTime, .expanderMasterGain]
            case .highPassFilter:
                return [.hpfCutoffFrequency, .hpfResonance]
            case .lowPassFilter:
                return [.cutoffFrequency, .resonance]
            case .phaser:
                return [.phaserNotchMinimumFrequency, .phaserNotchMaximumFrequency, .phaserNotchWidth, .phaserNotchFrequency, .phaserVibratoMode, .phaserDepth, .phaserFeedback, .phaserInverted, .phaserLfoBPM, .phaserDryWetMixer]
            case .peakingParametricEqualizerFilter:
                return [.ppefCenterFrequency, .ppefGain, .ppefQ]
            case .responseReverb:
                return [.respReverbDuration, .dryWetMixer]
            case .reverb:
                return [.reverbDryWetMix, .reverbPreset]
            case .tanhDistortion:
                return [.pregain, .postgain, .positiveShapeParameter, .negativeShapeParameter, .dryWetTanh]
            }
        }

        
//        static func effectVars(effectType: EffectType ) -> [String] {
//
//            switch effectType {
//
//            case .bandPassFilter: return ["centerFrequency","bandwidth"]
//            case .costelloReverb: return ["feedbackCostello","cutoffFrequencyCostello","dryWetMixer"]
//            case .compressor: return ["threshold","headRoom","attackTime","releaseTime","masterGain"]
//            case .delay: return ["time","feedback","lowPassCutoff","dryWetMix"]
//            case .distortion: return ["distDelay","distDecay","distDelayMix","distRingModFreq1","distRingModFreq2","distRingModBalance","distRingModMix","distDecimation","distRounding","distDecimationMix","distLinearTerm","distSquaredTerm","distCubicTerm","distPolynomialMix","distSoftClipGain","distFinalMix"]
//            case .dynamicRangeCompressor: return ["drcAttackDuration","drcReleaseDuration","drcRatio","drcTreshold"]
//            case .expander: return ["expansionRatio","expansionThreshold","expanderAttackTime","expanderReleaseTime","expanderMasterGain"]
//            case .highPassFilter: return ["hpfCutoffFrequency","hpfResonance"]
//            case .lowPassFilter: return ["cutoffFrequency","resonance"]
//            case .phaser: return ["phaserNotchMinimumFrequency","phaserNotchMaximumFrequency","phaserNotchWidth","phaserNotchFrequency","phaserVibratoMode","phaserDepth","phaserFeedback", "phaserInverted","phaserLfoBPM","phaserDryWetMixer"]
//            case .peakingParametricEqualizerFilter: return ["ppefCenterFrequency","ppefGain","ppefQ"]
//            case .responseReverb: return ["reverbDuration","dryWetMixer"]
//            case .reverb: return ["reverbDryWetMix","reverbPreset"]
//            case .tanhDistortion: return ["pregain","postgain","positiveShapeParameter","negativeShapeParameter","dryWetTanh"]
//            }
//        }
        
        func valueAndRanges(parameter: String) -> ValueAndRange? {
            
            return effect.valueAndRange(parameter: parameter)
        }
        
        func chain(to input: Node) -> Node {
            return effect.chain(to: input)
        }
        
        func apply(value: Double, with damperTarget: InstrumentsSet.Track.Part.DamperTarget) {
            effect.apply(value: value, with: damperTarget)
        }
        
        func targetAndApply(value: Double, nodeName: String, parameter: String, parameterRange: [Double]) {
            let damperTarget = InstrumentsSet.Track.Part.DamperTarget(
                trackIdString: "master",
                nodeNameString: nodeName,
                parameterString: parameter,
                parameterRangeArray: parameterRange)
            effect.apply(value: value, with: damperTarget)
        }
    }
}

//Effect names
extension InstrumentsSet.Track.Effect {
    
    enum EffectType: String, Codable, CaseIterable {
        case bandPassFilter
        case costelloReverb
        case compressor
        case delay
        case distortion
        case expander
        case dynamicRangeCompressor
        case highPassFilter
        case lowPassFilter
        case phaser
        case peakingParametricEqualizerFilter
        case responseReverb
        case reverb
        case tanhDistortion
    }
}

//Write to disk
extension InstrumentsSet.Track.Effect: Encodable {

    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: EffectKeys.self)

        switch self {
            
        case .bandPassFilter(let effect):
            try container.encode(effectType, forKey: .effectType)
            try container.encode(effect.centerFrequency, forKey: .centerFrequency)
            try container.encode(effect.bandwidth, forKey: .bandwidth)
        
        case .costelloReverb(let effect):
            try container.encode(effectType, forKey: .effectType)
            try container.encode(effect.feedback, forKey: .feedbackCostello)
            try container.encode(effect.cutoffFrequency, forKey: .cutoffFrequencyCostello)
            try container.encode(effect.dryWetMixer, forKey: .dryWetMixer)
            
        case .compressor(let effect):
            try container.encode(effectType, forKey: .effectType)
            try container.encode(effect.threshold, forKey: .threshold)
            try container.encode(effect.headRoom, forKey: .headRoom)
            try container.encode(effect.attackTime, forKey: .attackTime)
            try container.encode(effect.releaseTime, forKey: .releaseTime)
            try container.encode(effect.masterGain, forKey: .masterGain)
        
        case .delay(let effect):
            try container.encode(effectType, forKey: .effectType)
            try container.encode(effect.time, forKey: .time)
            try container.encode(effect.feedback, forKey: .feedback)
            try container.encode(effect.lowPassCutoff, forKey: .lowPassCutoff)
            try container.encode(effect.dryWetMix, forKey: .dryWetMix)
            
        case .distortion(let effect):
            try container.encode(effectType, forKey: .effectType)
            try container.encode(effect.distDelay, forKey: .distDelay)
            try container.encode(effect.distDecay, forKey: .distDecay)
            try container.encode(effect.distDelayMix, forKey: .distDelayMix)
            try container.encode(effect.distRingModFreq1, forKey: .distRingModFreq1)
            try container.encode(effect.distRingModFreq2, forKey: .distRingModFreq2)
            try container.encode(effect.distRingModBalance, forKey: .distRingModBalance)
            try container.encode(effect.distRingModMix, forKey: .distRingModMix)
            try container.encode(effect.distDecimation, forKey: .distDecimation)
            try container.encode(effect.distRounding, forKey: .distRounding)
            try container.encode(effect.distDecimationMix, forKey: .distDecimationMix)
            try container.encode(effect.distLinearTerm, forKey: .distLinearTerm)
            try container.encode(effect.distSquaredTerm, forKey: .distSquaredTerm)
            try container.encode(effect.distCubicTerm, forKey: .distCubicTerm)
            try container.encode(effect.distPolynomialMix, forKey: .distPolynomialMix)
            try container.encode(effect.distSoftClipGain, forKey: .distSoftClipGain)
            try container.encode(effect.distFinalMix, forKey: .distFinalMix)
        
        case .dynamicRangeCompressor(let effect):
            try container.encode(effectType, forKey: .effectType)
            try container.encode(effect.drcAttackDuration, forKey: .drcAttackDuration)
            try container.encode(effect.drcReleaseDuration, forKey: .drcReleaseDuration)
            try container.encode(effect.drcRatio, forKey: .drcRatio)
            try container.encode(effect.drcTreshold, forKey: .drcTreshold)
        
        case .expander(let effect):
            try container.encode(effectType, forKey: .effectType)
            try container.encode(effect.expansionRatio, forKey: .expansionRatio)
            try container.encode(effect.expansionThreshold, forKey: .expansionThreshold)
            try container.encode(effect.expanderAttackTime, forKey: .expanderAttackTime)
            try container.encode(effect.expanderReleaseTime, forKey: .expanderReleaseTime)
            try container.encode(effect.expanderMasterGain, forKey: .expanderMasterGain)
        
        case .highPassFilter(let effect):
            try container.encode(effectType, forKey: .effectType)
            try container.encode(effect.hpfCutoffFrequency, forKey: .hpfCutoffFrequency)
            try container.encode(effect.hpfResonance, forKey: .hpfResonance)
            
        case .lowPassFilter(let effect):
            try container.encode(effectType, forKey: .effectType)
            try container.encode(effect.cutOffFrequency, forKey: .cutoffFrequency)
            try container.encode(effect.resonance, forKey: .resonance)
            
        case .phaser(let effect):
            try container.encode(effectType, forKey: .effectType)
            try container.encode(effect.phaserNotchMinimumFrequency, forKey: .phaserNotchMinimumFrequency)
            try container.encode(effect.phaserNotchMaximumFrequency, forKey: .phaserNotchMaximumFrequency)
            try container.encode(effect.phaserNotchWidth, forKey: .phaserNotchWidth)
            try container.encode(effect.phaserNotchFrequency, forKey: .phaserNotchFrequency)
            try container.encode(effect.phaserVibratoMode, forKey: .phaserVibratoMode)
            try container.encode(effect.phaserDepth, forKey: .phaserDepth)
            try container.encode(effect.phaserFeedback, forKey: .phaserFeedback)
            try container.encode(effect.phaserInverted, forKey: .phaserInverted)
            try container.encode(effect.phaserLfoBPM, forKey: .phaserLfoBPM)
            try container.encode(effect.phaserDryWetMixer, forKey: .phaserDryWetMixer)
            
        case .peakingParametricEqualizerFilter(let effect):
            try container.encode(effectType, forKey: .effectType)
            try container.encode(effect.ppefCenterFrequency, forKey: .ppefCenterFrequency)
            try container.encode(effect.ppefQ, forKey: .ppefQ)
            try container.encode(effect.ppefGain, forKey: .ppefGain)
            
        case .responseReverb(let effect):
            try container.encode(effectType, forKey: .effectType)
            try container.encode(effect.respReverbDuration, forKey: .respReverbDuration)
            try container.encode(effect.respDryWetMixer, forKey: .respDryWetMixer)
        
        case .reverb(let effect):
            try container.encode(effectType, forKey: .effectType)
            try container.encode(effect.reverbDryWetMix, forKey: .reverbDryWetMix)
            try container.encode(effect.reverbPreset, forKey: .reverbPreset)
                                 
        case .tanhDistortion(let effect):
            try container.encode(effectType, forKey: .effectType)
            try container.encode(effect.pregain, forKey: .pregain)
            try container.encode(effect.postgain, forKey: .postgain)
            try container.encode(effect.positiveShapeParameter, forKey: .positiveShapeParameter)
            try container.encode(effect.negativeShapeParameter, forKey: .negativeShapeParameter)
            try container.encode(effect.dryWetTanh, forKey: .dryWetTanh)
        
//        default:
//            fatalError("Not implemented!")
        
        }
    }
}

