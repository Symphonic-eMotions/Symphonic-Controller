//
//  SetInfoModel.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 23/02/2023.
//

import Combine
import OrderedCollections
import SwiftUI

struct SetInfoState {
    var currentInstrumentsSet: InstrumentsSet
    var currentLevel: Double = 0.0 // Leveling

    var values: [[AreaValues]] = []
    // SpriteKit
    var displayOpacity: Float = 0.12
    // Pro
    var semActive: SeMActive
    var displayMode: DisplayModes = .both
    // Part editor
    var updateEditView: Int = 0
    // Master
    var masterTrackStructure: [MasterTrackEffect]?
}

enum PlayerControlsViewAction {
    case displayModeChange(DisplayModes)
    case settingsChange(Bool)
    case partFeedbackViewChange(Bool)
}

extension SetInfoModel {
    func currentRamps(for trackId: String, partId: String) -> (up: Double, down: Double) {
        let partFallbackUp   = setSettingsValue.tracks[trackId]?.parts[partId]?.rampUp
        let partFallbackDown = setSettingsValue.tracks[trackId]?.parts[partId]?.rampDown

        let defaultUp   = partFallbackUp   ?? conductor.rampUp[RampKey.part(trackId, partId)]   ?? 0.5
        let defaultDown = partFallbackDown ?? conductor.rampDown[RampKey.part(trackId, partId)] ?? 0.5

        let up   = userSettings.rampUp(forTrack: trackId, part: partId, default: defaultUp)
        let down = userSettings.rampDown(forTrack: trackId, part: partId, default: defaultDown)
        return (up, down)
    }

    func updateRamp(for trackId: String, partId: String, up: Double? = nil, down: Double? = nil) {
        let key = RampKey.part(trackId, partId)

        // 1) Persist
        if let up   { userSettings.setRampUp(up, forTrack: trackId, part: partId) }
        if let down { userSettings.setRampDown(down, forTrack: trackId, part: partId) }

        // 2) Conductor cache
        if let up   { conductor.rampUp[key]   = up;   DebugLog.d("CACHE up   \(key) = \(up)") }
        if let down { conductor.rampDown[key] = down; DebugLog.d("CACHE down \(key) = \(down)") }

        // 3) SetSettings (voor UI/serialisatie)
        var ss = setSettingsValue
        if var track = ss.tracks[trackId], var part = track.parts[partId] {
            if let up   { part.rampUp = up }
            if let down { part.rampDown = down }
            track.parts[partId] = part
            ss.tracks[trackId] = track
            setSettingsValue = ss
        }
    }

    func primeRampsFromDefaults() {
        let ss = setSettingsValue
        for (trackId, track) in ss.tracks {
            for (partId, part) in track.parts {
                let up   = userSettings.rampUp(forTrack: trackId, part: partId, default: part.rampUp)
                let down = userSettings.rampDown(forTrack: trackId, part: partId, default: part.rampDown)
                let key = RampKey.part(trackId, partId)
                conductor.rampUp[key]   = up
                conductor.rampDown[key] = down
                DebugLog.d("PRIME \(key) up=\(up) down=\(down)")
            }
        }
    }
}


final class SetInfoModel: ObservableObject {
    var userSettings: UserSettings
    private var didPrimeRamps = false
    private(set) var frameExtractor: FrameExtractor
    @Binding var setInfoLocalState: SetInfoLocalState
    @Binding var imageDifference: ImageDifference
    @Published var setInfoState: SetInfoState
    
    //Toegang speciaal voor PlayOverlayView->AOIOverlay
    @Binding var setSettings: SetSettings
    var setSettingsValue: SetSettings {
        get { _setSettings.wrappedValue }
        set { _setSettings.wrappedValue = newValue }
    }
    var tracksValue: OrderedDictionary<String, TrackSettings> {
        setSettingsValue.tracks
    }
    
    let currentInstrumentsSetIsChanged: (InstrumentsSet) -> Void
    var conductor: Conductor
    let leveling: Leveling
    var onLevelReached: (() -> Void)?

    let feedbackPresets: [(button: Int, feedback: Double)] = [
        (0, 0.70), // Meeste feedback
        (1, 0.60),
        (2, 0.50),
        (3, 0.40) // Minste feedback
    ]

    let sensitivityPreset: [(button: Int, sensitivity: Double)] = [
        (0, 0.70), // Minste gevoeligheid
        (1, 0.80),
        (2, 0.90),
        (3, 0.95) // Meeste gevoeligheid
    ]

    // Part editor visual feedback
    let partFeedback: PartFeedback
    @Published var partFeedbackState: PartFeedbackState
    let playerControlsAction: ((PlayerControlsViewAction) -> Void)?

    // Sink variables
    var cancellableLevels: AnyCancellable?
    var cancellableImageDifference: AnyCancellable?
    var cancellablePartFeddback: AnyCancellable?

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
        _setInfoLocalState = setInfoLocalState
        _setSettings = setSettings
        _imageDifference = imageDifference
        self.setInfoState = setInfoState
        self.currentInstrumentsSetIsChanged = currentInstrumentsSetIsChanged
        self.conductor = conductor
        self.leveling = leveling

        self.partFeedback = partFeedback
        self.partFeedbackState = partFeedbackState

        self.playerControlsAction = playerControlsAction

        frameExtractor = FrameExtractor.shared
        frameExtractor.delegate = self

//        subscribeToLevels()
        subscribeToImageDifference()
        subscribeToPartFeedback()
        
        // Prime per-part ramps direct:
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if !self.didPrimeRamps {
                self.primeRampsFromDefaults()
                self.didPrimeRamps = true
            }
        }
    }

    func buttonToFeedback(id: Int) -> Double {
        for preset in feedbackPresets {
            if preset.button == id {
                return preset.feedback
            }
        }
        return 0.5
    }

    // ImageDifference feedbcak
    func feedbackToButton(feedback: Double) -> Int {
        for preset in feedbackPresets {
            if preset.feedback == feedback {
                return preset.button
            }
        }
        return 1
    }

    // ImageDifference Sensitivity
    func buttonToSensitivity(id: Int) -> Double {
        for preset in sensitivityPreset {
            if preset.button == id {
                return preset.sensitivity
            }
        }
        return 0.5
    }

    // TODO: random cell colors
    func colorForCell(row _: Int, column _: Int) -> Color {
        // Genereer een willekeurige kleur voor de rand van de cel
        Color(
            red: Double.random(in: 0 ... 1),
            green: Double.random(in: 0 ... 1),
            blue: Double.random(in: 0 ... 1)
        )
    }

    // Multi purpose scale function
    func scale(
        input: Double,
        fromInputRange: (Double, Double),
        toOutputRange: (Double, Double)
    ) -> Double {
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
        Task { @MainActor [weak self] in
            guard let self else { return }
            guard self.userSettings.isCapturingRunning else { return }
            self.imageDifference.updateImageData(image: image)
        }
    }
}
