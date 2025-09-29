//
//  StartViewModel.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 15/05/2024.
//

import Combine
import SwiftUI

class StartViewModel: ObservableObject {
    private let countDownLength = 3
    @Published var countdown: Int
    @Published var isCountdownActive = false
    @Published var isLocalPlaying = false

    var timerSubscription: AnyCancellable?
    var onCountdownComplete: (() -> Void)?

    init() {
        countdown = countDownLength
        setupTimer()
    }

    func initalizeModel() {
        countdown = countDownLength
        isCountdownActive = false
        isLocalPlaying = false
    }

    func setupTimer() {
        timerSubscription = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.handleTimerTick()
            }
    }

    func startCountdown() {
        if !isCountdownActive {
            isCountdownActive = true
            setupTimer()
        }
    }

    func handleTimerTick() {
        if isCountdownActive, countdown > 1 {
            countdown -= 1
        } else if countdown <= 1 {
            stopCountdown()
        }
    }

    func stopCountdown() {
        timerSubscription?.cancel()
        onCountdownComplete?()
    }
}
