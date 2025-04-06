//
//  MainView.swift
//

import SwiftUI

struct MainView: View {
  @EnvironmentObject var vm: GameViewModel
  @EnvironmentObject var nm: NavigationStateManager
  @State private var rule = 4
  @State private var rotation: Double = 0
  
  @State private var offset: CGFloat = .zero
    var body: some View {
      ZStack {
        bg
        Text("Strategic card battles")
          .cardFont(size: 27, style: .courgetReg, color: .white)
          .yOffset(-vm.h*0.3)
        
        ForEach(1..<5) { i in
          Image("card\(i)")
            .resizableToFit()
            .scaleEffect(i == 3 ? 0.95 : 1)
            .hPadding(40)
            .rotationEffect(Angle(degrees: Double(zIndexForCard(page: rule, card: i) - 4)*(-2)))
            .zIndex(Double(zIndexForCard(page: rule, card: i)))
            .offset(x: rule == i ? offset : 0)
            .rotation3DEffect(.init(degrees: rotation), axis: (0,1,0), perspective: 0.5)
            .gesture (
              DragGesture()
                .onChanged{ value in
                  let xOffset = value.translation.width
                  offset = xOffset
                }
                .onEnded{ value in
                  let xVelocity = max(-value.velocity.width/5, 0)
                  
                  if (abs(offset) > 100) {
  
                    pushToNextCard()
                  } else {
                    withAnimation(.smooth ) {
                      offset = .zero
                    }
                  }
                },
              
              isEnabled: i == rule
            )
          
        }
      }
    }
  
  private func pushToNextCard() {
    withAnimation(.smooth) {
      if offset > 0 {
        offset = 200
      } else {
        offset = -200
      }
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
    
      withAnimation(.smooth(duration: 0.25)) {
        if rule < 4 {
          rule += 1
        } else {
          rule = 1
        }
        offset = .zero
      }
    }
  }
  
  func zIndexForCard(page: Int, card: Int) -> Int {
      let cards = [1, 2, 3, 4]
      let shift = (page - 1) % cards.count
      let rotated = Array(cards[shift...] + cards[..<shift])
      if let index = rotated.firstIndex(of: card) {
          return cards.count - index
      }
      return 0
  }
  private var bg: some View {
    Image(.menubg)
      .backgroundFill()
  }
}

#Preview {
    MainView()
    .vm
    .nm
}
