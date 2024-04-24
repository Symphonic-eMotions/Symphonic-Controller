//
//  StartView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 18/04/2024.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject var userSettings: UserSettings
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplaySub: SessionDisplay
    var geometry: GeometryProxy
    @State private var isLocalPlaying: Bool = false
    @State private var countdown = 3
    @State private var isCountdownActive: Bool = false
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            
            Circle()
                .stroke(Color.primary, lineWidth: 20)
                .frame(width: geometry.size.height * 0.6, height: geometry.size.height * 0.6)
                .overlay(
                    Button(action: {
                        isLocalPlaying.toggle()
                    }) {
                        if isLocalPlaying {
                            Text("\(countdown)")
                                .font(.largeTitle)
                                .foregroundColor(.primary)
                        } else {
                            Triangle()
                                .fill(Color.primary)
                                .frame(width: 60, height: 60)
                        }
                    }
                )
                .background(Color.white.opacity(0.5))
                .clipShape(Circle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
        .onReceive(timer) { _ in
            
            print("onReceive currentLevel: \(setInfoModel.setInfoState.currentLevel)")
            
            var highestScaledValue = Double.leastNormalMagnitude

            for row in setInfoModel.setInfoState.values {
                for areaValue in row {
                    if areaValue.scaledValue > highestScaledValue {
                        highestScaledValue = areaValue.scaledValue
                    }
                }
            }

            print("Highest Scaled Value: \(highestScaledValue)")
            
            if isLocalPlaying && setInfoModel.setInfoState.currentLevel < 0.01 && !isCountdownActive {
                startCountdown()
            }
        }
    }

    func startCountdown() {
        isCountdownActive = true
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 0 {
                countdown -= 1
            } else {
                print("Verberg knop start set")
                timer.invalidate()
                
                sessionDisplaySub = .playing
                setInfoModel.conductor.playEngineAndTracks(
                    setSettings: setInfoModel.setSettings,
                    level: 0
                )
                setInfoModel.conductor.levelController(
                    level: 0,
                    setSettings: setInfoModel.setSettings
                )
                
                countdown = 3
                isCountdownActive = false
            }
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Punt van de driehoek naar rechts wijzend
        path.move(to: CGPoint(x: rect.maxX, y: rect.midY))  // Rechter middenpunt
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))  // Linker bovenpunt
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))  // Linker onderpunt
        path.closeSubpath()
        
        return path
    }
}
