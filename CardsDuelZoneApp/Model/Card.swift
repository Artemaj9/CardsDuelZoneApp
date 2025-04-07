//
//  Card.swift
//

import Foundation

enum Zone: String, CaseIterable {
    case red, yellow, blue
}

struct Card: Identifiable, Equatable {
    let id = UUID()
    let name: String // e.g. "b2", "g14", "joker"

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

    // This is useful for sorting cards into UI sections, but NOT used to restrict Joker
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

struct ZoneResult {
    let zone: Zone
    let winner: Player
    let winnerCards: Int
}

//struct Card: Identifiable, Equatable {
//    let id = UUID()
//    let name: String
//    
//    var value: Int {
//        if name == "joker" { return 100 } // Джокер самый сильный
//        return Int(name.dropFirst(1)) ?? 0
//    }
//    
//    var isJoker: Bool {
//        name == "joker"
//    }
//    
//    var zoneColor: Zone? {
//        guard !isJoker else { return nil }
//        let val = value
//        switch val {
//        case 2...6: return .blue
//        case 7...10: return .yellow
//        case 11...14: return .red
//        default: return nil
//        }
//    }
//}





//final class GameViewModel: ObservableObject {
    // MARK: Game State
//    @Published var hand: [Card] = []
//    @Published var botHand: [Card] = []
//    @Published var drawPile: [Card] = []
//    @Published var discardPile: [Card] = []
//    @Published var zones: [Zone: [PlayedCard]] = [
//        .red: [],
//        .yellow: [],
//        .blue: []
//    ]
//    
//    @Published var selectedCard: Card?
//    
//    // MARK: Game Setup
//    func startGame() {
//        let allCards = generateFullDeck().shuffled()
//        hand = Array(allCards.prefix(7))
//        botHand = Array(allCards.dropFirst(7).prefix(7))
//        drawPile = Array(allCards.dropFirst(14))
//        zones = [.red: [], .yellow: [], .blue: []]
//        discardPile = []
//        selectedCard = nil
//    }
//    
//    private func generateFullDeck() -> [Card] {
//        var cards: [Card] = []
//        let suits = ["b", "g", "s", "w"]
//        for suit in suits {
//            for value in 2...14 {
//                let name = "\(suit)\(value)"
//                cards.append(Card(name: name))
//            }
//        }
//        cards.append(Card(name: "joker"))
//        return cards
//    }
//    
//    // MARK: Turn Handling
//    func botTurn() {
//        for card in botHand {
//            let zonesToTry = validZones(for: card)
//            for zone in zonesToTry {
//                if canPlay(card: card, in: zone) {
//                    playBotCard(card, in: zone)
//                    return
//                }
//            }
//        }
//        // Если не смог сходить — сбрасывает первую карту
//        if !botHand.isEmpty {
//            discardPile.append(botHand.removeFirst())
//        }
//        drawCard(for: .bot)
//    }
//    
//    func drawCard(for player: Player) {
//        guard let drawn = drawPile.first else { return }
//        drawPile.removeFirst()
//        switch player {
//        case .player:
//            hand.append(drawn)
//        case .bot:
//            botHand.append(drawn)
//        }
//    }
//
//    // MARK: Player Interaction
//    func selectCard(_ card: Card) {
//        selectedCard = card
//    }
//    
//    func placeSelectedCard(in zone: Zone) {
//        guard let card = selectedCard else { return }
//        guard validZones(for: card).contains(zone) else { return }
//        guard canPlay(card: card, in: zone) else { return }
//        
//        if let index = hand.firstIndex(of: card) {
//            hand.remove(at: index)
//        }
//        
//        zones[zone, default: []].append(PlayedCard(card: card, player: .player))
//        selectedCard = nil
//        drawCard(for: .player)
//        botTurn()
//    }
//
//    func discardSelectedCard() {
//        guard let card = selectedCard else { return }
//        if let index = hand.firstIndex(of: card) {
//            hand.remove(at: index)
//        }
//        discardPile.append(card)
//        selectedCard = nil
//        drawCard(for: .player)
//        botTurn()
//    }
//
//    // MARK: Core Logic
//    func validZones(for card: Card) -> [Zone] {
//        if card.isJoker {
//            return Zone.allCases
//        }
//        return card.zoneColor.map { [$0] } ?? []
//    }
//    
//    func canPlay(card: Card, in zone: Zone) -> Bool {
//        let cardsInZone = zones[zone, default: []]
//        if card.isJoker { return true }
//        if let topCard = cardsInZone.last {
//            return card.value >= topCard.card.value
//        }
//        return true
//    }
//
//    func playBotCard(_ card: Card, in zone: Zone) {
//        if let index = botHand.firstIndex(of: card) {
//            botHand.remove(at: index)
//        }
//        zones[zone, default: []].append(PlayedCard(card: card, player: .bot))
//        drawCard(for: .bot)
//    }
//
//    // MARK: Result Evaluation
//    func winnerFor(zone: Zone) -> Player? {
//        guard let last = zones[zone]?.last else { return nil }
//        return last.card.isJoker ? last.player : last.player
//    }
//
//    func calculateZoneResults() -> [ZoneResult] {
//        var results: [ZoneResult] = []
//
//        for zone in Zone.allCases {
//            guard let cards = zones[zone], let last = cards.last else { continue }
//            let winner = last.player
//            let count = cards.filter { $0.player == winner }.count
//            results.append(ZoneResult(zone: zone, winner: winner, winnerCards: count))
//        }
//
//        return results
//    }
//
//    func calculateFinalResult(bet: Int) -> (netResult: Int, zoneResults: [ZoneResult]) {
//        let results = calculateZoneResults()
//        var net = 0
//
//        for result in results {
//            let zoneValue = result.winnerCards * bet
//            if result.winner == .player {
//                net += zoneValue
//            } else {
//                net -= zoneValue
//            }
//        }
//
//        return (net, results)
//    }
//}
