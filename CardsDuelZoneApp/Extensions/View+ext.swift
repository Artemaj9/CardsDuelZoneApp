//
//  View+ext.swift
//

import SwiftUI

extension View {
  func readSize(_ size: Binding<CGSize>) -> some View {
    self.modifier(SizeReader(size: size))
  }
  
  func tappableBg() -> some View {
    background(Color.black.opacity(0.001))
  }
  
  func overlayMask(@ViewBuilder content: () -> some View) -> some View {
    self.overlay { content().mask { self }}
  }
  
  func asButton(action: @escaping () -> Void) -> some View {
    Button {
      action()
    } label: {
      self
    }
  }
  
  func scrollMask(location1: Double = 0.09, location2: Double = 0.15, location3: Double = 0.9, location4: Double = 1) -> some View {
    self.modifier(ScrollMask(location1: location1, location2: location2, location3: location3, location4: location4))
  }
  
  func cardFont(size: CGFloat, style: CustomFont, color: Color) -> some View {
    return self
      .font(.custom(style, size: size))
      .foregroundStyle(color)
  }
  
  func env<T: ObservableObject>(_ object: T) -> some View {
    self.environmentObject(object)
  }
  
  func env<T: ObservableObject, U: ObservableObject>(_ object: T, _ object2: U) -> some View {
    self
      .env(object)
      .env(object2)
  }

  // for previews
  var vm: some View {
    self.environmentObject(GameViewModel())
  }
  
  var nm: some View {
    self.environmentObject(NavigationStateManager())
  }
  
  func width(_ width: CGFloat, _ alignment: Alignment = .center) -> some View {
    frame(width: width, alignment: alignment)
  }
  
  func height(_ height: CGFloat, _ alignment: Alignment = .center) -> some View {
    frame(height: height, alignment: alignment)
  }
  
  func frame(_ width: CGFloat, _ height: CGFloat, _ alignment: Alignment = .center) -> some View {
    frame(width: width, height: height, alignment: alignment)
  }
  
  func hPadding() -> some View {
    padding(.horizontal)
  }
  
  func vPadding() -> some View {
    padding(.vertical)
  }
  
  func hPadding(_ horizontalPadding: CGFloat) -> some View {
    padding(.horizontal, horizontalPadding)
  }
  
  func vPadding(_ verticalPadding: CGFloat) -> some View {
    padding(.vertical, verticalPadding)
  }
  
  func lPadding() -> some View {
    padding(.leading)
  }
  
  func trPadding() -> some View {
    padding(.trailing)
  }
  
  func lPadding(_ lpadding: CGFloat) -> some View {
    padding(.leading, lpadding)
  }
  
  func trPadding(_ trailingPadding: CGFloat) -> some View {
    padding(.trailing, trailingPadding)
  }
  
  func xOffset(_ x: CGFloat) -> some View {
    offset(x: x)
  }
  
  func yOffset(_ y: CGFloat) -> some View {
    offset(y: y)
  }
  
  func xOffsetIf(_ condition: Bool, _ xOffset: CGFloat) -> some View {
    self.xOffset(condition ? xOffset : 0)
  }
  
  func yOffsetIf(_ condition: Bool, _ yOffset: CGFloat) -> some View {
    self.yOffset(condition ? yOffset : 0)
  }
  
  func xOffsetIfNot(_ condition: Bool, _ xOffset: CGFloat) -> some View {
    xOffsetIf(!condition, xOffset)
  }
  
  func yOffsetIfNot(_ condition: Bool, _ yOffset: CGFloat) -> some View {
    yOffsetIf(!condition, yOffset)
  }
  
  func offset(_ x: CGFloat, _ y: CGFloat) -> some View {
    offset(x: x, y: y)
  }
  
  func overlay(_ alignment: Alignment, @ViewBuilder content: () -> some View) -> some View {
    overlay(content(), alignment: alignment)
  }
  
  func transparentIf(_ condition: Bool) -> some View {
    opacity(condition ? 0 : 1)
  }
  
  func transparentIfNot(_ condition: Bool) -> some View {
    opacity(condition ? 1 : 0)
  }
}
