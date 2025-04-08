//
//  TakeBonus.swift
//

import SwiftUI

struct TakeBonus: View {
  @EnvironmentObject var vm: GameViewModel
    var body: some View {
      ZStack {
        BackBlurView(radius: 10)
        Color(hex: "#030E03")
          .opacity(0.6)
          .ignoresSafeArea()
        VStack {
          Text("Bonus every 3.5 hours")
            .cardFont(size: 27, style: .courgetReg, color: .white)
          
          Image(.yourbonus)
            .resizableToFit(height: 75)
          
          Button {
            vm.claimBonus()
            vm.showNoMoney = false
          } label: {
            Image(.takebonusbtn)
              .resizableToFit(height: 70)
          }
        }
      }
    }
}

#Preview {
    TakeBonus()
}
