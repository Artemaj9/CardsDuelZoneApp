//
//  Splash.swift
//

import SwiftUI

struct Splash: View {
  @EnvironmentObject var vm: GameViewModel
  
  var body: some View {
    ZStack {
      Image(.splash)
        .backgroundFill()
        .readSize($vm.size)
    }
    .onAppear {
      performAction(after: 0.01) {
        vm.isSplash = false
      }
    }
  }
}

#Preview {
  Splash()
    .environmentObject(GameViewModel())
}
