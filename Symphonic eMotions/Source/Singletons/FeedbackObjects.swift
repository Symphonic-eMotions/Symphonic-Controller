//
//  FeedbackObjects.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 19/07/2022.
//

import Combine

class FeedbackObjects {
    
    var objectOne = CurrentValueSubject<Double, Never>(0)
    
    var objectTwo = CurrentValueSubject<Double, Never>(0)
    
    var objectThree = CurrentValueSubject<Double, Never>(0)
    
    var objectFour = CurrentValueSubject<Double, Never>(0)
}
