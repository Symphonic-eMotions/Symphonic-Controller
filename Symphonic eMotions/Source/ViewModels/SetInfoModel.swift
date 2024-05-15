//
//  SetInfoModel.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 23/02/2023.
//

import SwiftUI
import Combine
import OrderedCollections

struct SetInfoState {
    var currentInstrumentsSet: InstrumentsSet
    var currentLevel: Double = 0.0 //Leveling
    
    var values: [[AreaValues]] = []
    //SpriteKit
    var displayOpacity: Float = 0.12
    //Pro
    var semActive: SeMActive
    var displayMode: DisplayModes = .both
    //Part editor
    var updateEditView: Int = 0
    //Master
    var masterTrackStructure: [MasterTrackEffect]?
}

enum PlayerControlsViewAction {
    case displayModeChange(DisplayModes)
    case settingsChange(Bool)
    case partFeedbackViewChange(Bool)
}

final class SetInfoModel: ObservableObject {
    
    var userSettings: UserSettings
    private(set) var frameExtractor: FrameExtractor
    @Binding var setInfoLocalState: SetInfoLocalState
    @Binding var setSettings: SetSettings
    @Binding var imageDifference: ImageDifference
    @Published var setInfoState: SetInfoState
    let currentInstrumentsSetIsChanged: (InstrumentsSet) -> ()
    var conductor: Conductor
    let leveling: Leveling
    var onLevelReached: (() -> Void)?
    
    let feedbackPresets: [(button: Int, feedback: Double)] = [
        (0, 0.70), // Meeste feedback
        (1, 0.60),
        (2, 0.50),
        (3, 0.40)  // Minste feedback
    ]
    
    let sensitivityPreset: [(button: Int, sensitivity: Double)] = [
        (0, 0.70), // Minste gevoeligheid
        (1, 0.80),
        (2, 0.90),
        (3, 0.95)  // Meeste gevoeligheid
    ]
    
    //Part editor visual feedback
    let partFeedback: PartFeedback
    @Published var partFeedbackState: PartFeedbackState
    let playerControlsAction: ((PlayerControlsViewAction) -> Void)?
    
    //Sink variables
    internal var cancellableLevels: AnyCancellable? = nil
    internal var cancellableImageDifference: AnyCancellable? = nil
    internal var cancellablePartFeddback: AnyCancellable? = nil
    
    init(
        userSettings: UserSettings = UserSettings.shared,
        setInfoLocalState: Binding<SetInfoLocalState>,
        setSettings: Binding<SetSettings>,
        imageDifference: Binding<ImageDifference>,
        setInfoState: SetInfoState,
        currentInstrumentsSetIsChanged: @escaping (InstrumentsSet) -> Void,
        conductor: Conductor,
        leveling: Leveling,
        partFeedback: PartFeedback,
        partFeedbackState: PartFeedbackState,
        playerControlsAction: ((PlayerControlsViewAction) -> Void)? = nil
    ) {
        self.userSettings = userSettings
        self._setInfoLocalState = setInfoLocalState
        self._setSettings = setSettings
        self._imageDifference = imageDifference
        self.setInfoState = setInfoState
        self.currentInstrumentsSetIsChanged = currentInstrumentsSetIsChanged
        self.conductor = conductor
        self.leveling = leveling
        
        self.partFeedback = partFeedback
        self.partFeedbackState = partFeedbackState
        
        self.playerControlsAction = playerControlsAction
        
        frameExtractor = FrameExtractor.shared
        frameExtractor.delegate = self
        
        subscribeToLevels()
        subscribeToImageDifference()
        subscribeToPartFeedback()
    }
    
    func buttonToFeedback(id: Int) -> Double {
        for preset in feedbackPresets {
            if preset.button == id {
                return preset.feedback
            }
        }
        return 0.5
    }
    
    //ImageDifference feedbcak
    func feedbackToButton(feedback: Double) -> Int {
        for preset in feedbackPresets {
            if preset.feedback == feedback {
                return preset.button
            }
        }
        return 1
    }
    
    //ImageDifference Sensitivity
    func buttonToSensitivity(id: Int) -> Double {
        for preset in sensitivityPreset {
            if preset.button == id {
                return preset.sensitivity
            }
        }
        return 0.5
    }
    
    //TODO: random cell colors
    func colorForCell(row: Int, column: Int) -> Color {
        // Genereer een willekeurige kleur voor de rand van de cel
        Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
    
    //Multi purpose scale function
    func scale(
        input: Double,
        fromInputRange: (Double, Double),
        toOutputRange: (Double, Double)) -> Double {
        let (A, B) = fromInputRange
        let (C, D) = toOutputRange
        
        // Translate the input range to [0, 1]
        let normalizedInput = (input - A) / (B - A)
        
        // Translate from [0, 1] to the output range
        let output = C + (D - C) * normalizedInput
        
        return output
    }
}

extension SetInfoModel: FrameExtractorDelegate {
    
    func captured(image: CIImage) {
        guard userSettings.isCapturingRunning else { return }
        imageDifference.updateImageData(image: image)
    }
}
