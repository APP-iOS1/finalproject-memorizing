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
        case notificationBadgeCount
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
            Task {
                do {
                    self.user = User(id: "", email: "", nickName: "", coin: 0, signInPlatform: User.Platform.apple.rawValue)
                    let result = try await Auth.auth().signIn(with: credential)
                    
                    self.user = User(
                        id: result.user.uid,
                        email: "\(result.user.email ?? "NO Email")",
                        nickName: appleIDCredential.fullName?.nickname ?? "No Name",
                        coin: 1000,
                        signInPlatform: User.Platform.apple.rawValue
                    )
                    UserDefaults.standard.set(true, forKey: UserDefaults.Keys.isExistingAuth.rawValue)
//                    await self.userInfoWillFetchDB()
              //      self.state = .signedIn
                } catch let error as NSError {
                    self.errorMessage = error.localizedDescription
                    print("Apple SignIn Error: ", self.errorMessage)
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
