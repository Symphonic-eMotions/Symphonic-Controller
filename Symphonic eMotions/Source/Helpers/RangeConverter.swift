//
//  RangeConverter.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 18/09/2022.
//

import Foundation

enum RangeConverter {
    /// Converts a value by raising it to a specified exponent, potentially inverting it,
    /// and then scaling and shifting it to fit within a target range.
    ///
    /// - Parameters:
    ///   - range: The target range for the value.
    ///   - value: The original value to be converted.
    ///   - exponent: The exponent to which the value should be raised. Default is 0 (no change).
    ///   - inverted: A flag indicating whether the value should be inverted within the range [0, 1]. Default is false.
    /// - Returns: The converted value within the target range.
    static func valueToRange(range: [Double], value: Double, exponent: Int = 0, inverted: Bool = false) -> Double {
        // Compute the value raised to the specified exponent
        var expValue = value
        for _ in 0 ..< exponent {
            expValue *= value
        }

        // If inverted flag is true, invert the value within the range [0, 1]
        if inverted {
            expValue = 1 - expValue
        }

        // Scale and shift the value to fit within the target range
        let convertedValue = expValue * (range[1] - range[0]) + range[0]

        return convertedValue
    }

    /// Converts a normalized value from the range [0, 1] to its original range.
    ///
    /// - Parameters:
    ///   - range: The target range for the value.
    ///   - value: The normalized value to be converted.
    /// - Returns: The value within the target range.
    static func rangeToValue(range: [Double], value: Double) -> Double {
        // Compute the value within the target range
        let convertedValue = value * (range[1] - range[0]) + range[0]

        return convertedValue
    }

    /// Converts a value from a given range to a normalized slider range of [0, 1].
    ///
    /// - Parameters:
    ///   - range: The original range of the value.
    ///   - value: The original value to be converted.
    /// - Returns: The normalized value within the range [0, 1].
    static func rangedToSlider(range: [Double], value: Double) -> Float {
        // Calculate the reciprocal of the total range span
        let rangePart: Double = 1 / (range[1] - range[0])

        // Compute the normalized value
        let normalizedValue = (value - range[0]) * rangePart

        return Float(normalizedValue)
    }
}
