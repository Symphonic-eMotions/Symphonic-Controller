//
//  AOIOverlay.swift
//  eMotion
//
//  Created by Frans-Jan Wind on 11/10/2025.
//

import SwiftUI
import OrderedCollections

struct AOIOverlay: View {
    let rows: Int
    let columns: Int
    let tracks: OrderedDictionary<String, TrackSettings>

    // simpele kleurkeuze: varieer per part binnen track
    private func color(for track: TrackSettings, partIndex: Int) -> Color {
        // Gebruik je bestaande instrumentColor en draai hue per part,
        // of map naar je eigen palet. Voorbeeld: accentkleur met huerotate.
        // Hier vereenvoudigd: partIndex shift in HSB
        let base = track.instrumentColor   // jouw Color al
        // SwiftUI heeft geen directe hueRotate op Color; je kunt alternatieven gebruiken:
        // Voor nu: verlaag opacity, want basisColor is al per instrument onderscheidend.
        return base
    }

    var body: some View {
        GeometryReader { geo in
            Canvas { ctx, size in
                let cellW = size.width / CGFloat(columns)
                let cellH = size.height / CGFloat(rows)

                for (_, track) in tracks {
                    var pIdx = 0
                    for (_, part) in track.parts {
                        let partColor = color(for: track, partIndex: pIdx)
                        pIdx += 1

                        // AOI indices → kleur overlay
                        let indexes = part.interestIndexes(rows: rows, columns: columns)
                        for index in indexes {
                            let rect = CGRect(
                                x: CGFloat(index.column) * cellW,
                                y: CGFloat(index.row) * cellH,
                                width: cellW,
                                height: cellH
                            )

                            // zachte vulling
                            ctx.fill(
                                Path(roundedRect: rect, cornerRadius: 7),
                                with: .color(partColor.opacity(0.18))
                            )
                            // subtiele outline per part
                            ctx.stroke(
                                Path(roundedRect: rect, cornerRadius: 7),
                                with: .color(partColor.opacity(0.7)),
                                lineWidth: 1.0
                            )
                        }
                    }
                }
            }
        }
        .aspectRatio(1.77777, contentMode: .fit)
    }
}
