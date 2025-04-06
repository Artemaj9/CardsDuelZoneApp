//
//  MyKeyframeAnimator.swift
//

import SwiftUI

struct MyKeyframeAnimator<Root, Trigger: Equatable, Content: View>: View {
  var initialValue: Root
  var trigger: Trigger
  @ViewBuilder var content: (Root) -> Content
  var keyframes: [any MyKeyframeTracks<Root>]
  
  @State private var startDate: Date? = nil
  @State private var suspended = true
  
  var timeline: MyKeyframeTimeline<Root> {
    MyKeyframeTimeline(initialValue: initialValue, tracks: keyframes)
  }
  
  func value(for date: Date) -> Root {
    guard let s = startDate else { return initialValue }
    return timeline.value(time: date.timeIntervalSince(s))
  }
  
  func isPaused(_ date: Date) -> Bool {
    guard let s = startDate else { return true }
    let time = date.timeIntervalSince(s)
    if time > timeline.duration { return true }
    return false
  }
  
  var body: some View {
    TimelineView(.animation(paused: suspended)) { context in
      let value = value(for: context.date)
      content(value)
        .onChange(of: isPaused(context.date)) { suspended = $0 }
    }
    .onChange(of: trigger) { _ in
      startDate = Date()
      suspended = false
    }
  }
}
