//
//  Card.swift
//

import Foundation

struct Card: Identifiable, Equatable {
    let id = UUID()
    let name: String

    var value: Int {
        if name == "joker" { return 15 }
        return Int(String(name.dropFirst())) ?? 0
    }

    var suit: String? {
        if name == "joker" { return nil }
        return String(name.prefix(1))
    }

    var isJoker: Bool {
        name == "joker"
    }

    var zoneColor: Zone? {
        guard !isJoker else { return nil }

        switch value {
        case 2...6: return .red
        case 7...10: return .yellow
        case 11...14: return .blue
        default: return nil
        }
    }
}

struct PlayedCard: Identifiable, Equatable {
    let id = UUID()
    let card: Card
    let player: Player
}

enum Player {
    case player
    case bot
}
