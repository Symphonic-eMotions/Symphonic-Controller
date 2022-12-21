//
//  CalibrationModel.swift
//  Symphonic eMotions Intern
//
//  Created by Frans-Jan Wind on 06/11/2022.
//

import SwiftUI
import Combine

struct CalibrationState {
    var values: [[AreaValues]] = []
    var buildSettings: BuildSettings
    var sessionSettings: SessionSettings
}

final class CalibrationModel: ObservableObject {
    
    private(set) var frameExtractor: FrameExtractor
    
    var conductor: Conductor
    @Published var calibrationState: CalibrationState
    @Binding var imageDifference: ImageDifference
    var cancellables = Swift.Set<AnyCancellable>()
    @Published var setSettings: SetSettings
    let partFeedback: PartFeedback
    @Published var partFeedbackState: PartFeedbackState
        
    init(
        conductor: Conductor,
        calibrationState: CalibrationState,
        imageDifference: Binding<ImageDifference>,
        setSettings: SetSettings,
        partFeedback: PartFeedback,
        partFeedbackState: PartFeedbackState
    ) {
        self.conductor = conductor
        self.calibrationState = calibrationState
        self._imageDifference = imageDifference
        self.setSettings = setSettings
        self.partFeedback = partFeedback
        self.partFeedbackState = partFeedbackState
        
        frameExtractor = FrameExtractor.shared
        
        frameExtractor.delegate = self
        startObservingData()
    }
    
    func startObservingData() {
        
        //Image difference values
        self.imageDifference.values.sink { values in
            
            guard self.conductor.isConductorPlayingSubject.value else { return }
            
            DispatchQueue.main.sync { [weak self] in
                
                self?.calibrationState.values = values
                
                let _ = self?.conductor.valuesDidChange(
                    //These are the main values for controlling
                    values: values,
                    //Dynamic area's of interest
                    setSettings: self!.setSettings,
                    //These 3 are for advanced view monitoring
                    currentSetLevel: 0,
                    partFeedbackTrackID: self?.partFeedback.currentTrackID.value ?? "",
                    partFeedbackPartID: self?.partFeedback.currentPartID.value ?? ""
                )
            }
        }
        .store(in: &cancellables)
        
        //Intermediair for part value monitoring preview
        self.conductor.forwardRampedPartFeedback.sink { value in
            self.partFeedbackState.ramped = Double(value)
        }
        .store(in: &cancellables)
    }
    
    func lightIndicator(indicatorNr i:Int) -> some View {
        
        var lightColor: Color = Color.clear
        let imageMaxStepSize = self.calibrationState.sessionSettings.imageMaxStepSizeLight
        let indicator: Int = i * -1
        
        if indicator == 0 {
            lightColor = Color.gray
        }
        else if indicator > 0 {
            if self.calibrationState.sessionSettings.imageMaxLightPart >= indicator * imageMaxStepSize {
                lightColor = Color.gray
            }
        }
        else if indicator < 0 {
            if self.calibrationState.sessionSettings.imageMaxLightPart <= indicator * imageMaxStepSize {
                lightColor = Color.gray
            }
        }
        
        return  Rectangle().fill(lightColor)
            .overlay(RoundedRectangle(cornerRadius: 7.0).stroke(Color("GridBorderColor")))
            .cornerRadius(7.0)
    }
    
    func incrementImageMaxLightPart(updateView: Int) -> Int {
        self.calibrationState.sessionSettings.imageMaxLightPart += self.calibrationState.sessionSettings.imageMaxStepSizeLight
        self.calibrationTotal()
        return updateView + 1
    }
    
    func decrementImageMaxLightPart(updateView: Int) -> Int {
        self.calibrationState.sessionSettings.imageMaxLightPart -= self.calibrationState.sessionSettings.imageMaxStepSizeLight
        self.calibrationTotal()
        return updateView + 1
    }
    
    func setImageMaxDistancePart(personButtonValue p:Float) {
        self.calibrationState.sessionSettings.imageFeedbackDisctancePart = p
        self.calibrationTotal()
    }
    
    

    func calibrationTotal(){
        //Add variables up
        let imageMax = 40 + self.calibrationState.sessionSettings.imageMaxLightPart
        
        let imageFeedback = self.calibrationState.sessionSettings.imageFeedbackDisctancePart
        
        //Send to engine
        self.imageDifference.maxValueSubject.send(imageMax)
        self.imageDifference.feedback.send(imageFeedback)
    }
    
    func partMeter(indicatorNr i:Int, currentValue v:Float) -> some View {
        
        var meterPartColor: Color = Color.clear
        let calibrationPartMeterSteps = Float(self.calibrationState.sessionSettings.calibrationPartMeterSteps)
        let meterPart: Float = 1/Float(calibrationPartMeterSteps) - 0.001
        let indicator: Float = (Float(i) * -1) + calibrationPartMeterSteps
        
        if v >= meterPart * indicator {
            if indicator == calibrationPartMeterSteps {
                meterPartColor = Color.red
            }
            else if indicator < calibrationPartMeterSteps * 0.8 {
                meterPartColor = Color.blue
            }
            else {
                meterPartColor = Color.green
            }
        }
        
        return Rectangle().fill(meterPartColor)
            .frame(width: 50)
            .overlay(RoundedRectangle(cornerRadius: 3.5).stroke(Color("GridBorderColor")))
            .cornerRadius(3.5)
    }
    
    func partThumb(currentValue v:Float) -> some View {
        
        if v >= 1 - 0.001 {
            return Image(systemName: "hand.thumbsdown")
                .foregroundColor(Color.red)
        }
        else if v >= 0.8 {
            return Image(systemName: "hand.thumbsup")
                .foregroundColor(Color.green)
        }
        else{
            return Image(systemName: "hand.thumbsdown")
                .foregroundColor(Color.blue)
        }
    }
}

extension CalibrationModel: FrameExtractorDelegate {
    
    func captured(image: CIImage) {
        guard conductor.isConductorPlayingSubject.value else { return }
        imageDifference.updateImageData(image: image)
    }
    
}
