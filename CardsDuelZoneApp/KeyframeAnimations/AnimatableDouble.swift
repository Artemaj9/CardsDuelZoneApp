//
//  AnimatableDouble.swift
//


import SwiftUI

struct AnimatableDouble: VectorArithmetic, Animatable {
    var value: Double
  var animatableData: AnimatableDouble {
    get { self }
    set { self = newValue }
  }

    static var zero: AnimatableDouble { AnimatableDouble(value: 0) }

    static func + (lhs: AnimatableDouble, rhs: AnimatableDouble) -> AnimatableDouble {
        AnimatableDouble(value: lhs.value + rhs.value)
    }

    static func - (lhs: AnimatableDouble, rhs: AnimatableDouble) -> AnimatableDouble {
        AnimatableDouble(value: lhs.value - rhs.value)
    }

    mutating func scale(by rhs: Double) {
        value *= rhs
    }

    var magnitudeSquared: Double {
        value * value
    }

    static func += (lhs: inout AnimatableDouble, rhs: AnimatableDouble) {
        lhs.value += rhs.value
    }

    static func -= (lhs: inout AnimatableDouble, rhs: AnimatableDouble) {
        lhs.value -= rhs.value
    }

    static func == (lhs: AnimatableDouble, rhs: AnimatableDouble) -> Bool {
        lhs.value == rhs.value
    }
}
