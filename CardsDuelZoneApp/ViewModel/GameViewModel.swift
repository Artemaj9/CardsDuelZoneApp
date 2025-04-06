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
