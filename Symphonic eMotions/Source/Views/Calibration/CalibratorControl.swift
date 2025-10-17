//
//  CalibratorControl.swift
//  eMotion
//
//  Created by Frans-Jan Wind on 13/10/2025.
//


import Combine
import SwiftUI

// Compacte UI component voor één kalibrator
struct CalibratorControl: View {
    let title: String
    let isActive: Bool
    let activeLabel: String
    let idleLabel: String
    let start: () -> Void
    let stop: () -> Void

    @Binding var value: Int
    let decrement: () -> Void
    let increment: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Titel + aan/uit knop
            HStack(spacing: 12) {
                Text(title)
                    .font(.headline)

                Spacer(minLength: 8)

                Button(isActive ? activeLabel : idleLabel) {
                    isActive ? stop() : start()
                }
                .font(.callout.weight(.semibold))
                .controlSize(.small)
                .buttonStyle(.borderedProminent)
                .tint(isActive ? .red : .green)
                .clipShape(Capsule())
            }

            // Waarde + compacte stepper
            HStack(spacing: 8) {
                Text("\(value)")
                    .font(.title3.weight(.semibold))
                    .monospacedDigit()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))

                HStack(spacing: 6) {
                    Button(action: decrement) {
                        Image(systemName: "minus")
                            .font(.subheadline.weight(.semibold))
                    }
                    .controlSize(.small)
                    .buttonStyle(.bordered)

                    Button(action: increment) {
                        Image(systemName: "plus")
                            .font(.subheadline.weight(.semibold))
                    }
                    .controlSize(.small)
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding(14)
        .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
    }
}
