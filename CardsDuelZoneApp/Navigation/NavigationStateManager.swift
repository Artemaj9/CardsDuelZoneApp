//
//  NavigationStateManager.swift
//

import Foundation

enum SelectionState: Hashable, Codable {
  case info
  case history
  case calculate
  case simulation
}

class NavigationStateManager: ObservableObject {
  @Published var path = [SelectionState]()
}
