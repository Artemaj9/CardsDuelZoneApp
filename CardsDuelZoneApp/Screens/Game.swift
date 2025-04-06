//
//  Game.swift
//

import SwiftUI

struct Game: View {
  @EnvironmentObject var vm: GameViewModel
  @EnvironmentObject var nm: NavigationStateManager
  @State private var isBetStage = true
  @State private var showRules = false
  
    var body: some View {
      ZStack {
        Image(.gamebg)
          .backgroundFill()
        
        Color(hex: "030E03")
          .opacity(0.6)
          .ignoresSafeArea()
        BackBlurView(radius: 10)
          .ignoresSafeArea()
        
        toMenu
        rulesbtn
        
    
        rulesOverlay
       
      }
      .navigationBarBackButtonHidden()
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

#Preview {
    Game()
    .nm
    .vm
}
