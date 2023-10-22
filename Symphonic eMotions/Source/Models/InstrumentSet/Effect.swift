//
//  Effect.swift
//  eMotion
//
//  Created by Mihai Fratu on 30.09.2021.
//

import Foundation
import AudioKit
import SoundpipeAudioKit

protocol AudioProcessingEffect {
//    var node: Node? { get set }
    func chain(to input: Node) -> Node
    func apply(value: Double, with damperTarget: InstrumentsSet.Track.Part.DamperTarget)
    func valueAndRange(parameter: String) -> ValueAndRange?
}

extension InstrumentsSet.Track.Effect {
    init() {
        self = .bandPassFilter(BandPassFilterEffect(centerFrequency: .zero, bandwidth: .zero))
    }
}

extension InstrumentsSet.Track.Effect.EffectKeys: CaseIterable {
    static var allCases: [InstrumentsSet.Track.Effect.EffectKeys] {
        return [
            .effectType,
            .centerFrequency,
            .bandwidth,
            .cutoffFrequencyCostello,
            .feedbackCostello,
            .dryWetMixer,
            .threshold,
            .headRoom,
            .attackTime,
            .releaseTime,
            .masterGain,
            .time,
            .feedback,
            .lowPassCutoff,
            .dryWetMix,
            .distDelay,
            .distDecay,
            .distDelayMix,
            .distRingModFreq1,
            .distRingModFreq2,
            .distRingModBalance,
            .distRingModMix,
            .distDecimation,
            .distRounding,
            .distDecimationMix,
            .distLinearTerm,
            .distSquaredTerm,
            .distCubicTerm,
            .distPolynomialMix,
            .distSoftClipGain,
            .distFinalMix,
            .drcAttackDuration,
            .drcReleaseDuration,
            .drcRatio,
            .drcTreshold,
            .expansionRatio,
            .expansionThreshold,
            .expanderAttackTime,
            .expanderReleaseTime,
            .expanderMasterGain,
            .hpfCutoffFrequency,
            .hpfResonance,
            .cutoffFrequency,
            .resonance,
            .phaserNotchMinimumFrequency,
            .phaserNotchMaximumFrequency,
            .phaserNotchWidth,
            .phaserNotchFrequency,
            .phaserVibratoMode,
            .phaserDepth,
            .phaserFeedback,
            .phaserInverted,
            .phaserLfoBPM,
            .phaserDryWetMixer,
            .ppefCenterFrequency,
            .ppefGain,
            .ppefQ,
            .respReverbDuration,
            .respDryWetMixer,
            .reverbDryWetMix,
            .reverbPreset,
            .pregain,
            .postgain,
            .positiveShapeParameter,
            .negativeShapeParameter,
            .dryWetTanh,
            .volume
        ]
    }
    
    public var description: String {
        switch self {
        case .effectType:
            return "Effect Type"
        case .centerFrequency:
            return "Center Frequency"
        case .bandwidth:
            return "Bandwidth"
        case .cutoffFrequencyCostello:
            return "Cutoff Frequency (Costello)"
        case .feedbackCostello:
            return "Feedback (Costello)"
        case .dryWetMixer:
            return "Dry/Wet Mixer"
        case .threshold:
            return "Threshold"
        case .headRoom:
            return "Head Room"
        case .attackTime:
            return "Attack Time"
        case .releaseTime:
            return "Release Time"
        case .masterGain:
            return "Master Gain"
        case .time:
            return "Time"
        case .feedback:
            return "Feedback"
        case .lowPassCutoff:
            return "Low-Pass Cutoff"
        case .dryWetMix:
            return "Dry/Wet Mix"
        case .distDelay:
            return "Delay"
        case .distDecay:
            return "Decay"
        case .distDelayMix:
            return "Delay Mix"
        case .distRingModFreq1:
            return "Ring Mod Frequency 1"
        case .distRingModFreq2:
            return "Ring Mod Frequency 2"
        case .distRingModBalance:
            return "Ring Mod Balance"
        case .distRingModMix:
            return "Ring Mod Mix"
        case .distDecimation:
            return "Decimation"
        case .distRounding:
            return "Rounding"
        case .distDecimationMix:
            return "Decimation Mix"
        case .distLinearTerm:
            return "Linear Term"
        case .distSquaredTerm:
            return "Squared Term"
        case .distCubicTerm:
            return "Cubic Term"
        case .distPolynomialMix:
            return "Polynomial Mix"
        case .distSoftClipGain:
            return "Soft Clip Gain"
        case .distFinalMix:
            return "Final Mix"
        case .drcAttackDuration:
            return "Attack Duration"
        case .drcReleaseDuration:
            return "Release Duration"
        case .drcRatio:
            return "Ratio"
        case .drcTreshold:
            return "Threshold"
        case .expansionRatio:
            return "Expansion Ratio"
        case .expansionThreshold:
            return "Expansion Threshold"
        case .expanderAttackTime:
            return "Attack Time"
        case .expanderReleaseTime:
            return "Release Time"
        case .expanderMasterGain:
            return "Master Gain"
        case .hpfCutoffFrequency:
            return "Cutoff Frequency"
        case .hpfResonance:
            return "Resonance"
        case .cutoffFrequency:
            return "Cutoff Frequency"
        case .resonance:
            return "Resonance"
        case .phaserNotchMinimumFrequency:
            return "Notch Minimum Frequency"
        case .phaserNotchMaximumFrequency:
            return "Notch Maximum Frequency"
        case .phaserNotchWidth:
            return "Notch Width"
        case .phaserNotchFrequency:
            return "Notch Frequency"
        case .phaserVibratoMode:
            return "Vibrato Mode"
        case .phaserDepth:
            return "Depth"
        case .phaserFeedback:
            return "Feedback"
        case .phaserInverted:
            return "Inverted"
        case .phaserLfoBPM:
            return "LFO BPM"
        case .phaserDryWetMixer:
            return "Dry/Wet Mixer"
        case .ppefCenterFrequency:
            return "Peaking Parametric EQ Center Frequency"
        case .ppefGain:
            return "Peaking Parametric EQ Gain"
        case .ppefQ:
            return "Peaking Parametric EQ Q"
        case .respReverbDuration:
            return "Response Reverb Duration"
        case .respDryWetMixer:
            return "Response Reverb Dry/Wet Mixer"
        case .reverbDryWetMix:
            return "Reverb Dry/Wet Mix"
        case .reverbPreset:
            return "Reverb Preset"
        case .pregain:
            return "Pre-gain"
        case .postgain:
            return "Post-gain"
        case .positiveShapeParameter:
            return "Positive Shape Parameter"
        case .negativeShapeParameter:
            return "Negative Shape Parameter"
        case .dryWetTanh:
            return "Dry/Wet Tanh"
        case .volume:
            return "Volume"
        }
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
            //MixerEffect
            case volume
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
        case mixer(MixerEffect)
        case phaser(PhaserEffect)
        case peakingParametricEqualizerFilter(PeakingParametricEqualizerFilterEffect)
        case responseReverb(ResponseReverbEffect)
        case reverb(Reverbeffect)
        case tanhDistortion(TanhDistortionEffect)
        case none(NoneEffect)
        
        //Init for encoding
        init(
            effectType: EffectType,
            parameters: [ValueAndRange]
        ) {
            let effectType = effectType
            switch effectType {
            case .bandPassFilter:
                self = .bandPassFilter(BandPassFilterEffect(
                    centerFrequency: parameters[0],
                    bandwidth: parameters[1]
                ))
            case .costelloReverb:
                self = .costelloReverb(CostelloReverbEffect(
                    feedback: parameters[0],
                    cutoffFrequency: parameters[1],
                    dryWetMixer: parameters[2]
                ))
            case .compressor:
                self = .compressor(CompressorEffect(
                    threshold: parameters[0],
                    headRoom: parameters[1],
                    attackTime: parameters[2],
                    releaseTime: parameters[3],
                    masterGain: parameters[4]
                ))
            case .delay:
                self = .delay(DelayEffect(
                    time: parameters[0],
                    feedback: parameters[1],
                    lowPassCutoff: parameters[2],
                    dryWetMix: parameters[3]
                ))
            case .distortion:
                self = .distortion(DistortionEffect(
                    distDelay: parameters[0],
                    distDecay: parameters[1],
                    distDelayMix: parameters[2],
                    distRingModFreq1: parameters[3],
                    distRingModFreq2: parameters[4],
                    distRingModBalance: parameters[5],
                    distRingModMix: parameters[6],
                    distDecimation: parameters[7],
                    distRounding: parameters[8],
                    distDecimationMix: parameters[9],
                    distLinearTerm: parameters[10],
                    distSquaredTerm: parameters[11],
                    distCubicTerm: parameters[12],
                    distPolynomialMix: parameters[13],
                    distSoftClipGain: parameters[14],
                    distFinalMix: parameters[15]
                ))
            case .dynamicRangeCompressor:
                self = .dynamicRangeCompressor(DynamicRangeCompressorEffect(
                    drcAttackDuration: parameters[0],
                    drcReleaseDuration: parameters[1],
                    drcRatio: parameters[2], 
                    drcTreshold: parameters[3]
                ))
            case .expander:
                self = .expander(ExpanderEffect(
                    expansionRatio: parameters[0],
                    expansionThreshold: parameters[1],
                    expanderAttackTime: parameters[2],
                    expanderReleaseTime: parameters[3],
                    expanderMasterGain: parameters[4]
                ))
            case .highPassFilter:
                self = .highPassFilter(HighPassFiltereffect(
                    hpfCutoffFrequency: parameters[0],
                    hpfResonance: parameters[1]
                ))
            case .lowPassFilter:
                self = .lowPassFilter(LowPassFilterEffect(
                    cutOffFrequency: parameters[0],
                    resonance: parameters[1]
                ))
            case .mixer:
                self = .mixer(MixerEffect(
                    volume: parameters[0]))
            case .phaser:
                self = .phaser(PhaserEffect(
                    phaserNotchMinimumFrequency: parameters[0],
                    phaserNotchMaximumFrequency: parameters[1],
                    phaserNotchWidth: parameters[2],
                    phaserNotchFrequency: parameters[3],
                    phaserVibratoMode: parameters[4],
                    phaserDepth: parameters[5],
                    phaserFeedback: parameters[6],
                    phaserInverted: parameters[7],
                    phaserLfoBPM: parameters[8],
                    phaserDryWetMixer: parameters[9]
                ))
            case .peakingParametricEqualizerFilter:
                self = .peakingParametricEqualizerFilter(PeakingParametricEqualizerFilterEffect(
                    ppefCenterFrequency: parameters[0],
                    ppefGain: parameters[1],
                    ppefQ: parameters[2]
                ))
            case .responseReverb:
                self = .responseReverb(ResponseReverbEffect(
                    respReverbDuration: parameters[0],
                    respDryWetMixer: parameters[1]
                ))
            case .reverb:
                self = .reverb(Reverbeffect(
                    reverbDryWetMix: parameters[0],
                    reverbPreset: parameters[1]
                ))
            case .tanhDistortion:
                self = .tanhDistortion(TanhDistortionEffect(
                    pregain: parameters[0],
                    postgain: parameters[1],
                    positiveShapeParameter: parameters[2],
                    negativeShapeParameter: parameters[3],
                    dryWetTanh: parameters[4]
                ))
            case .none:
                self = .none(NoneEffect())
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
            
            case .mixer:
                let volume = try container.decode(ValueAndRange.self, forKey: .volume)
                self = .mixer(MixerEffect(volume: volume))
                
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
            case .none:
                self = .none(NoneEffect())
            }
        }
    
        var effectType: EffectType {
            switch self {
            case .bandPassFilter: return .bandPassFilter
            case .costelloReverb: return .costelloReverb
            case .compressor: return .compressor
            case .delay: return .delay
            case .distortion: return .distortion
            case .dynamicRangeCompressor: return .dynamicRangeCompressor
            case .expander: return .expander
            case .highPassFilter: return .highPassFilter
            case .lowPassFilter: return .lowPassFilter
            case .mixer: return .mixer
            case .phaser: return .phaser
            case .peakingParametricEqualizerFilter: return .peakingParametricEqualizerFilter
            case .responseReverb: return .responseReverb
            case .reverb: return .reverb
            case .tanhDistortion: return .tanhDistortion
            case .none: return .none
            }
        }
        
        var effect: AudioProcessingEffect {
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
                case .mixer(let effect):
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
                case .none(let effect):
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
            case .mixer:
                return [.volume]
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
            case .none:
                return []
            }
        }
        
        //Obsolete due to EffectKeys init mapping??
//        func effectParameterValue( parameterType: EffectKeys ) -> ValueAndRange {
//            switch parameterType {
//            case .effectType:
//                return ValueAndRange.zero
//            //BandPassFilter
//            case .centerFrequency:
//                return ValueAndRange(value: 5000, range: [20, 22050]) // Frequency usually in Hz
//            case .bandwidth:
//                return ValueAndRange(value: 600, range: [100, 12000])  // Bandwidth usually in Hz
//            //CostelloReverb
//            case .cutoffFrequencyCostello:
//                return ValueAndRange(value: 20000, range: [12, 20000]) // Frequency usually in Hz
//            case .feedbackCostello:
//                return ValueAndRange(value: 0.5, range: [0, 1]) // Feedback usually between 0-1
//            case .dryWetMixer:
//                return ValueAndRange(value: 0.5, range: [0, 1])  // dryWetMixer usually between 0-1
//            //Compressor effect
//            case .threshold:
//                return ValueAndRange(value: -5, range: [-40, 20]) // Threshold usually in dB
//            case .headRoom:
//                return ValueAndRange(value: 4, range: [0.1, 40]) // HeadRoom usually between 0-1
//            case .attackTime:
//                return ValueAndRange(value: 0.001, range: [0.0001, 0.2]) // AttackTime usually between 0-1 seconds
//            case .releaseTime:
//                return ValueAndRange(value: 0.05, range: [0.01, 0.2]) // ReleaseTime usually between 0-1 seconds
//            case .masterGain:
//                return ValueAndRange(value: 10, range: [-40, 40])  // MasterGain usually in dB
//            //Delay effect
//            case .time:
//                return ValueAndRange(value: 0.417, range: [0, 2]) // Time usually in seconds
//            case .feedback:
//                return ValueAndRange(value: 0.5, range: [0, 1]) // Feedback usually between 0-1
//            case .lowPassCutoff:
//                return ValueAndRange(value: 440, range: [10, 20000]) // Frequency usually in Hz
//            case .dryWetMix:
//                return ValueAndRange(value: 0.5, range: [0, 1]) // dryWetMix usually between 0-1
//            //Distortion
//            case .distDelay:
//                return ValueAndRange(value: 0.1, range: [0.1, 500]) // distDelay
//            case .distDecay:
//                return ValueAndRange(value: 1.0, range: [0.1, 50]) // distDecay
//            case .distDelayMix:
//                return ValueAndRange(value: 50, range: [0, 100]) // distDelayMix
//            case .distRingModFreq1:
//                return ValueAndRange(value: 100, range: [0.5, 8000]) // distRingModFreq1
//            case .distRingModFreq2:
//                return ValueAndRange(value: 100, range: [0.5, 8000]) // distRingModFreq2
//            case .distRingModBalance:
//                return ValueAndRange(value: 50, range: [0, 100]) // distRingModBalance
//            case .distRingModMix:
//                return ValueAndRange(value: 0, range: [0, 100]) // distRingModMix
//            case .distDecimation:
//                return ValueAndRange(value: 50, range: [0, 100]) // distDecimation
//            case .distRounding:
//                return ValueAndRange(value: 0, range: [0, 100]) // distRounding
//            case .distDecimationMix:
//                return ValueAndRange(value: 50, range: [0, 100]) // distDecimationMix
//            case .distLinearTerm:
//                return ValueAndRange(value: 50, range: [0, 100]) // distLinearTerm
//            case .distSquaredTerm:
//                return ValueAndRange(value: 50, range: [0, 100]) // distSquaredTerm
//            case .distCubicTerm:
//                return ValueAndRange(value: 50, range: [0, 100]) // distCubicTerm
//            case .distPolynomialMix:
//                return ValueAndRange(value: 50, range: [0, 100]) // distPolynomialMix
//            case .distSoftClipGain:
//                return ValueAndRange(value: -6, range: [-80, 20]) // distSoftClipGain
//            case .distFinalMix:
//                return ValueAndRange(value: 50, range: [0, 100]) // distFinalMix
//            //DynamicRangeCompressor
//            case .drcAttackDuration:
//                return ValueAndRange(value: 0.01, range: [0, 1]) // AttackDuration usually between 0-1 seconds
//            case .drcReleaseDuration:
//                return ValueAndRange(value: 0.1, range: [0, 1]) // ReleaseDuration usually between 0-1 seconds
//            case .drcRatio:
//                return ValueAndRange(value: 20, range: [0.01, 100]) // Ratio usually a value > 1
//            case .drcTreshold:
//                return ValueAndRange(value: -15, range: [-100, 0]) // Threshold usually in dB
//            //Expander
//            case .expansionRatio:
//                return ValueAndRange(value: 2, range: [1, 50]) // ExpansionRatio typically > 1
//            case .expansionThreshold:
//                return ValueAndRange(value: 2, range: [1, 50]) // ExpansionThreshold typically in dB
//            case .expanderAttackTime:
//                return ValueAndRange(value: 0.001, range: [0.0001, 0.2]) // AttackTime typically between 0-1 seconds
//            case .expanderReleaseTime:
//                return ValueAndRange(value: 0.05, range: [0.01, 3]) // ReleaseTime typically between 0-1 seconds
//            case .expanderMasterGain:
//                return ValueAndRange(value: 0, range: [-40, 40]) // MasterGain typically in dB
//            //HighPassFilter
//            case .hpfCutoffFrequency:
//                return ValueAndRange(value: 6900, range: [20, 22050]) // CutoffFrequency typically in Hz
//            case .hpfResonance:
//                return ValueAndRange(value: 0, range: [-20, 40]) // Resonance typically between 0-1
//            //LowPassFilter
//            case .cutoffFrequency:
//                return ValueAndRange(value: 6900, range: [10, 22050]) // CutoffFrequency typically in Hz
//            case .resonance:
//                return ValueAndRange(value: 0, range: [-20, 40]) // Resonance typically between 0-1
//            //Phaser
//            case .phaserNotchMinimumFrequency:
//                return ValueAndRange(value: 100, range: [20, 5000]) //phaserNotchMinimumFrequency
//            case .phaserNotchMaximumFrequency:
//                return ValueAndRange(value: 1800, range: [20, 10000]) //phaserNotchMaximumFrequency
//            case .phaserNotchWidth:
//                return ValueAndRange(value: 1000, range: [10, 5000]) //phaserNotchWidth
//            case .phaserNotchFrequency:
//                return ValueAndRange(value: 1.5, range: [1.1, 4.0]) //phaserNotchFrequency
//            case .phaserVibratoMode:
//                return ValueAndRange(value: 1, range: [0, 1]) //phaserVibratoMode
//            case .phaserDepth:
//                return ValueAndRange(value: 1, range: [0, 1]) //phaserDepth
//            case .phaserFeedback:
//                return ValueAndRange(value: 0, range: [0, 1]) //phaserFeedback
//            case .phaserInverted:
//                return ValueAndRange(value: 0, range: [0, 1]) //phaserInverted
//            case .phaserLfoBPM:
//                return ValueAndRange(value: 30, range: [24, 360]) //phaserLfoBPM
//            case .phaserDryWetMixer:
//                return ValueAndRange(value: 0.5, range: [0, 1]) //phaserDryWetMixer
//            //PeakingParametricEqualizer
//            case .ppefCenterFrequency:
//                return ValueAndRange(value: 1000, range: [12, 20000]) // Center Frequency typically in Hz
//            case .ppefGain:
//                return ValueAndRange(value: 1, range: [0.0, 10]) // Gain typically in dB
//            case .ppefQ:
//                return ValueAndRange(value: 0.707, range: [0.0, 2.0]) // Q (Quality factor) typically > 0
//            //ResponseReverb
//            case .respReverbDuration:
//                return ValueAndRange(value: 0.5, range: [0, 10]) // Reverb Duration typically in seconds
//            case .respDryWetMixer:
//                return ValueAndRange(value: 0.5, range: [0, 1]) // DryWetMixer typically between 0 (dry) and 1 (wet)
//            //Reverb
//            case .reverbDryWetMix:
//                return ValueAndRange(value: 0.5, range: [0, 1]) // DryWetMix
//            case .reverbPreset:
//                return ValueAndRange(value: 8, range: [0, 12]) // Preset selection
//            //TanhDistortion
//            case .pregain:
//                return ValueAndRange(value: 2, range: [0, 10]) // PreGain
//            case .postgain:
//                return ValueAndRange(value: 0.5, range: [0, 10]) // PostGain
//            case .positiveShapeParameter:
//                return ValueAndRange(value: 0.0, range: [-10, 10]) // positiveShapeParameter
//            case .negativeShapeParameter:
//                return ValueAndRange(value: 0.0, range: [-10, 10]) // negativeShapeParameter
//            case .dryWetTanh:
//                return ValueAndRange(value: 0.5, range: [0, 1]) // DryWetTanh
//            //MixerEffect
//            case .volume:
//                return ValueAndRange(value: 0.69, range: [0, 1]) // Volume typically between 0 (mute) and 1 (max)
//            }
//        }
        
        
        func effectParameterValues(effectType: EffectType) -> [ValueAndRange] {
            switch effectType {
            case .bandPassFilter:
                // Parameters: centerFrequency, bandwidth
                return [
                    ValueAndRange(value: 5000, range: [20, 22050]), // Frequency usually in Hz
                    ValueAndRange(value: 600, range: [100, 12000])  // Bandwidth usually in Hz
                ]
            case .costelloReverb:
                // Parameters: feedbackCostello, cutoffFrequencyCostello, dryWetMixer
                return [
                    ValueAndRange(value: 0.5, range: [0, 1]), // Feedback usually between 0-1
                    ValueAndRange(value: 20000, range: [12, 20000]), // Frequency usually in Hz
                    ValueAndRange(value: 0.5, range: [0, 1])  // dryWetMixer usually between 0-1
                ]
            case .compressor:
                // Parameters: threshold, headRoom, attackTime, releaseTime, masterGain
                return [
                    ValueAndRange(value: -5, range: [-40, 20]), // Threshold usually in dB
                    ValueAndRange(value: 4, range: [0.1, 40]), // HeadRoom usually between 0-1
                    ValueAndRange(value: 0.001, range: [0.0001, 0.2]), // AttackTime usually between 0-1 seconds
                    ValueAndRange(value: 0.05, range: [0.01, 0.2]), // ReleaseTime usually between 0-1 seconds
                    ValueAndRange(value: 10, range: [-40, 40])  // MasterGain usually in dB
                ]
            case .delay:
                // Parameters: time, feedback, lowPassCutoff, dryWetMix
                return [
                    ValueAndRange(value: 0.417, range: [0, 2]), // Time usually in seconds
                    ValueAndRange(value: 50, range: [-100, 100]), // Feedback this one -100-100
                    ValueAndRange(value: 440, range: [10, 20000]), // Frequency usually in Hz
                    ValueAndRange(value: 0.5, range: [0, 1]) // dryWetMix usually between 0-1
                ]
            case .distortion:
                return [
                    ValueAndRange(value: 0.1, range: [0.1, 500]), // distDelay
                    ValueAndRange(value: 1.0, range: [0.1, 50]), // distDecay
                    ValueAndRange(value: 50, range: [0, 100]), // distDelayMix
                    ValueAndRange(value: 100, range: [0.5, 8000]), // distRingModFreq1
                    ValueAndRange(value: 100, range: [0.5, 8000]), // distRingModFreq2
                    ValueAndRange(value: 50, range: [0, 100]), // distRingModBalance
                    ValueAndRange(value: 0, range: [0, 100]), // distRingModMix
                    ValueAndRange(value: 50, range: [0, 100]), // distDecimation
                    ValueAndRange(value: 0, range: [0, 100]), // distRounding
                    ValueAndRange(value: 50, range: [0, 100]), // distDecimationMix
                    ValueAndRange(value: 50, range: [0, 100]), // distLinearTerm
                    ValueAndRange(value: 50, range: [0, 100]), // distSquaredTerm
                    ValueAndRange(value: 50, range: [0, 100]), // distCubicTerm
                    ValueAndRange(value: 50, range: [0, 100]), // distPolynomialMix
                    ValueAndRange(value: -6, range: [-80, 20]), // distSoftClipGain
                    ValueAndRange(value: 50, range: [0, 100]), // distFinalMix
                ]
            case .dynamicRangeCompressor:
                // Parameters: drcAttackDuration, drcReleaseDuration, drcRatio, drcThreshold
                return [
                    ValueAndRange(value: 0.01, range: [0, 1]), // AttackDuration usually between 0-1 seconds
                    ValueAndRange(value: 0.1, range: [0, 1]), // ReleaseDuration usually between 0-1 seconds
                    ValueAndRange(value: 20, range: [0.01, 100]), // Ratio usually a value > 1
                    ValueAndRange(value: -15, range: [-100, 0]) // Threshold usually in dB
                ]
            case .expander:
                // Parameters: expansionRatio, expansionThreshold, expanderAttackTime, expanderReleaseTime, expanderMasterGain
                return [
                    ValueAndRange(value: 2, range: [1, 50]), // ExpansionRatio typically > 1
                    ValueAndRange(value: 2, range: [1, 50]), // ExpansionThreshold typically in dB
                    ValueAndRange(value: 0.001, range: [0.0001, 0.2]), // AttackTime typically between 0-1 seconds
                    ValueAndRange(value: 0.05, range: [0.01, 3]), // ReleaseTime typically between 0-1 seconds
                    ValueAndRange(value: 0, range: [-40, 40]) // MasterGain typically in dB
                ]
            case .highPassFilter:
                // Parameters: hpfCutoffFrequency, hpfResonance
                return [
                    ValueAndRange(value: 20, range: [20, 22050]), // CutoffFrequency typically in Hz
                    ValueAndRange(value:-20, range: [-20, 40]) // Resonance typically between 0-1
                ]
            case .lowPassFilter:
                // Parameters: cutoffFrequency, resonance
                return [
                    ValueAndRange(value: 22050, range: [10, 22050]), // CutoffFrequency typically in Hz
                    ValueAndRange(value: -20, range: [-20, 40]) // Resonance typically between 0-1
                ]
            case .mixer:
                // Parameter: volume
                return [
                    ValueAndRange(value: 0.69, range: [0, 1]) // Volume typically between 0 (mute) and 1 (max)
                ]
            case .phaser:
                // Parameters: phaserNotchMinimumFrequency, phaserNotchMaximumFrequency, phaserNotchWidth,
                // phaserNotchFrequency, phaserVibratoMode, phaserDepth, phaserFeedback, phaserInverted,
                // phaserLfoBPM, phaserDryWetMixer
                return [
                    ValueAndRange(value: 100, range: [20, 5000]), //phaserNotchMinimumFrequency
                    ValueAndRange(value: 1800, range: [20, 10000]), //phaserNotchMaximumFrequency
                    ValueAndRange(value: 1000, range: [10, 5000]), //phaserNotchWidth
                    ValueAndRange(value: 1.5, range: [1.1, 4.0]), //phaserNotchFrequency
                    ValueAndRange(value: 1, range: [0, 1]), //phaserVibratoMode
                    ValueAndRange(value: 1, range: [0, 1]), //phaserDepth
                    ValueAndRange(value: 0, range: [0, 1]), //phaserFeedback
                    ValueAndRange(value: 0, range: [0, 1]), //phaserInverted
                    ValueAndRange(value: 30, range: [24, 360]), //phaserLfoBPM
                    ValueAndRange(value: 0.5, range: [0, 1]) //phaserDryWetMixer
                ]
            case .peakingParametricEqualizerFilter:
                // Parameters: ppefCenterFrequency, ppefGain, ppefQ
                return [
                    ValueAndRange(value: 1000, range: [12, 20000]), // Center Frequency typically in Hz
                    ValueAndRange(value: 1, range: [0.0, 10]), // Gain typically in dB
                    ValueAndRange(value: 0.707, range: [0.0, 2.0]) // Q (Quality factor) typically > 0
                ]
            case .responseReverb:
                // Parameters: respReverbDuration, dryWetMixer
                return [
                    ValueAndRange(value: 0.5, range: [0, 10]), // Reverb Duration typically in seconds
                    ValueAndRange(value: 0.5, range: [0, 1]) // DryWetMixer typically between 0 (dry) and 1 (wet)
                ]
            case .reverb:
                // Parameters: reverbDryWetMix, reverbPreset
                return [
                    ValueAndRange(value: 0.5, range: [0, 1]), // DryWetMix
                    ValueAndRange(value: 8, range: [0, 12]) // Preset selection
                ]
            case .tanhDistortion:
                // Parameters: pregain, postgain, positiveShapeParameter, negativeShapeParameter, dryWetTanh
                return [
                    ValueAndRange(value: 2, range: [0, 10]), // PreGain
                    ValueAndRange(value: 0.5, range: [0, 10]), // PostGain
                    ValueAndRange(value: 0.0, range: [-10, 10]), // positiveShapeParameter
                    ValueAndRange(value: 0.0, range: [-10, 10]), // negativeShapeParameter
                    ValueAndRange(value: 0.5, range: [0, 1]) // DryWetTanh
                ]
            case .none:
                return []
            }
        }

        
        func valueAndRanges(parameter: String) -> ValueAndRange? {
            
            return effect.valueAndRange(parameter: parameter)
        }
        
        func chain(to input: Node) -> Node {
            return effect.chain(to: input)
        }
        
        func apply(value: Double, with damperTarget: InstrumentsSet.Track.Part.DamperTarget) {
            effect.apply(value: value, with: damperTarget)
        }
        
        func targetAndApply(
            value: Double,
            nodeName: String,
            parameter: String,
            parameterRange: [Double]
        ) {
            let damperTarget = InstrumentsSet.Track.Part.DamperTarget(
                trackIdString: "master",
                nodeNameString: nodeName,
                parameterString: parameter,
                parameterRangeArray: parameterRange,
                parameterInversedBool: false
            )
            effect.apply(value: value, with: damperTarget)
        }
    }
}

//Effect names
extension InstrumentsSet.Track.Effect {
    
    enum EffectType: String, Codable, CaseIterable {
        case none
        case bandPassFilter
        case costelloReverb
        case compressor
        case delay
        case distortion
        case expander
        case dynamicRangeCompressor
        case highPassFilter
        case lowPassFilter
        case mixer
        case phaser
        case peakingParametricEqualizerFilter
        case responseReverb
        case reverb
        case tanhDistortion
        
        var description: String {
            switch self {
            case .none:
                return "None"
            case .bandPassFilter:
                return "Band Pass Filter"
            case .costelloReverb:
                return "Costello Reverb"
            case .compressor:
                return "Compressor"
            case .delay:
                return "Delay"
            case .distortion:
                return "Distortion"
            case .expander:
                return "Expander"
            case .dynamicRangeCompressor:
                return "Dynamic Range Compressor"
            case .highPassFilter:
                return "High Pass Filter"
            case .lowPassFilter:
                return "Low Pass Filter"
            case .mixer:
                return "Amplitude"
            case .phaser:
                return "Phaser"
            case .peakingParametricEqualizerFilter:
                return "Peaking Parametric Equalizer Filter"
            case .responseReverb:
                return "Response Reverb"
            case .reverb:
                return "Reverb"
            case .tanhDistortion:
                return "Tanh Distortion"
            }
        }
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
        
        case .mixer(let effect):
            try container.encode(effectType, forKey: .effectType)
            try container.encode(effect.volume, forKey: .volume)
            
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
        
        case .none(_):
            try container.encode(effectType, forKey: .effectType)
        
//        default:
//            fatalError("Not implemented!")
        
        }
    }
}

