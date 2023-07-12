//
//  DistortionEffect.swift
//  Symphonic eMotions Intern
//
//  Created by Frans-Jan Wind on 06/10/2022.
//

import Foundation
import AudioKit

class DistortionEffect: AudioProcessingEffect {
    
    /// Initialize the distortion node
    ///
    /// - parameter input: Input node to process
    /// - parameter delay: Delay (Milliseconds) ranges from 0.1 to 500 (Default: 0.1)
    /// - parameter decay: Decay (Rate) ranges from 0.1 to 50 (Default: 1.0)
    /// - parameter delayMix: Delay Mix (Percent) ranges from 0 to 100 (Default: 50)
    /// - parameter ringModFreq1: Ring Mod Freq1 (Hertz) ranges from 0.5 to 8000 (Default: 100)
    /// - parameter ringModFreq2: Ring Mod Freq2 (Hertz) ranges from 0.5 to 8000 (Default: 100)
    /// - parameter ringModBalance: Ring Mod Balance (Percent) ranges from 0 to 100 (Default: 50)
    /// - parameter ringModMix: Ring Mod Mix (Percent) ranges from 0 to 100 (Default: 0)
    /// - parameter decimation: Decimation (Percent) ranges from 0 to 100 (Default: 50)
    /// - parameter rounding: Rounding (Percent) ranges from 0 to 100 (Default: 0)
    /// - parameter decimationMix: Decimation Mix (Percent) ranges from 0 to 100 (Default: 50)
    /// - parameter linearTerm: Linear Term (Percent) ranges from 0 to 100 (Default: 50)
    /// - parameter squaredTerm: Squared Term (Percent) ranges from 0 to 100 (Default: 50)
    /// - parameter cubicTerm: Cubic Term (Percent) ranges from 0 to 100 (Default: 50)
    /// - parameter polynomialMix: Polynomial Mix (Percent) ranges from 0 to 100 (Default: 50)
    /// - parameter softClipGain: Soft Clip Gain (decibels) ranges from -80 to 20 (Default: -6)
    /// - parameter finalMix: Final Mix (Percent) ranges from 0 to 100 (Default: 50)
    
    var distDelay: ValueAndRange
    var distDecay: ValueAndRange
    var distDelayMix: ValueAndRange
    var distRingModFreq1: ValueAndRange
    var distRingModFreq2: ValueAndRange
    var distRingModBalance: ValueAndRange
    var distRingModMix: ValueAndRange
    var distDecimation: ValueAndRange
    var distRounding: ValueAndRange
    var distDecimationMix: ValueAndRange
    var distLinearTerm: ValueAndRange
    var distSquaredTerm: ValueAndRange
    var distCubicTerm: ValueAndRange
    var distPolynomialMix: ValueAndRange
    var distSoftClipGain: ValueAndRange
    var distFinalMix: ValueAndRange
    
    weak var node: Node?
    
    init(
        distDelay: ValueAndRange,
        distDecay: ValueAndRange,
        distDelayMix: ValueAndRange,
        distRingModFreq1: ValueAndRange,
        distRingModFreq2: ValueAndRange,
        distRingModBalance: ValueAndRange,
        distRingModMix: ValueAndRange,
        distDecimation: ValueAndRange,
        distRounding: ValueAndRange,
        distDecimationMix: ValueAndRange,
        distLinearTerm: ValueAndRange,
        distSquaredTerm: ValueAndRange,
        distCubicTerm: ValueAndRange,
        distPolynomialMix: ValueAndRange,
        distSoftClipGain: ValueAndRange,
        distFinalMix: ValueAndRange
    ){
        self.distDelay = distDelay
        self.distDecay = distDecay
        self.distDelayMix = distDelayMix
        self.distRingModFreq1 = distRingModFreq1
        self.distRingModFreq2 = distRingModFreq2
        self.distRingModBalance = distRingModBalance
        self.distRingModMix = distRingModMix
        self.distDecimation = distDecimation
        self.distRounding = distRounding
        self.distDecimationMix = distDecimationMix
        self.distLinearTerm = distLinearTerm
        self.distSquaredTerm = distSquaredTerm
        self.distCubicTerm = distCubicTerm
        self.distPolynomialMix = distPolynomialMix
        self.distSoftClipGain = distSoftClipGain
        self.distFinalMix = distFinalMix
    }
    
    func chain(to input: Node) -> Node {
        let newNode = Distortion(
            input,
            delay: distDelay.value,
            decay: distDecay.value,
            delayMix: distDelayMix.value,
            ringModFreq1: distRingModFreq1.value,
            ringModFreq2: distRingModFreq2.value,
            ringModBalance: distRingModBalance.value,
            ringModMix: distRingModMix.value,
            decimation: distDecimation.value,
            rounding: distRounding.value,
            decimationMix: distDecimationMix.value,
            linearTerm: distLinearTerm.value,
            squaredTerm: distSquaredTerm.value,
            cubicTerm: distCubicTerm.value,
            polynomialMix: distPolynomialMix.value,
            softClipGain: distSoftClipGain.value,
            finalMix: distFinalMix.value
        )
        node = newNode
        return newNode
    }
    
    func apply(value: Double, with damperTarget: InstrumentsSet.Track.Part.DamperTarget) {
            
        switch damperTarget.parameter {
        case "distDelay":
            let a = RangeConverter.valueToRange(range: distDelay.range, value: value)
            (node as? Distortion)?.delay = AUValue(a)
        case "distDecay":
            let b = RangeConverter.valueToRange(range: distDecay.range, value: value)
            (node as? Distortion)?.decay = AUValue(b)
        case "distDelayMix":
            let c = RangeConverter.valueToRange(range: distDelayMix.range, value: value)
            (node as? Distortion)?.delayMix = AUValue(c)
        case "distRingModFreq1":
            let d = RangeConverter.valueToRange(range: distRingModFreq1.range, value: value)
            (node as? Distortion)?.ringModFreq1 = AUValue(d)
        case "distRingModFreq2":
            let e = RangeConverter.valueToRange(range: distRingModFreq2.range, value: value)
            (node as? Distortion)?.ringModFreq2 = AUValue(e)
        case "distRingModBalance":
            let f = RangeConverter.valueToRange(range: distRingModBalance.range, value: value)
            (node as? Distortion)?.ringModBalance = AUValue(f)
        case "distRingModMix":
            let g = RangeConverter.valueToRange(range: distRingModMix.range, value: value)
            (node as? Distortion)?.ringModMix = AUValue(g)
        case "distDecimation":
            let h = RangeConverter.valueToRange(range: distDecimation.range, value: value)
            (node as? Distortion)?.decimation = AUValue(h)
        case "distRounding":
            let i = RangeConverter.valueToRange(range: distRounding.range, value: value)
            (node as? Distortion)?.rounding = AUValue(i)
        case "distDecimationMix":
            let j = RangeConverter.valueToRange(range: distDecimationMix.range, value: value)
            (node as? Distortion)?.decimationMix = AUValue(j)
        case "distLinearTerm":
            let h = RangeConverter.valueToRange(range: distLinearTerm.range, value: value)
            (node as? Distortion)?.linearTerm = AUValue(h)
        case "distSquaredTerm":
            let i = RangeConverter.valueToRange(range: distSquaredTerm.range, value: value)
            (node as? Distortion)?.squaredTerm = AUValue(i)
        case "distCubicTerm":
            let j = RangeConverter.valueToRange(range: distCubicTerm.range, value: value)
            (node as? Distortion)?.cubicTerm = AUValue(j)
        case "distPolynomialMix":
            let k = RangeConverter.valueToRange(range: distPolynomialMix.range, value: value)
            (node as? Distortion)?.polynomialMix = AUValue(k)
        case "distSoftClipGain":
            let l = RangeConverter.valueToRange(range: distSoftClipGain.range, value: value)
            (node as? Distortion)?.softClipGain = AUValue(l)
        case "distFinalMix":
            let m = RangeConverter.valueToRange(range: distFinalMix.range, value: value)
            (node as? Distortion)?.finalMix = AUValue(m)
        default: break
        }
    }
    
    func apply<V>(keyPath: WritableKeyPath<Distortion, V>, value: V) {
        var distortion = node as? Distortion
        distortion?[keyPath: keyPath] = value
    }
    
    func valueAndRange(parameter: String) -> ValueAndRange?{
        switch parameter {
        case "distDelay":
            return distDelay
        case "distDecay":
            return distDecay
        case "distDelayMix":
            return distDelayMix
        case "distRingModFreq1":
            return distRingModFreq1
        case "distRingModFreq2":
            return distRingModFreq2
        case "distRingModBalance":
            return distRingModBalance
        case "distRingModMix":
            return distRingModMix
        case "distDecimation":
            return distDecimation
        case "distRounding":
            return distRounding
        case "distDecimationMix":
            return distDecimationMix
        case "distLinearTerm":
            return distLinearTerm
        case "distSquaredTerm":
            return distSquaredTerm
        case "distCubicTerm":
            return distCubicTerm
        case "distPolynomialMix":
            return distPolynomialMix
        case "distSoftClipGain":
            return distSoftClipGain
        case "distFinalMix":
            return distFinalMix
        default: return nil
        }
    }
}
