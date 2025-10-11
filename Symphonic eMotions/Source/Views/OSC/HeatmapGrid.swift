//
//  HeatmapGrid.swift
//  eMotion
//
//  Created by Frans-Jan Wind on 11/10/2025.
//
import SwiftUI

struct HeatmapGrid: View {
    let rows: Int
    let columns: Int
    let values: [[AreaValues]]
    let baseOpacity: Double

    var body: some View {
        GeometryReader { geo in
            Canvas { ctx, size in
                let cellW = size.width / CGFloat(columns)
                let cellH = size.height / CGFloat(rows)

                // teken cellen
                for r in 0..<rows {
                    for c in 0..<columns {
                        guard r < values.count, c < values[r].count else { continue }
                        let v = values[r][c].scaledValue   // of values[r][c].average
                        let alpha = max(0, min(1, v)) * baseOpacity

                        let rect = CGRect(
                            x: CGFloat(c) * cellW,
                            y: CGFloat(r) * cellH,
                            width: cellW,
                            height: cellH
                        )

                        // subtiele grijs/wit hittekaart
                        let color = Color.white.opacity(alpha)
                        ctx.fill(Path(roundedRect: rect, cornerRadius: 7), with: .color(color))

                        // gridlijn (optioneel licht)
                        ctx.stroke(Path(roundedRect: rect, cornerRadius: 7),
                                   with: .color(Color("GridBorderColor").opacity(0.8)),
                                   lineWidth: 1)
                    }
                }
            }
        }
        .aspectRatio(1.77777, contentMode: .fit)
    }
}
