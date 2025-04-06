//
//  ContentView.swift
//
// swiftlint:disable all

import SwiftUI

struct ContentView: View {
  @StateObject var vm = GameViewModel()
  @StateObject var nm = NavigationStateManager()
  
  var body: some View {
    AppViewBuilder(
      isSplash: $vm.isSplash,
      isWelcome: $vm.isWelcome,
      splash: { Splash().env(vm) },
      welcome: { Welcome().env(vm) },
      mainView: { MainView().env(vm,nm) }
    )
  }
}
