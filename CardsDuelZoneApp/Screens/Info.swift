//
//  Info.swift
//

import SwiftUI

struct Info: View {
  @EnvironmentObject var vm: GameViewModel
  @EnvironmentObject var nm: NavigationStateManager
  @State private var saturation: Double = 0
  @State private var scrOff: Double = 0
  var body: some View {
    ZStack {
      bg
    
      Image(.newlight)
        .resizableToFill()
        .opacity(0.5)
        .blendMode(.luminosity)
        .scaleEffect(2)
        .yOffset(-500)
      .offset(y: +0.7*scrOff)
      header
      
      
      ScrollView {
        VStack(alignment: .leading) {
          Color.clear.height(50)
          Text(Txt.Info.intro)
            .cardFont(size: 16, style: .geologReg, color: .white)
          
          Text("How to Play")
            .cardFont(size: 18, style: .geologBold, color: .white)
            .padding(.top)
            .padding(.bottom, 8)
          
          ForEach(Txt.Info.zones, id: \.self) { t in
            HStack(alignment: .firstTextBaseline) {
              Text(Txt.dot)
              Text(t)
            }
            .vPadding(4)
          }
          .cardFont(size: 16, style: .geologReg, color: .white)
          Text("Key Features")
            .cardFont(size: 18, style: .geologBold, color: .white)
            .padding(.top)
            .padding(.bottom, 8)
          
          ForEach(Txt.Info.features, id: \.self) { f in
            Text(f)
              .cardFont(size: 16, style: .geologReg, color: .white)
              .vPadding(2)
          }
          
          Text("Disclaimer")
            .cardFont(size: 18, style: .geologBold, color: .white)
            .padding(.top)
            .padding(.bottom, 8)
          Text(Txt.Info.discl)
            .cardFont(size: 16, style: .geologReg, color: .white)
          
          ForEach(Txt.Info.points, id: \.self) { t in
            HStack(alignment: .firstTextBaseline) {
              Text(Txt.dot)
              Text(t)
            }
            .cardFont(size: 16, style: .geologReg, color: .white)
            .vPadding(4)
          }
          
          Text(Txt.Info.outlog)
            .cardFont(size: 16, style: .geologReg, color: .white)
            .vPadding(4)
          
          Color.clear.height(250)
        }
      .hPadding()
      .background(GeometryReader {
        Color.clear.preference(
          key: ViewOffsetKey.self,
          value: -$0.frame(in: .named("scroll")).origin.y
        )
      }).onPreferenceChange(ViewOffsetKey.self) {
        saturation = $0 * 0.001
        scrOff = $0
      }
    }
      .coordinateSpace(name: "scroll")
      .scrollIndicators(.hidden)
      .scrollMask(
        location1: 0,
        location2: 0.05,
        location3: 0.8,
        location4: 0.9
      )
      .yOffset(vm.h*0.12)
      
    }
  }
  
  private var bg: some View {
    Image(.infobg)
      .backgroundFill()
      .hueRotation(Angle(radians: saturation))
      .saturation(1 + saturation)
  }
  
  @ViewBuilder private var header: some View {
    Text("App information")
      .cardFont(size: 22, style: .courgetReg, color: .white)
      .yOffset(vm.header)
    
    Button {
      nm.path = []
    } label: {
      Image(.homebtn)
        .resizableToFit(height: 40)
    }
    .offset(-vm.w*0.4, vm.header)
  }
}

#Preview {
    Info()
    .nm
    .vm
}
