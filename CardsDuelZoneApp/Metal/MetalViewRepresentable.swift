//
//  MetalViewRepresentable.swift
//

import SwiftUI
import MetalKit

struct MetalViewRepresentable: UIViewRepresentable {
  var effect: String
  
  func makeUIView(context: Context) -> MTKView {
    let metalView = MagicMetalView(effect: effect, frame: .zero)
    return metalView
  }
  
  func updateUIView(_ uiView: MTKView, context: Context) {}
}
