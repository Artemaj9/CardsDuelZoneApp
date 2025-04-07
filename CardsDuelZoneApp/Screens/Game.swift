//
//  Game.swift
//

import SwiftUI

struct Game: View {
  @EnvironmentObject var vm: GameViewModel
  @EnvironmentObject var nm: NavigationStateManager
  @State private var isBetStage = false
  @State private var showRules = false
  
  var body: some View {
    ZStack {
      bg
      rulesbtn
      gameHeader
      discard
      botHand
      zones
      playerHand
      bottomRow
      betStage
      rulesOverlay
    }
    .onAppear {
      vm.startGame()
    }
    .navigationBarBackButtonHidden()
  }
  
  // MARK: - Zone View
  func zoneView(for zone: Zone, title: String) -> some View {
    ZStack {
      let playerCardCount = vm.zones[zone]?.filter { $0.player == .player }.count ?? 0
      let isLastCardBot = (vm.zones[zone]?.last?.player == .bot) ?? false
      Group {
        switch zone {
        case .red:
          Image(.z1)
            .resizableToFit(width: 65)
            .overlay {
              Image(.zonehighl)
                .resizableToFit(width: 64)
                .opacity(playerCardCount == 0 || isLastCardBot ? 0 : 1)
            }
            .overlay(.top) {
              Text(title)
                .cardFont(size: 12, style: .geologReg, color: Color(hex: "FF0101"))
                .yOffset(-20)
            }
            .overlay(.bottom) {
              Text("2-6")
                .cardFont(size: 12, style: .geologReg, color: Color(hex: "113410"))
                .yOffset(20)
            }
          
        case .yellow:
          Image(.z2)
            .resizableToFit(width: 65)
            .overlay {
              Image(.zonehighl)
                .resizableToFit(width: 64)
                .opacity(playerCardCount == 0 || isLastCardBot ? 0 : 1)
            }
            .overlay(.top) {
              Text(title)
                .cardFont(size: 12, style: .geologReg, color: Color(hex: "FBFF01"))
                .yOffset(-20)
            }
            .overlay(.bottom) {
              Text("7-10")
                .cardFont(size: 12, style: .geologReg, color: Color(hex: "113410"))
                .yOffset(20)
            }
          
        case .blue:
          Image(.z3)
            .resizableToFit(width: 65)
            .overlay {
              Image(.zonehighl)
                .resizableToFit(width: 64)
                .opacity(playerCardCount == 0 || isLastCardBot ? 0 : 1)
            }
            .overlay(.top) {
              Text(title)
                .cardFont(size: 12, style: .geologReg, color: Color(hex: "59A7FF"))
                .yOffset(-20)
            }
            .overlay(.bottom) {
              Text("J, Q, K, A")
                .cardFont(size: 12, style: .geologReg, color: Color(hex: "113410"))
                .yOffset(20)
            }
        }
      }
      
  
    
      ForEach(Array(vm.zones[zone]?.enumerated() ?? [].enumerated()), id: \.element.id) { index, played in
       
          Image(played.card.name)
              .resizableToFit(height: 60)
              .yOffset(Double(index*10))
              .offset(y: -20)
      }
      
      if playerCardCount != 0 && !isLastCardBot {
        Text("x\(playerCardCount)")
          .cardFont(size: 30, style: .geologReg, color: .white)
          .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
          .yOffset(vm.h*0.08)
      }
      
                       }
    .animation(.easeInOut(duration: 0.5),value: vm.zones[zone]?.count)
    .onTapGesture {
      vm.placeSelectedCard(in: zone)
    }
  }
  
  private var bg: some View {
    Image(.gamebg)
      .backgroundFill()
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
  }
  
  private var homebtn: some View {
    Button {
      nm.path = []
      vm.resetvm()
    } label: {
      Image(.homebtn)
        .resizableToFit(height: 40)
    }
    .offset(-vm.w*0.4, vm.header)
  }
  
  private var botHand: some View {
    HStack(spacing: 0) {
      ForEach(vm.botHand) { card in
        Image("back")
          .resizableToFit(height: 60)
      }
    }
    .yOffset(-vm.h*0.15)
  }
  
  private var zones: some View {
    // MARK: ZONES
    HStack(spacing: 12) {
      zoneView(for: .red, title: "Red")
      zoneView(for: .yellow, title: "Yellow")
      zoneView(for: .blue, title: "Blue")
    }
    .padding(.vertical, 20)
    .yOffset(vm.h*0.05)
  }
  
  private var discard: some View {
    Button {
      if vm.hand.count >= 7, let selected = vm.selectedCard {
        vm.discardSelectedCard()
      } else {
        vm.drawCard(for: .player)
      }
    } label: {
      Image(.discard)
        .resizableToFit(height: 80)
    }
    .disabled(vm.hand.count < 7 || vm.selectedCard == nil)
    .opacity(vm.hand.count < 7 || vm.selectedCard == nil ? 0.3 : 1)
    .animation(.easeInOut, value: vm.hand.count < 7 || vm.selectedCard == nil)
    .offset(-vm.w*0.4, -vm.h*0.05)
  }
  
  private var playerHand: some View {
    HStack(spacing: 2) {
      ForEach(vm.hand) { card in
        Image(card.name)
          .resizableToFit(height: 75)
          .background(vm.selectedCard == card ? Color(hex: "FF3BC4") : Color.gray.opacity(0))
          .cornerRadius(4)
          .onTapGesture {
            vm.selectCard(card)
          }
      }
    }
    .yOffset(vm.h*0.25)
  }
  
  private var bottomRow: some View {
    HStack {
      Button {
        vm.resetvm()
      } label: {
        Image(.resetbtn)
          .resizableToFit(height: 44)
      }
      
      Image(.yourbet)
        .resizableToFit(height: 71)
        .overlay {
          Capsule()
            .fill(Color(hex: "0C1410"))
            .frame(56, 34)
            .overlay {
              Text("\(vm.bet)")
                .cardFont(size: 15, style: .geologBold, color: .white)
            }
            .yOffset(-8)
        }
      
      Button {
        if vm.hand.count >= 7, let selected = vm.selectedCard {
          vm.discardSelectedCard()
        } else {
          vm.drawCard(for: .player)
        }
      } label: {
        Image(.newcardbtn)
          .resizableToFit(height: 44)
      }
      .disabled(vm.hand.count < 7 || vm.selectedCard == nil)
      .opacity(vm.hand.count < 7 || vm.selectedCard == nil ? 0.7 : 1)
      .animation(.easeInOut, value: vm.hand.count < 7 || vm.selectedCard == nil)
    }
    .yOffset(vm.h*0.4)
    
  }
  
  private var betStage: some View  {
    Group {
      Color(hex: "030E03")
        .opacity(0.6)
        .ignoresSafeArea()
      BackBlurView(radius: 10)
        .ignoresSafeArea()
      
      toMenu
    }
    .transparentIfNot(isBetStage)
  }
  
  private var toMenu: some View {
    Button {
      nm.path = []
    } label: {
      Image(.tomenu)
        .resizableToFit(height: 74)
    }
    .yOffset(vm.h*0.4)
  }
  
  private var rulesOverlay: some View {
    ZStack {
      if showRules {
        Rules(showRules: $showRules)
      }
    }
    .transparentIfNot(showRules)
    .animation(.easeInOut, value: showRules)
  }
}

struct CardView: View {
  let card: Card
  
  var body: some View {
    Image(card.name)
      .resizableToFit()
      .frame(width: 40, height: 60)
      .cornerRadius(6)
  }
}

#Preview {
  Game()
    .nm
    .vm
}
