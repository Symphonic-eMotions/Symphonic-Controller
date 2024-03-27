extension Conductor {
    
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
        
        // Increment AND decrement level
        localCurrentSetLevel = adjustCurrentSetLevel(
            setSettings: setSettings,
            currentSetLevel: currentSetLevel,
            averageMovement: averageForLevelUpdate
        )
 
        // Find the maximum index (used for variation by position)
        let maxIndexTuple = vDSP.indexOfMaximum(scaledValues)
        let maxIndex = Int(maxIndexTuple.0)
        
        return localCurrentSetLevel
    }
}
