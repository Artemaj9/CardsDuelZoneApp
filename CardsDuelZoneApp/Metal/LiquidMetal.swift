//
//  Flicker.swift
//

import SwiftUI

struct LiquidMetal: View {
  var effect: String = "glowShader"
  
  var body: some View {
    ZStack {
      MetalViewRepresentable(effect: effect)
        .edgesIgnoringSafeArea(.all)
    }
  }
}

#Preview {
  LiquidMetal()
}
