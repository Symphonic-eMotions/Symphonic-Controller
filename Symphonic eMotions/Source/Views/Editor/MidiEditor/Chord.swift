//
//  Chord.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 22/05/2024.
//

import Foundation

enum ChordOption: Codable {
    case none
    case addSecondNoteAsFourth
    case addSeventh
}

enum Chord: String, CaseIterable, Codable {
    case C, Cm, Csharp, Csharpm, D, Dm, Dsharp, Dsharpm, E, Em, F, Fm, Fsharp, Fsharpm, G, Gm, Gsharp, Gsharpm, A, Am, Asharp, Asharpm, B, Bm

    var notes: [UInt8] {
        switch self {
        case .C: return [48, 52, 55]
        case .Cm: return [48, 51, 55]
        case .Csharp: return [49, 53, 56]
        case .Csharpm: return [49, 52, 56]
        case .D: return [50, 54, 57]
        case .Dm: return [50, 53, 57]
        case .Dsharp: return [51, 55, 58]
        case .Dsharpm: return [51, 54, 58]
        case .E: return [52, 56, 59]
        case .Em: return [52, 55, 59]
        case .F: return [53, 57, 60]
        case .Fm: return [53, 56, 60]
        case .Fsharp: return [54, 58, 61]
        case .Fsharpm: return [54, 57, 61]
        case .G: return [55, 59, 62]
        case .Gm: return [55, 58, 62]
        case .Gsharp: return [56, 60, 63]
        case .Gsharpm: return [56, 59, 63]
        case .A: return [57, 61, 64]
        case .Am: return [57, 60, 64]
        case .Asharp: return [58, 62, 65]
        case .Asharpm: return [58, 61, 65]
        case .B: return [59, 63, 66]
        case .Bm: return [59, 62, 66]
        }
    }

    var description: String {
        switch self {
        case .C: return "C majeur"
        case .Cm: return "C mineur"
        case .Csharp: return "C# majeur"
        case .Csharpm: return "C# mineur"
        case .D: return "D majeur"
        case .Dm: return "D mineur"
        case .Dsharp: return "D# majeur"
        case .Dsharpm: return "D# mineur"
        case .E: return "E majeur"
        case .Em: return "E mineur"
        case .F: return "F majeur"
        case .Fm: return "F mineur"
        case .Fsharp: return "F# majeur"
        case .Fsharpm: return "F# mineur"
        case .G: return "G majeur"
        case .Gm: return "G mineur"
        case .Gsharp: return "G# majeur"
        case .Gsharpm: return "G# mineur"
        case .A: return "A majeur"
        case .Am: return "A mineur"
        case .Asharp: return "A# majeur"
        case .Asharpm: return "A# mineur"
        case .B: return "B majeur"
        case .Bm: return "B mineur"
        }
    }
}
