//
//  Rules.swift
//

import SwiftUI

struct Rules: View {
  @Binding var showRules: Bool
  @EnvironmentObject var vm: GameViewModel
  @State private var rule = 1
  @State private var rotation: Double = 0
  @State private var offset: CGFloat = .zero
  @State private var flow = false
  
    var body: some View {
      ZStack {
        BackBlurView(radius: 5)
        Color(hex: "#030E03").opacity(0.6)
          .ignoresSafeArea()
        ZStack {
          Image(.newlight)
            .resizableToFit()
            .scaleEffect(2)
            .rotationEffect(Angle(degrees: 180))
          Image(.coolglow)
            .resizableToFit()
          Image(.newlight)
            .resizableToFit()
          Image(.newlight)
            .resizableToFit()
            .rotationEffect(Angle(degrees: 180))
        }
        .mask {
          LiquidMetal()
            .luminanceToAlpha()
            .transparentIfNot(flow)
            .animation(.easeIn(duration: 2), value: flow)
        }
        .blur(radius: 2)
     
        Text("Tutorial (Learn to Play)")
          .cardFont(size: 27, style: .courgetReg, color: .white)
          .yOffset(-vm.h*0.33)
        cards
        
        Button {
          withAnimation {
            showRules = false
          }
        } label: {
          Image(.backbtn)
            .resizableToFit(height: 74)
          
        }
        .yOffset(vm.h*0.4)
      }
      .onAppear {
        flow = true
      }
    }
  
  func pushToNextCard() {
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
  
  private var cards: some View {
    ForEach(1..<5) { i in
      Image("card\(i)")
        .resizableToFit()
        .scaleEffect(i == 3 ? 0.95 : 1)
        .hPadding(40)
        .rotationEffect(Angle(degrees: Double(vm.zIndexForCard(page: rule, card: i) - 4)*(-2)))
        .zIndex(Double(vm.zIndexForCard(page: rule, card: i)))
        .offset(x: rule == i ? offset : 0)
        .rotation3DEffect(.init(degrees: rotation), axis: (0,1,0), perspective: 0.5)
        .gesture(
          DragGesture()
            .onChanged { value in
              let xOffset = value.translation.width
              offset = xOffset
            }
            .onEnded { value in
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

#Preview {
  Rules(showRules: .constant(true))
    .vm
}
