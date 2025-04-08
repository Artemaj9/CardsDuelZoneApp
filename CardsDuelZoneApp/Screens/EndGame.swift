//
//  EndGame.swift
//

import SwiftUI

struct EndGame: View {
  @EnvironmentObject var vm: GameViewModel
  @EnvironmentObject var nm: NavigationStateManager
  @Binding var showRules: Bool
  @Binding var isBetStage: Bool
  
    var body: some View {
      ZStack {
        Image(vm.playerWon ? .winbg : .losebg)
          .backgroundFill()
        if vm.playerWon {
          Image(.winlight)
            .resizableToFit()
            .blendMode(.overlay)
            .opacity(0.6)
          
          Text("+ \(vm.finalWinnings)")
            .cardFont(size: 16, style: .geologBold, color: Color(hex:"#3BFF4F"))
            .offset(30, -vm.h*0.4)
            .yOffsetIf(vm.isSEight, 54)
          
          Image(.winlight)
            .resizableToFit()
            .blendMode(.overlay)
            .opacity(0.6)
            .mask {
              LiquidMetal()
                .luminanceToAlpha()
                .blur(radius: 10)
            }
          
          VStack {
            Image(.youwin)
              .resizableToFit(height: 55)
            Image(.scorelight)
              .resizableToFit(height: 30)
              .overlay {
                Text("Score: \(vm.finalWinnings)")
                  .cardFont(size: 14, style: .geologBold, color: Color(.white))
              }
          }
        } else {
          Text("- \(vm.bet)")
            .cardFont(size: 16, style: .geologBold, color: Color(hex:"#FF3BC4"))
            .offset(30, -vm.h*0.4)
            .yOffsetIf(vm.isSEight, 54)
          
          VStack {
            Image(.youlose)
              .resizableToFit(height: 55)

            Image(.loselight)
              .resizableToFit(height: 34)
              .overlay {
                Text("The bot has the best game")
                  .cardFont(size: 14, style: .geologBold, color: Color(.white))
              }
          }
        }
         
        Button {
          if vm.playerWon {
            vm.balance += vm.finalWinnings
          } else {
            vm.balance = max(vm.balance - vm.bet, 0)
          }
          vm.resetGame()
          isBetStage = true
        } label: {
          Image(.newbetbtn)
            .resizableToFit(height: 80)
        }
        .yOffset(vm.h*0.17)
        gameHeader
      }
    }
  
  @ViewBuilder private var gameHeader: some View {
    homebtn
    Image(.gamemoney)
      .resizableToFit(height: 40)
      .overlay {
        Capsule()
          .fill(Color(hex: "10000"))
          .frame(76, 34)
          .overlay {
            Text("\(vm.balance)")
              .cardFont(size: 16, style: .geologBold, color: .white)
          }
          .xOffset(16)
      }
      .yOffset(vm.header)
    
    rulesbtn
  }
  
  private var homebtn: some View {
    Button {
      vm.resetvm()
      nm.path = []
    } label: {
      Image(.homebtn)
        .resizableToFit(height: 40)
    }
    .offset(-vm.w*0.4, vm.header)
  }
  
  private var rulesbtn: some View {
    Button {
      withAnimation {
        showRules = true
      }
    } label: {
      Image(.rulesbtn)
        .resizableToFit(height: 40)
    }
    .offset(vm.w*0.4, vm.header)
  }
}

#Preview {
  EndGame(showRules: .constant(false), isBetStage: .constant(false))
    .vm
    .nm
}
