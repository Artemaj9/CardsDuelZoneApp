//
//  AppViewBuilder.swift
//

import SwiftUI

struct AppViewBuilder<Splash: View, Welcome: View, MainView: View>: View {
  @Binding var isSplash: Bool
  @Binding var isWelcome: Bool
  @ViewBuilder let splash: Splash
  @ViewBuilder let welcome: Welcome
  @ViewBuilder let mainView: MainView
  
  var body: some View {
    ZStack {
      if isSplash {
        splash
          .transition(.opacity)
      } else if isWelcome {
        welcome
          .transition(.opacity)
      } else {
        mainView
          .transition(.opacity)
      }
    }
    .animation(.smooth, value: isSplash)
    .ignoresSafeArea()
  }
}
