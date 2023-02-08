//
//  ShakeEffectModifier.swift
//  Memorizing
//
//  Created by 윤현기 on 2023/02/08.
//

import SwiftUI

struct ShakeEffect: ViewModifier {

  var trigger: Bool

  @State private var isShaking = false

  func body(content: Content) -> some View {
    content
      .offset(x: isShaking ? -6 : .zero)
      .animation(.default.repeatCount(3).speed(6),
                 value: isShaking)
      .onChange(of: trigger) { newValue in
          
          guard newValue else { return }
          isShaking = true
          
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
              isShaking = false
          }
          
      }
  }
}

extension View {

  /// 트리거가 true 가 되면 흔들리는 효과 발생
  func shakeEffect(trigger: Bool) -> some View {
    modifier(ShakeEffect(trigger: trigger))
  }
}
