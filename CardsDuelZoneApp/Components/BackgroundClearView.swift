//
//  BackgroundClearView.swift
//

import SwiftUI

struct BackgroundClearView: UIViewRepresentable {
  var color = Color(hex: "181818").opacity(0.1)
  
  func makeUIView(context: Context) -> UIView {
    let view = UIView()
    DispatchQueue.main.async {
      view.superview?.superview?.backgroundColor = UIColor(color)
    }
    return view
  }
  func updateUIView(_ uiView: UIView, context: Context) {}
}
