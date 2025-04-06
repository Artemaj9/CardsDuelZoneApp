//
//  MainView.swift
//

import SwiftUI

struct MainView: View {
  @EnvironmentObject var vm: GameViewModel
  @EnvironmentObject var nm: NavigationStateManager
  @State private var rule = 1
  @State private var rotation: Double = 0
  @State private var offset: CGFloat = .zero
  @Namespace private var animationNamespace
  
  var body: some View {
    NavigationStack(path: $nm.path) {
      ZStack {
        bg
        header
        lines
        title
        cards
        letsplay
      }
      .navigationDestination(for: SelectionState.self) { state in
        if state == .game { Game() }
        if state == .info { Info() }
      }
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
  
  private var bg: some View {
    Image(.menubg)
      .backgroundFill()
  }
  
  private var header: some View {
    HStack(alignment: .top) {
      Button {
        nm.path.append(.info)
      } label: {
        Image(.infobtn)
          .resizableToFit(height: 40)
          .tappableBg()
      }
      
      Spacer()
      
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
      
      Spacer()
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
    }
    .yOffset(vm.header)
    .hPadding()
  }
  
  private var title: some View {
    Text("Strategic card battles")
      .cardFont(size: 27, style: .courgetReg, color: .white)
      .yOffset(-vm.h*0.34)
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
  
  private var lines: some View {
    HStack(spacing: 20) {
      ForEach(1..<5) { i in
        ZStack {
          RoundedRectangle(cornerRadius: 4)
            .fill(Color(hex: "AAAAAA"))
            .frame(60, 2)
          if rule == i {
            RoundedRectangle(cornerRadius: 4)
              .fill(.white)
              .frame(60, 2)
              .matchedGeometryEffect(id: "overlay", in: animationNamespace)
          }
        }
      }
    }
    .yOffset(vm.h*0.32)
  }
  
  private var letsplay: some View {
    Button {
      nm.path.append(.game)
    } label: {
      Image(.letsplaybtn)
        .resizableToFit(height: 74)
    }
    .yOffset(vm.h*0.42)
  }
}

#Preview {
    MainView()
    .vm
    .nm
}
