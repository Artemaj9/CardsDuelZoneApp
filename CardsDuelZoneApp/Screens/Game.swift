//
//  Game.swift
//

import SwiftUI

struct Game: View {
  @EnvironmentObject var vm: GameViewModel
  @EnvironmentObject var nm: NavigationStateManager
  @State private var isBetStage = true
  @State private var showRules = false
  @State private var showPicker = false
  
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
      ZStack {
        if vm.isGameOver {
          EndGame(showRules: $showRules, isBetStage: $isBetStage)
        }
      }
      .transparentIfNot(vm.isGameOver)
      .animation(.easeInOut, value: vm.isGameOver)
      
      rulesOverlay
    }
    .navigationBarBackButtonHidden()
    .sheet(isPresented: $showPicker) {
      ZStack {
        VStack(spacing: 0) {
          Picker("Select a Bet", selection: $vm.bet) {
            ForEach(Array(stride(from: 10, through: min(500, vm.balance), by: 10)), id: \.self) { number in
                  Text("\(number)").tag(number)
                      .foregroundStyle(.white)
              }
          }
          .pickerStyle(.wheel)
          .frame(height: 180)
              
          okBtn
            .offset(y: vm.isSEight ? -24 : 0)
        }
      }
      .offset(y: 20)
      .vPadding()
      .presentationDetents([.fraction(vm.isSEight ? 0.4 : 0.33)])
      .background(BackgroundClearView(color: Color(hex: "808080").opacity(0.1)))
      .background(.ultraThinMaterial)
    }
  }
  
  // MARK: - Zone View
  func zoneView(for zone: Zone, title: String) -> some View {
    ZStack {
      let playerCardCount = vm.multiplier(for: vm.zones[zone]?.filter { $0.player == .player }.count ?? 0)
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
              .offset(y: -50)
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
  
  private var okBtn: some View {
    Button {
      showPicker = false
    } label: {
      Image(.okbtn)
        .resizableToFit(height: 44)
    }
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
          .background(
            Rectangle()
              .fill(vm.selectedCard == card ? Color(hex: "FF3BC4") : Color.gray.opacity(0))
                .scaleEffect(x: card.name == "joker" ? 1.1 : 1)
            
          )
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
        withAnimation {
          isBetStage = true
        }
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
    .yOffsetIf(vm.isSEight, -40)
  }
  
  private var betStage: some View {
    Group {
      Color(hex: "030E03")
        .opacity(0.6)
        .ignoresSafeArea()
      BackBlurView(radius: 10)
        .ignoresSafeArea()
      
      playbtn
      rulesbtn
      homebtn
      Image(.betbg)
        .resizableToFit(height: 100)
        .overlay {
          Capsule()
            .fill(Color(hex: "0C1410"))
            .frame(87, 34)
            .overlay {
              Text("\(vm.bet)")
                .cardFont(size: 16, style: .geologBold, color: .white)
            }
            .onTapGesture {
              showPicker = true
            }
        }
        .overlay(.leading) {
          Button {
            if vm.bet > 10 {
              vm.bet -= 10
            }
          } label: {
            Image(.minusbtn)
              .resizableToFit(height: 70)
          }
          .opacity(vm.bet <= 10 ? 0.5 : 1)
          .yOffset(4)
        }
        .overlay(.trailing) {
          Button {
            if vm.balance >= vm.bet + 10  && vm.bet < 500 {
              vm.bet += 10
            }
          } label: {
            Image(.plusbtn)
              .resizableToFit(height: 70)
          }
          .opacity(vm.balance >= vm.bet + 10  && vm.bet < 500 ? 1 : 0.5)
          .yOffset(4)

        }
        .onAppear {
          vm.bet = min(100, vm.balance)
        }
    }
    .transparentIfNot(isBetStage)
  }
  
  private var playbtn: some View {
    Button {
      vm.resetGame()
      isBetStage = false
    } label: {
      Image(.playbtn)
        .resizableToFit(height: 74)
    }
    .yOffset(vm.h*0.4)
    .yOffsetIf(vm.isSEight, -34)
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
