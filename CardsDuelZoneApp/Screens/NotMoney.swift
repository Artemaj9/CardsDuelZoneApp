//
//  NotMoney.swift
//

import SwiftUI

struct NotMoney: View {
  @EnvironmentObject var vm: GameViewModel
    var body: some View {
      ZStack {
        BackBlurView(radius: 10)
          .ignoresSafeArea()
        Color(hex: "#030E03")
          .opacity(0.6)
          .ignoresSafeArea()
        
        VStack(spacing: 0) {
          
          Text("Not enough coins")
            .cardFont(size: 27, style: .courgetReg, color: .white)
            .vPadding()
          
          Text("Wait for the bonus in 3.5 hours or play the game")
            .cardFont(size: 17, style: .geologBold, color: .white)
            .multilineTextAlignment(.center)
            .padding(.top, 4)
          
          Image(.bonus)
            .resizableToFit(height: 54)
            .overlay {
              Capsule()
                .fill(Color(hex: "10000"))
                .frame(76, 34)
                .overlay {
                  Text("\(vm.timeRemaining) h")
                    .cardFont(size: 16, style: .geologBold, color: .white)
                }
                .yOffset(-8)
               
            }
            .vPadding(20)
          Button {
            withAnimation {
              vm.showNoMoney = false
            }
          } label: {
            Image(.letplay)
              .resizableToFit(height: 70)
          }
          .yOffset(20)
        }
        .yOffset(-vm.h*0.05)
        
        Image(.balance)
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
      
        Button {
          withAnimation {
            vm.showNoMoney = false
          }
        } label: {
          Image(.xbtn)
            .resizableToFit(height: 40)
        }
        .offset(vm.w*0.4, vm.header)
      
      }
    }
}

#Preview {
    NotMoney()
    .vm
}
