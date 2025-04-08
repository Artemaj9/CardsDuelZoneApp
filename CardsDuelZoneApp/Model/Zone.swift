//
//  Zone.swift
//

import Foundation

enum Zone: String, CaseIterable {
    case red, yellow, blue
}

struct ZoneResult {
    let zone: Zone
    let winner: Player
    let winnerCards: Int
}
