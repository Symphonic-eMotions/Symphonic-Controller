//
//  AppStateOld.swift
//  AppState
//
//  Created by Mihai Fratu on 31.07.2021.
//

import Foundation

class AppState: ObservableObject {
    var imageDifference: ImageDifference

    @Published var sets: [InstrumentsSet]

    @Published var conductor: Conductor {
        willSet {}
    }

    @Published var currentInstrumentsSet: InstrumentsSet {
        didSet {
            conductor.stop()
            conductor.trackSequencers = [:]
            conductor.velocities = [:]
            conductor.feedbackParts = [:]
            conductor.isSequencerPlaying = [:]
            conductor.trackSamplers = [:]
            conductor.trackInstruments = [:]
            conductor.effectNodes = [:]
            conductor.set = currentInstrumentsSet
            conductor.loadTracks()

            imageDifference = ImageDifference(
                rowCount: currentInstrumentsSet.columns,
                columnCount: currentInstrumentsSet.rows
            )
            print("\(currentInstrumentsSet.name) \(currentInstrumentsSet.columns)x\(currentInstrumentsSet.rows)")

            imageDifference.feedback = currentInstrumentsSet.imageFeedback
            imageDifference.maxValue = currentInstrumentsSet.imageMax

            level = 0
        }
    }

    @Published var level: Double = 0
    @Published var currentTrack: InstrumentsSet.Track?
    @Published var currentTrackPart: InstrumentsSet.Track.Part?
    @Published var isInEditMode: Bool = false

    init() {
        guard var masterTrack = InstrumentsSet.Track.withJSON("SE-set-master") else {
            preconditionFailure()
        }

        var instrumentSet1 = AppState.loadInstrumentSet(json: "SE-set-waltz")
        // Set timeSignature as loopLength tempoTrack midiFile looplength
        masterTrack.midiFiles![0].updateLoopLength(setLoopLength: Double(instrumentSet1.timeSignature))
        instrumentSet1.tracks.append(masterTrack)

        var instrumentSet2 = AppState.loadInstrumentSet(json: "SE-set-global-trigger")
        masterTrack.midiFiles![0].updateLoopLength(setLoopLength: Double(instrumentSet2.timeSignature))
        instrumentSet2.tracks.append(masterTrack)

        var instrumentSet3 = AppState.loadInstrumentSet(json: "SE-set-pwsynth")
        masterTrack.midiFiles![0].updateLoopLength(setLoopLength: Double(instrumentSet2.timeSignature))
        instrumentSet3.tracks.append(masterTrack)

        sets = [instrumentSet1, instrumentSet2, instrumentSet3]
        currentInstrumentsSet = instrumentSet1
        conductor = Conductor(set: instrumentSet1)

        imageDifference = ImageDifference(
            rowCount: instrumentSet1.rows,
            columnCount: instrumentSet1.columns
        )

        imageDifference.feedback = currentInstrumentsSet.imageFeedback
        imageDifference.maxValue = currentInstrumentsSet.imageMax
    }

    class func loadInstrumentSet(json: String) -> InstrumentsSet {
        guard let instrumentSet = InstrumentsSet.withJSON(json) else {
            preconditionFailure()
        }
        return instrumentSet
    }

    func toggle(index: InstrumentsSet.Track.Part.Index, for part: InstrumentsSet.Track.Part?) {
        guard let part = part else { return }
        guard let track = currentTrack else { return }

        var newPart = part
        newPart.toggleIndex(index: index, in: currentInstrumentsSet)

        var newTrack = track
        newTrack.update(part: newPart)

        var newSet = currentInstrumentsSet
        newSet.update(track: newTrack)

        var newSets = sets
        guard let setIndex = sets.firstIndex(where: { $0.id == newSet.id }) else { return }

        newSets.remove(at: setIndex)
        newSets.insert(newSet, at: setIndex)

        currentTrackPart = newPart
        currentTrack = newTrack
        currentInstrumentsSet = newSet
        sets = newSets
    }
}
