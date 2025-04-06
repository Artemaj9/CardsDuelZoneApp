//
//  Welcome.swift
//

import SwiftUI

struct Welcome: View {
  @EnvironmentObject var vm: GameViewModel
  @State private var page = 1
  @Namespace private var animationNamespace
  
  var body: some View {
    ZStack {
      bgcolor
      pages
      skipBtn
      welclines
    }
  }
  
  private var bgcolor: some View {
    Color(hex: "030E03")
      .ignoresSafeArea()
  }
  
  private var welclines: some View {
    HStack(spacing: 20) {
      ForEach(1..<4) { i in
        ZStack {
          RoundedRectangle(cornerRadius: 4)
            .fill(Color(hex: "AAAAAA"))
            .frame(60, 2)
          if page == i {
            RoundedRectangle(cornerRadius: 4)
              .fill(.white)
              .frame(60, 2)
              .matchedGeometryEffect(id: "overlay", in: animationNamespace)
          }
        }
      }
    }
    .yOffset(-vm.h*0.42)
  }
  
  private var page1: some View {
    Group {
      Image(.wbga)
        .backgroundFill()
      Image(.coolglow)
        .resizableToFit()
        .yOffset(-vm.h*0.25)
      
      VStack(spacing: 20) {
        Text(Txt.welcomeTitle[0])
          .cardFont(size: 27, style: .courgetReg, color: .white)
        
        Text(Txt.welcDescr[0])
          .cardFont(size: 16, style: .geologReg, color: .white)
          .hPadding()
        
      }
      .hPadding(30)
      .multilineTextAlignment(.center)
      .yOffset(vm.h*0.17)
      
      Button {
        withAnimation {
          page = 2
        }
      } label: {
        Image(.startgamebtn)
          .resizableToFit(height: 74)
      }
      .yOffset(vm.h*0.4)
    }
    .xOffsetIf(page != 1, -vm.w)
  }
  
  private var page2: some View {
    Group {
      Image(.wbg2)
        .backgroundFill()
      Image(.coolglow)
        .resizableToFit()
        .yOffset(-vm.h*0.25)

      VStack(spacing: 20) {
        Text(Txt.welcomeTitle[1])
          .cardFont(size: 27, style: .courgetReg, color: .white)
        
        Text(Txt.welcDescr[1])
          .cardFont(size: 16, style: .geologReg, color: .white)
          .hPadding()
        
      }
      .hPadding(30)
      .multilineTextAlignment(.center)
      .yOffset(vm.h*0.19)
      
      Button {
        withAnimation {
          page = 3
        }
      } label: {
        Image(.gotitbtn)
          .resizableToFit(height: 74)
      }
      .yOffset(vm.h*0.4)
    }
    .xOffset(page == 2 ? 0 : (page == 1 ? vm.w : -vm.w))
  }
  
  private var page3: some View {
    Group {
      Image(.wbg3)
        .backgroundFill()
      //        Image(.wtxt)
      //          .resizableToFit()
      //          .hPadding(40)
      //          .yOffset(-vm.h*0.03)
      finalText
       
      Button {
        withAnimation {
          vm.isWelcome = false
        }
      } label: {
        Image(.okletsgobtn)
          .resizableToFit(height: 74)
      }
      .yOffset(vm.h*0.4)
    }
    .xOffsetIf(page != 3, vm.w)
  }
  
  private var pages: some View {
    Group {
      page1
      page2
      page3
    }
    .gesture(
      DragGesture(minimumDistance: 5.0, coordinateSpace: .local)
        .onEnded { value in
          if value.translation.width < -50 && abs(value.translation.height) < 50 {
            withAnimation {
              if page < 3 {
                page += 1
              }
            }
          } else if value.translation.width > 50 && abs(value.translation.height) < 50 {
            withAnimation {
              if page > 1 {
                page -= 1
              }
            }
          }
        }
    )
  }
  
  private var finalText: some View {
    VStack {
      Text("Important Notice!")
        .cardFont(size: 27, style: .courgetReg, color: .white)
        .padding(.bottom, 24)
      
      Text("This product is intended for entertainment purposes only. The game uses virtual currency, which has no real monetary value and cannot be exchanged for real money, securities, goods, or services.")
        .cardFont(size: 16, style: .geologReg, color: .white)
        .multilineTextAlignment(.leading)
      
      Text("Important Restrictions:")
        .cardFont(size: 18, style: .geologBold, color: .white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top)
        .padding(.bottom, 8)
      
      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Text(Txt.dot)
          Text("The game does not offer any form of cash winnings.")
        }
        
        HStack {
          Text(Txt.dot)
          Text("The game does not offer any foPurchasing virtual currency does not grant the right to refunds or exchanges for real-world funds.")
        }
        
        HStack {
          Text(Txt.dot)
          Text("The game does not support cash withdrawals in any form.")
        }
      }
      .cardFont(size: 16, style: .geologReg, color: .white)
      .padding(.leading, 4)
      
      Text("This project is designed for entertainment and does not promote gambling involving real stakes. Please play responsibly.")
        .cardFont(size: 16, style: .geologReg, color: .white)
        .padding(.top)
    }
    .hPadding(30)
    .yOffset(-20)
  }
  
  private var skipBtn: some View {
    Button {
      withAnimation {
        vm.isWelcome = false
      }
    } label: {
      Text("Skip")
        .cardFont(size: 17, style: .interReg, color: .white)
        .padding()
        .tappableBg()
    }
    .offset(vm.w*0.4, -vm.h*0.42)
  }
}

#Preview {
  Welcome()
    .vm
}
