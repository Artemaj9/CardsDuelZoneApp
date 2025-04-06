//
//  Font.swift
//

import SwiftUI

enum CustomFont: String {
  case geologReg = "Geologica Roman Regular"
  case geologBold = "Geologica Roman Bold"
  case courgetReg = "Courgette-Regular"
  case interReg = "Inter-Regular"
}

extension Font {
  static func custom(_ font: CustomFont, size: CGFloat) -> Font {
    Font.custom(font.rawValue, size: size)
  }
}
