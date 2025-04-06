//
//  GameViewModel.swift
//
// swiftlint:disable all

import SwiftUI
import Combine

final class GameViewModel: ObservableObject {
  @Published var size: CGSize = CGSize(width: 393, height: 851)
  @Published var isSplash = true
  @AppStorage("isWelcome") var isWelcome = true
  
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

  func resetvm() {
    showPopUp = false
    showResetBtn = false
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
  // MARK: - Layout
  
  var h: CGFloat {
    size.height
  }
  
  var w: CGFloat {
    size.width
  }
  var header: CGFloat {
    isSEight ? -size.height*0.42 + 44 : -size.height*0.42
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
