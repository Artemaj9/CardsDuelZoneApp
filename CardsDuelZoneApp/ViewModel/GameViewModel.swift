//
//  GameViewModel.swift
//
// swiftlint:disable all

import SwiftUI
import Combine

final class GameViewModel: ObservableObject {
  @Published var size: CGSize = CGSize(width: 393, height: 851)
  @Published var isSplash = true
  //@AppStorage("isWelcome") var isWelcome = true
  @Published var isWelcome = true

// MARK: GAME
  @Published var isWin = false
  @Published var showPopUp = false
  @Published var time = 0
  @Published var balance = 10000
  // SimulationStats
  @Published var totalSpins = 0
  @Published var totalWins = 0
  @Published  var selectedNumbers: Set<Int> = []
  @Published var showResetBtn = false

  private var cancellables = Set<AnyCancellable>()
  @Published var hand: [Card] = []
  @Published var botHand: [Card] = []
  @Published var drawPile: [Card] = []
  @Published var discardPile: [Card] = []
  @Published var zones: [Zone: [PlayedCard]] = [
      .red: [],
      .yellow: [],
      .blue: []
  ]

  @Published var selectedCard: Card?
  @Published var isGameOver = false
  @Published var playerWon = false
  @Published var finalWinnings: Int = 0
  @Published var turnOn = true
  var bet: Int = 100

  // MARK: Game Setup
  func startGame() {
      let allCards = generateFullDeck().shuffled()
      hand = Array(allCards.prefix(7))
      botHand = Array(allCards.dropFirst(7).prefix(7))
      drawPile = Array(allCards.dropFirst(14))
      zones = [.red: [], .yellow: [], .blue: []]
      discardPile = []
      selectedCard = nil
  }

  private func generateFullDeck() -> [Card] {
      var cards: [Card] = []
      let suits = ["b", "g", "s", "w"]
      for suit in suits {
          for value in 2...14 {
              let name = "\(suit)\(value)"
              cards.append(Card(name: name))
          }
      }
      cards.append(Card(name: "joker"))
      return cards
  }

  // MARK: Turn Handling
  func botTurn() {
    self.turnOn = false
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [self] in
      for card in botHand {
          let zonesToTry = validZones(for: card)
          for zone in zonesToTry {
              if canPlay(card: card, in: zone) {
                  playBotCard(card, in: zone)
                  return
              }
          }
      }
      // Если не смог сходить — сбрасывает первую карту
      if !botHand.isEmpty {
          discardPile.append(botHand.removeFirst())
      }
      self.drawCard(for: .bot)
      checkForGameEnd()
      turnOn = false
    }
  
  }

  func drawCard(for player: Player) {
      guard let drawn = drawPile.first else { return }

      switch player {
      case .player:
          guard hand.count < 7 else { return }
          hand.append(drawn)
      case .bot:
          guard botHand.count < 7 else { return }
          botHand.append(drawn)
      }
      drawPile.removeFirst()
  }

  // MARK: Player Interaction
  func selectCard(_ card: Card) {
      selectedCard = card
  }
  
  func placeSelectedCard(in zone: Zone) {
      guard let card = selectedCard else { return }
      guard validZones(for: card).contains(zone) else { return }
      guard canPlay(card: card, in: zone) else { return }
      
      if let index = hand.firstIndex(of: card) {
          hand.remove(at: index)
      }
      
      zones[zone, default: []].append(PlayedCard(card: card, player: .player))
      selectedCard = nil
      drawCard(for: .player)
      botTurn()
  }

  func discardSelectedCard() {
      guard let card = selectedCard else { return }
      if let index = hand.firstIndex(of: card) {
          hand.remove(at: index)
      }
      discardPile.append(card)
      selectedCard = nil
      drawCard(for: .player)
      botTurn()
  }

  // MARK: Core Logic
  func validZones(for card: Card) -> [Zone] {
      if card.isJoker {
          return Zone.allCases
      }
      return card.zoneColor.map { [$0] } ?? []
  }

  func canPlay(card: Card, in zone: Zone) -> Bool {
      let cardsInZone = zones[zone, default: []]
      if card.isJoker { return true }
      if let topCard = cardsInZone.last {
          return card.value >= topCard.card.value
      }
      return true
  }

  func playBotCard(_ card: Card, in zone: Zone) {
      if let index = botHand.firstIndex(of: card) {
          botHand.remove(at: index)
      }
      zones[zone, default: []].append(PlayedCard(card: card, player: .bot))
      drawCard(for: .bot)
  }

  // MARK: Result Evaluation
  func winnerFor(zone: Zone) -> Player? {
      guard let last = zones[zone]?.last else { return nil }
      return last.card.isJoker ? last.player : last.player
  }

  func calculateZoneResults() -> [ZoneResult] {
      var results: [ZoneResult] = []

      for zone in Zone.allCases {
          guard let cards = zones[zone], let last = cards.last else { continue }
          let winner = last.player
          let count = cards.filter { $0.player == winner }.count
          results.append(ZoneResult(zone: zone, winner: winner, winnerCards: count))
      }

      return results
  }

  func calculateFinalResult(bet: Int) -> (netResult: Int, zoneResults: [ZoneResult]) {
      let results = calculateZoneResults()
      var net = 0

      for result in results {
          let zoneValue = result.winnerCards * bet
          if result.winner == .player {
              net += zoneValue
          } else {
              net -= zoneValue
          }
      }

      return (net, results)
  }

  func checkForGameEnd() {
      let playerCanMove = canAnyCardBePlayed(hand, for: .player)
      let botCanMove = canAnyCardBePlayed(botHand, for: .bot)
      let bothHandsEmpty = hand.isEmpty && botHand.isEmpty
      let noCardsToDraw = drawPile.isEmpty

    if (bothHandsEmpty && noCardsToDraw) || (!playerCanMove && !botHand.isEmpty && noCardsToDraw) {
          endGame()
      }
  }
  
  func endGame() {
    var playerZonesWon: [Zone] = []
    var totalMultiplier = 0
    
    for (zone, cards) in zones {
      guard let last = cards.last else { continue }
      
      if last.player == .player {
        playerZonesWon.append(zone)
        totalMultiplier += cards.count
      }
    }
    
    if playerZonesWon.count >= 2 {
      playerWon = true
      finalWinnings = bet * totalMultiplier
      print("Win: x \(totalMultiplier)")
    } else {
      playerWon = false
      finalWinnings = -bet * zones
        .filter { $0.value.last?.player == .bot }
        .map { $0.value.count }
        .reduce(0, +)
      print("Loos: x \(finalWinnings)")
    }
    isGameOver = true
    print("EEENND GAMME!!!")
  }
  
  func canAnyCardBePlayed(_ cards: [Card], for player: Player) -> Bool {
      for card in cards {
          for zone in validZones(for: card) {
              if canPlay(card: card, in: zone) {
                  return true
              }
          }
      }
      return false
  }
  
  func discardRandomPlayerCard() {
      guard hand.count == 7, !drawPile.isEmpty else { return }
      guard let randomCard = hand.randomElement() else { return }
      if let index = hand.firstIndex(of: randomCard) {
          hand.remove(at: index)
      }
      discardPile.append(randomCard)
      drawCard(for: .player)
      botTurn()
  }
  
  func playerDidFinishTurn() {
      drawCard(for: .player)
      botTurn()
      checkForGameEnd()
  }
  
  func resetGame() {
      // Reset hands
      hand = []
      botHand = []

      // Reset draw pile, discard pile, and zones
      drawPile = []
      discardPile = []
      zones = [.red: [], .yellow: [], .blue: []]

      // Reset selected card and game over state
      selectedCard = nil
      isGameOver = false
      playerWon = false
      finalWinnings = 0

      // Reset turn state and bet
      turnOn = true
      bet = 100

      // Start a new game setup
      startGame()
  }
  

  
  func resetvm() {
    showPopUp = false
    showResetBtn = false
    resetGame()
  }

  // MARK: Bonus Timer
  
  @Published var timeRemaining: String = "3:30:00"
  @Published var canClaimBonus: Bool = false
  
  private var timer: Timer?
  private var remainingSeconds: Int = 2 * 60 * 60
  private let lastSavedTimeKey = "lastSavedTime"
  private let remainingTimeKey = "remainingTime"
  
  init() {
    loadSavedTime()
    startTimer()
    setupAppLifecycleObservers()
  }
  
  private func setupAppLifecycleObservers() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(appWillResignActive),
      name: UIApplication.willResignActiveNotification,
      object: nil
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(appDidBecomeActive),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
  }
  
  @objc private func appWillResignActive() {
    UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastSavedTimeKey)
    UserDefaults.standard.set(remainingSeconds, forKey: remainingTimeKey)
  }
  
  @objc private func appDidBecomeActive() {
    loadSavedTime()
  }
  
  private func loadSavedTime() {
    let lastSavedTime = UserDefaults.standard.double(forKey: lastSavedTimeKey)
    let savedRemainingTime = UserDefaults.standard.integer(forKey: remainingTimeKey)
    
    if lastSavedTime > 0 {
      let elapsedTime = Int(Date().timeIntervalSince1970 - lastSavedTime)
      remainingSeconds = max(savedRemainingTime - elapsedTime, 0)
      
      if remainingSeconds == 0 {
        canClaimBonus = true
        timeRemaining = "BONUS"
        return
      }
    } else {
      remainingSeconds = 2 * 60 * 60
    }
    startTimer()
  }

  func startTimer() {
    updateDisplay()
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      self?.tick()
    }
  }

  private func tick() {
    guard remainingSeconds > 0 else {
      timer?.invalidate()
      canClaimBonus = true
      timeRemaining = "BONUS"
      return
    }
    remainingSeconds -= 1
    updateDisplay()
  }
  
  private func updateDisplay() {
    let hours = remainingSeconds / 3600
    let minutes = (remainingSeconds % 3600) / 60
    let seconds = remainingSeconds % 60
    timeRemaining = String(format: "%02d:%02d", hours, minutes)
  }

  func claimBonus() {
    guard canClaimBonus else { return }
    canClaimBonus = false
    balance += 1000
    remainingSeconds = 2 * 60 * 60
    startTimer()
  }
  
  // MARK: CARD STACK LOGIC
  func zIndexForCard(page: Int, card: Int) -> Int {
    let cards = [1, 2, 3, 4]
    let shift = (page - 1) % cards.count
    let rotated = Array(cards[shift...] + cards[..<shift])
    if let index = rotated.firstIndex(of: card) {
      return cards.count - index
    }
    return 0
  }

  // MARK: - Layout
  
  var h: CGFloat {
    size.height
  }
  
  var w: CGFloat {
    size.width
  }
  var header: CGFloat {
    isSEight ? -size.height*0.43 + 44 : -size.height*0.43
  }
  
  var isEightPlus: Bool {
    return size.width > 405 && size.height < 910 && size.height > 880 && UIDevice.current.name != "iPhone 11 Pro Max"
  }
  
  var isElevenProMax: Bool {
    UIDevice.current.name == "iPhone 11 Pro Max"
  }
  
  var isIpad: Bool {
    UIDevice.current.name.contains("iPad")
  }
  
  var isSE: Bool {
    return size.width < 380
  }

  var isSEight: Bool {
    return isSE || isEightPlus
  }
}
