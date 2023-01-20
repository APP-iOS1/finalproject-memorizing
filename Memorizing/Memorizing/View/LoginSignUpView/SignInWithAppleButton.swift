//
//  SignInWithAppleButton.swift
//  Memorizing
//
//  Created by 진태영 on 2023/01/20.
//

import SwiftUI
import AuthenticationServices

// Implementation courtesy of https://stackoverflow.com/a/56852456/281221
struct SignInWithAppleButton: View {
  @Environment(\.colorScheme) var colorScheme: ColorScheme // (1)
  
  var body: some View {
    Group {
      if colorScheme == .light { // (2)
        SignInWithAppleButtonInternal(colorScheme: .light)
      } else {
        SignInWithAppleButtonInternal(colorScheme: .dark)
      }
    }
  }
}

private struct SignInWithAppleButtonInternal: UIViewRepresentable { // (3)
  var colorScheme: ColorScheme
  
  func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
    switch colorScheme {
    case .light:
      return ASAuthorizationAppleIDButton(type: .signIn, style: .black) // (4)
    case .dark:
      return ASAuthorizationAppleIDButton(type: .signIn, style: .white) // (5)
    @unknown default:
      return ASAuthorizationAppleIDButton(type: .signIn, style: .black) // (6)
    }
  }
  
  func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
  }
}

struct SignInWithAppleButton_Previews: PreviewProvider {
  static var previews: some View {
    SignInWithAppleButton()
  }
}
