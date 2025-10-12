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

    private func derivedColorFromInstrumentColorName(track: TrackSettings, partIndex: Int) -> Color? {
        let baseName = track.instrumentColorName // bv. "InstrumentColor201"
        guard let last = baseName.last, last.isNumber else { return nil }

        let newName = String(baseName.dropLast()) + String(partIndex + 1) // -> "InstrumentColor202/203/204"
        let found = InstrumentColors.named(newName)
        DebugLog.d("AOI nameFromBase: base=\(baseName) part=\(partIndex+1) -> \(newName) found=\(found != nil)")
        return found
    }

    private func derivedColorFromTrackId(track: TrackSettings, partIndex: Int) -> Color? {
        let digits = track.trackId.compactMap { $0.wholeNumberValue }
        guard let n = digits.first else { return nil }
        let name = "InstrumentColor\(n)0\(partIndex + 1)" // bv. "InstrumentColor203"
        let found = colorNamed(name)
        DebugLog.d("AOI nameFromTrackId: trackId=\(track.trackId) part=\(partIndex+1) -> \(name) found=\(found != nil)")
        return found
    }

    private func color(for trackIndex: Int, partIndex: Int, track: TrackSettings) -> Color {
        if let c = derivedColorFromInstrumentColorName(track: track, partIndex: partIndex) {
            return c
        }
        if let c = derivedColorFromTrackId(track: track, partIndex: partIndex) {
            return c
        }
        DebugLog.d("AOI fallback color used for track=\(track.trackId) part=\(partIndex+1)")
        return fallbackColor(base: track.instrumentColor, partIndex: partIndex)
    }
    
    private func colorNamed(_ name: String) -> Color? {
        #if os(iOS) || os(tvOS) || os(visionOS)
        let bundle = Bundle.main // of Bundle.module als je assets in een SPM-package zitten
        if let ui = UIColor(named: name, in: bundle, compatibleWith: nil) {
            return Color(ui)
        }
        #elseif os(macOS)
        let bundle = Bundle.main // of Bundle.module
        if let ns = NSColor(named: NSColor.Name(name), bundle: bundle) {
            return Color(ns)
        }
        #endif
        return nil
    }
    
    private func fallbackColor(base: Color, partIndex: Int) -> Color {
        // Varieer lichtheid/verzadiging op basis van partIndex
        // Heel simpel: meng met wit/zwart
        let mix = Double((partIndex % 3) + 1) * 0.15 // 0.15, 0.30, 0.45, ...
        return base.opacity(1.0).blend(with: .white, amount: mix)
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

// Klein hulpfunctietje
private extension Color {
    func blend(with other: Color, amount: Double) -> Color {
        // lineaire mix in sRGB (voldoende voor UI)
        #if os(iOS) || os(tvOS) || os(visionOS)
        let ui1 = UIColor(self)
        let ui2 = UIColor(other)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        ui1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1); ui2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let r = r1*(1-amount) + r2*amount
        let g = g1*(1-amount) + g2*amount
        let b = b1*(1-amount) + b2*amount
        let a = a1*(1-amount) + a2*amount
        return Color(UIColor(red: r, green: g, blue: b, alpha: a))
        #elseif os(macOS)
        let ns1 = NSColor(self)
        let ns2 = NSColor(other)
        guard let c1 = ns1.usingColorSpace(.sRGB), let c2 = ns2.usingColorSpace(.sRGB) else { return self }
        let r = c1.redComponent*(1-amount) + c2.redComponent*amount
        let g = c1.greenComponent*(1-amount) + c2.greenComponent*amount
        let b = c1.blueComponent*(1-amount) + c2.blueComponent*amount
        let a = c1.alphaComponent*(1-amount) + c2.alphaComponent*amount
        return Color(NSColor(srgbRed: r, green: g, blue: b, alpha: a))
        #endif
    }
}
