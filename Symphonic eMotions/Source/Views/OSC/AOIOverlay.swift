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

    /// Probeert de naam van de Color te achterhalen en vervangt het laatste cijfer door (partIndex+1).
    private func derivedColorFromInstrumentColorName(track: TrackSettings, partIndex: Int) -> Color? {
        let ic = InstrumentColors()
        let baseName = ic.name(color: track.instrumentColor) // bv. "InstrumentColor201"
        guard !baseName.isEmpty, baseName.last?.isNumber == true else { return nil }
        let newName = String(baseName.dropLast()) + String(partIndex + 1) // -> "InstrumentColor202"
        if let ui = UIColor(named: newName) { return Color(ui) }
        return nil
    }

    /// Fallback: haal track-nummer uit trackId ("stap2" -> 2) en bouw naam "InstrumentColor{n}0{part}"
    private func derivedColorFromTrackId(track: TrackSettings, partIndex: Int) -> Color? {
        // Probeer digits uit trackId te lezen
        let digits = track.trackId.compactMap { $0.wholeNumberValue }
        guard let n = digits.first else { return nil }
        let name = "InstrumentColor\(n)0\(partIndex + 1)"
        if let ui = UIColor(named: name) { return Color(ui) }
        return nil
    }

    /// Definitieve kleurkeuze per part
    private func color(for trackIndex: Int, partIndex: Int, track: TrackSettings) -> Color {
        if let c = derivedColorFromInstrumentColorName(track: track, partIndex: partIndex) {
            return c
        }
        if let c = derivedColorFromTrackId(track: track, partIndex: partIndex) {
            return c
        }
        // Als er geen asset bestaat, subtiele variatie op de basiskleur
        let shift = Double(partIndex) * 0.08
        return track.instrumentColor
            .opacity(0.95)
            .hueRotation(.degrees(shift * 360)) as! Color
    }

    var body: some View {
        GeometryReader { geo in
            Canvas { ctx, size in
                let cellW = size.width / CGFloat(columns)
                let cellH = size.height / CGFloat(rows)

                var tIdx = 0
                for (_, track) in tracks {
                    var pIdx = 0
                    for (_, part) in track.parts {
                        let partColor = color(for: tIdx, partIndex: pIdx, track: track)
                        pIdx += 1

                        let indexes = part.interestIndexes(rows: rows, columns: columns)
                        for index in indexes {
                            let rect = CGRect(
                                x: CGFloat(index.column) * cellW,
                                y: CGFloat(index.row) * cellH,
                                width: cellW,
                                height: cellH
                            )
                            ctx.fill(Path(roundedRect: rect, cornerRadius: 7), with: .color(partColor.opacity(0.20)))
                            ctx.stroke(Path(roundedRect: rect, cornerRadius: 7), with: .color(partColor.opacity(0.7)), lineWidth: 1)
                        }
                    }
                    tIdx += 1
                }
            }
        }
        .aspectRatio(1.77777, contentMode: .fit)
    }
}
