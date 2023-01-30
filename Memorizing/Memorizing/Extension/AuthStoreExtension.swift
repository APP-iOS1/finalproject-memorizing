//
//  AuthStoreExtension.swift
//  Memorizing
//
//  Created by 진태영 on 2023/01/20.
//

import SwiftUI
import AuthenticationServices
import CryptoKit
import Firebase
import FirebaseAuth

// MARK: - UserDefaults extention: 기기에 로그인 정보를 담당하는 구조 추가
extension UserDefaults {
    
    enum Keys: String, CaseIterable {
        
        case isExistingAuth
        case email
        case password
        
    }
    
    func reset() {
        Keys.allCases.forEach { removeObject(forKey: $0.rawValue) }
    }
}

// Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
func randomNonceString(length: Int = 32) -> String {
  precondition(length > 0)
  let charset: [Character] =
      Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
  var result = ""
  var remainingLength = length

  while remainingLength > 0 {
    let randoms: [UInt8] = (0 ..< 16).map { _ in
      var random: UInt8 = 0
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
      if errorCode != errSecSuccess {
        fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
      }
      return random
    }

    randoms.forEach { random in
      if remainingLength == 0 {
        return
      }

      if random < charset.count {
        result.append(charset[Int(random)])
        remainingLength -= 1
      }
    }
  }

  return result
}

// MARK: - AppleAuth와 FirebaseAuth 연동
extension AuthStore: ASAuthorizationControllerDelegate {
    internal func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        print("Start apple authorization Controller")
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                         print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                         return
                     }
                     
            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce
            )
            Auth.auth().signIn(with: credential) {result, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("Apple SignIn Error: ", self.errorMessage)
                }
                if let user = result?.user {
                    let changeRequest = user.createProfileChangeRequest()
                    if let givenname = appleIDCredential.fullName?.givenName,
                       let familyName = appleIDCredential.fullName?.familyName {
                        changeRequest.displayName = "\(familyName)\(givenname)"
                    }
                    Task {
                    try await changeRequest.commitChanges()
//                    changeRequest.commitChanges { error in
//                        if let error = error {
//                            self.errorMessage = error.localizedDescription
//                            print("Apple SignIn, changeRequest displayName Fail: ", self.errorMessage)
//                        } else {
//                            print("Updated displayName: \(Auth.auth().currentUser!.displayName!)")
//                        }
//                    }
                    self.user = User(
                        id: user.uid,
                        email: "Apple_" + "\(user.email ?? "NO Email")",
                        nickName: changeRequest.displayName ?? "No Name",
                        coin: 1000
                    )
                    self.state = .signedIn
                    UserDefaults.standard.set(true, forKey: UserDefaults.Keys.isExistingAuth.rawValue)
                    print("Apple id: ", user.uid)
                    print("Apple email: ", user.email as Any)
                        print("Apple nickName: ", changeRequest.displayName as Any)
                        await self.userInfoWillFetchDB()
                    }
                }
            }
        }
    }
}

extension AuthStore: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
