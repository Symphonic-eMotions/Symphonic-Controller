//
//  InstrumentColors.swift
//  Symphonic eMotions Intern
//
//  Created by Frans-Jan Wind on 21/10/2022.
//

import SwiftUI

struct InstrumentColors {
    /// Bundle-veilige named lookup
    static func named(_ name: String, in bundle: Bundle = .main) -> Color? {
        #if os(iOS) || os(tvOS) || os(visionOS)
        if let ui = UIColor(named: name, in: bundle, compatibleWith: nil) {
            return Color(ui)
        }
        #elseif os(macOS)
        if let ns = NSColor(named: NSColor.Name(name), bundle: bundle) {
            return Color(ns)
        }
        #endif
        return nil
    }

    /// Afleiden van part-kleur-naam: "InstrumentColor201" + partIndex(0-based) → 201/202/203/204
    static func partName(from baseName: String, partIndex: Int) -> String? {
        guard !baseName.isEmpty, baseName.last?.isNumber == true else { return nil }
        return String(baseName.dropLast()) + String(partIndex + 1)
    }

    /// (Optioneel) fallbackkleur – eenvoudige variatie op basis van partIndex
    static func fallback(from base: Color, partIndex: Int) -> Color {
        let mix = Double((partIndex % 3) + 1) * 0.15
        return base.opacity(1.0).blend(with: .white, amount: mix)
    }
}

// kleine helper om te blenden zonder afhankelijkheden
private extension Color {
    func blend(with other: Color, amount: Double) -> Color {
        #if os(iOS) || os(tvOS) || os(visionOS)
        let a = UIColor(self), b = UIColor(other)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1v: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2v: CGFloat = 0, a2: CGFloat = 0
        a.getRed(&r1, green: &g1, blue: &b1v, alpha: &a1); b.getRed(&r2, green: &g2, blue: &b2v, alpha: &a2)
        return Color(UIColor(red: r1*(1-amount)+r2*amount,
                             green: g1*(1-amount)+g2*amount,
                             blue: b1v*(1-amount)+b2v*amount,
                             alpha: a1*(1-amount)+a2*amount))
        #else
        let a = NSColor(self).usingColorSpace(.sRGB) ?? .black
        let b = NSColor(other).usingColorSpace(.sRGB) ?? .white
        let r = a.redComponent*(1-amount) + b.redComponent*amount
        let g = a.greenComponent*(1-amount) + b.greenComponent*amount
        let bl = a.blueComponent*(1-amount) + b.blueComponent*amount
        let al = a.alphaComponent*(1-amount) + b.alphaComponent*amount
        return Color(NSColor(srgbRed: r, green: g, blue: bl, alpha: al))
        #endif
    }
}
