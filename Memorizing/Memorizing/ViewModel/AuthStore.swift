//
//  AuthStore.swift
//  Memorizing
//
//  Created by 진태영 on 2023/01/18.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import GoogleSignInSwift
import KakaoSDKAuth
import KakaoSDKUser
import AuthenticationServices
import CryptoKit

@MainActor
class AuthStore: UIViewController, ObservableObject {
    let coredataStore: CoreDataStore = CoreDataStore()
    // 태영
    @Published var state: SignInState = .signedOut
    @Published var user: User?
    @Published var errorMessage: String = "" // Firestore 관련 에러 메세지
    var currentNonce: String?
    
    enum SignInState {
        case signedIn
        case signedOut
        case firstIn    // 현기 추가
        case check    // 현기 추가
    }
    
    let database = Firestore.firestore()
    
    // MARK: - FirebaseAuth listen To Auth State
    func signInDidExistingAuth() async {
        if let user = Auth.auth().currentUser {
            self.user = User(
                id: user.uid,
                email: user.email ?? "email",
                nickName: "",
                coin: 0,
                signInPlatform: User.Platform.google.rawValue
            )
//            await self.userInfoWillFetchDB()
        }
    }
    
    // MARK: - FirebaseAuth SignIn Function / Auth에 signIn을 진행함
    func signInDidAuth(email: String, password: String) async {
        self.errorMessage = ""
        do {
            self.user = User(id: "", email: "", nickName: "", coin: 0, signInPlatform: User.Platform.kakao.rawValue)
            try await Auth.auth().signIn(withEmail: email, password: password)
            if let result = Auth.auth().currentUser {
                self.user = User(
                    id: result.uid,
                    email: result.email ?? "No Email",
                    nickName: result.displayName ?? "No Name",
                    coin: 0,
                    signInPlatform: User.Platform.kakao.rawValue
                )
                // 기기에 로그인 정보 저장
                UserDefaults.standard.set(true, forKey: UserDefaults.Keys.isExistingAuth.rawValue)
                //   self.state = .signedIn
                
            }
//            await self.userInfoWillFetchDB()
        } catch {
            errorMessage = "로그인 정보가 맞지 않습니다."
            print("Login fail: \(self.errorMessage)")
            self.state = .signedOut     // 현기 추가
        }
        
    } // emailAuthSignIn
    
    // MARK: - GoogleAuth SignIN Function
    func signInDidGoogleAuth() async {
        // 사전 로그인 기록이 있다면,
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            let configuration = GIDConfiguration(clientID: clientID)
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
        self.user = User(id: "", email: "", nickName: "", coin: 0, signInPlatform: User.Platform.google.rawValue)

            GIDSignIn.sharedInstance.signIn(
                with: configuration,
                presenting: rootViewController
            ) { [unowned self] user, error in
                Task {
                    await authenticateUser(for: user, with: error)
                    
                    guard error == nil else { return }
                    guard let user = user else { return }
                    self.user = User(
                        id: Auth.auth().currentUser?.uid ?? "No ID",
                        email: user.profile?.email ?? "No Email",
                        nickName: user.profile?.name ?? "No name",
                        coin: 0,
                        signInPlatform: User.Platform.google.rawValue
                    )
                    UserDefaults.standard.set(true, forKey: UserDefaults.Keys.isExistingAuth.rawValue)
//                    await userInfoWillFetchDB()
                    //    self.state = .signedIn
                }
     //       }
        }
    }
    
    // MARK: 구글의 id Token 발급받아 FirebaseAuth에 접근하여 로그인하는 함수
    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?) async {
        self.errorMessage = ""
        if let error = error {
            self.errorMessage = error.localizedDescription
            print("Google Login error: ", errorMessage)
            return
        }
        guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
        do {
            try await Auth.auth().signIn(with: credential)
            //    self.state = .signedIn
        } catch let error as NSError {
            errorMessage = error.localizedDescription
            print("Error sign In:", errorMessage)
        }
    }
    
    // MARK: - KakaoAuth SignIn Function
    func signInDidKakaoAuth() async {
        self.errorMessage = ""
        if AuthApi.hasToken() { // 발급된 토큰이 있는지
            UserApi.shared.accessTokenInfo { _, error in // 해당 토큰이 유효한지
                if let error = error { // 에러가 발생했으면 토큰이 유효하지 않다.
                    self.errorMessage = error.localizedDescription
                    print("Kakao loading token Info error: ", self.errorMessage)
                    print("Kakao loading token info error code: ", error.asAFError?.responseCode as Any)
                    self.openKakaoService()
                } else { // 유효한 토큰
                    Task {
                        await self.loadingInfoDidKakaoAuth()
                    }
                }
            } // 토큰 접근
        } else { // 발급된 토큰 만료
            self.openKakaoService()
        }
    }
    
    func loadingInfoDidKakaoAuth() async {  // 사용자 정보 불러오기
        
        UserApi.shared.me { kakaoUser, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                print("Kakao loading user Info error: ", self.errorMessage)
            } else {
                Task {
                    await self.signUpDidAuth(
                        email: "Kakao_" + "\(kakaoUser?.kakaoAccount?.email ?? "No Email")",
                        password: "\(String(describing: kakaoUser?.id))"
                    )
                    await self.signInDidAuth(
                        email: "Kakao_" + "\(kakaoUser?.kakaoAccount?.email ?? "No Email")",
                        password: "\(String(describing: kakaoUser?.id))"
                    )
                }
            }
            
        }
    }
    
    func openKakaoService() {
        if UserApi.isKakaoTalkLoginAvailable() { // 카카오톡 앱 이용 가능한지
            UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("Kakao Sign In Error: ", self.errorMessage)
                } else { // 로그인 성공
                    _ = oauthToken
                    Task {
                        await self.loadingInfoDidKakaoAuth() // 사용자 정보 불러와서 Firebase Auth 로그인하기
                    }
                }
            } // 카카오톡 앱 로그인
        } else { // 카카오톡 앱 이용 불가능한 사람
            UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.errorMessage = error.localizedDescription
                    print("Kakao web Sign in error: ", self.errorMessage)
                    print("Kakao web Sign in error code: ", error.asAFError?.responseCode as Any)
                } else { // 로그인 성공
                    _ = oauthToken
                    Task {
                        await self.loadingInfoDidKakaoAuth() // 사용자 정보 불러와서 Firebase Auth 로그인하기
                    }
                } // 로그인 성공
            } // 카톡 로그인
        } // 웹 로그인
    }
    
    // MARK: - AppleAuth SignIn Function
    @available(iOS 13, *)
    func signInDidAppleAuth() {
        let request = createAppleIDRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        currentNonce = nonce
        
        return request
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    // MARK: - FirebaseAuth SignUp Function /
    func signUpDidAuth(email: String, password: String) async {
        self.errorMessage = ""
        do {
            // 카카오는 이메일 등록으로 진행된다.
            // 이메일로 등록된 계정은 로그인할 때 다른 소셜 로그인 계정과 중복되면 로그인 불가 -> 다른 소셜 로그인 이메일은 직접 변경이 어려움으로 이메일 등록 계정을 변경해준다.
            try await Auth.auth().createUser(withEmail: email, password: password)
            
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("Email Sign up Error: ", self.errorMessage)
        }
    } // emailAuthSignUp
    
    // MARK: - Firestore SignUp Function / FireStore-DB에 UserInfo를 저장함
    func userInfoDidSaveDB(platform: String) {
        if let currentUser = Auth.auth().currentUser {
            var newEmail = Auth.auth().currentUser?.email ?? "\(self.user!.email)"
            if newEmail.hasPrefix("kakao_") {
                let range = newEmail.firstRange(of: "kakao_")
                newEmail.removeSubrange(range!)
            }
            self.user!.coin = 1000
            database.collection("users").document(currentUser.uid)
                .setData([
                    "id": currentUser.uid,
                    "email": newEmail,
                    "nickName": self.user!.nickName,
                    "coin": 1000,
                    "signInPlatform": self.user!.signInPlatform
                ])
        }
    } // FireStore-DB에 UserInfo를 저장함
    
    // MARK: - FirebaseAuth SignOut Function / Auth에 signOut을 진행함
    func signOutDidAuth() {
        self.errorMessage = ""
        do {
            try Auth.auth().signOut()
            if self.user?.signInPlatform == User.Platform.google.rawValue {
                GIDSignIn.sharedInstance.signOut()
            } else if self.user?.signInPlatform == User.Platform.kakao.rawValue {
                self.signOutDidKakao()
            }
            UserDefaults.standard.reset()
            state = .signedOut
            self.user = nil
        } catch let signOutError as NSError {
            self.errorMessage = signOutError.localizedDescription
            print("SignOut Fail: ", errorMessage)
        }
    } // AuthSignOut
    
    // MARK: - KakaoAuth SignOut Function
    func signOutDidKakao() {
        UserApi.shared.logout { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                print("Kakao logout error: ", self.errorMessage)
            } else {
            }
        }
    }
    
    // MARK: - FetchUser Function / FireStore-DB에서 UserInfo를 불러옴
    func userInfoWillFetchDB() async {
       
        do {
            let document = try await database.collection("users").document(Auth.auth().currentUser?.uid ?? "").getDocument()
            if document.exists {
                let docData = document.data()
                self.user?.id = docData?["id"] as? String ?? ""
                self.user?.nickName = docData?["nickName"] as? String ?? ""
                self.user?.email = docData?["email"] as? String ?? "No DB"
                self.user?.coin = docData?["coin"] as? Int ?? 0
                self.user?.signInPlatform = docData?["signInPlatform"] as? String ?? User.Platform.google.rawValue
                self.state = .signedIn
            } else {
                self.state = .firstIn
                self.userInfoDidSaveDB(platform: self.user!.signInPlatform)
                
                
            }
        } catch {
            print("Fail: fetchUser")
        }
    } // fetchUser
    
    // MARK: - User의 닉네임을 변경
    func userInfoDidChangeDB(nickName: String) async throws {
        do {
            _ = try await database.collection("users").document(user?.id ?? "").updateData([
                "nickName": nickName
            ])
            
            self.user?.nickName = nickName
        } catch {
            fatalError("fail update User")
        }
    }
    
    // MARK: - 회원 탈퇴
    func deleteAccount() async {
        self.errorMessage = ""
        let user = Auth.auth().currentUser

        do {
            try await user?.delete()
            if self.user?.signInPlatform == User.Platform.kakao.rawValue {
                UserApi.shared.unlink { error in
                    if let error = error {
                        print("카카오톡 연결 끊기 실패: \(error.localizedDescription)")
                    }
                }
            } else if self.user?.signInPlatform == User.Platform.google.rawValue {
                GIDSignIn.sharedInstance.disconnect { error in
                    if let error = error {
                        print("구글 계정 연결 해제 오류: \(error.localizedDescription)")
                    }
                }
            }
            
            try await self.database.collection("users").document(self.user!.id)
                .updateData([
                    "userState": 3
                ])
            self.signOutDidAuth()
        } catch let error as NSError {
            /*
             error code: 17014
             error description: This operation is sensitive and requires recent authentication. Log in again before retrying this request.
             */
            print("탈퇴 에러코드: \(error._code)")
            switch error._code {
            case 17014:
                if self.user?.signInPlatform == User.Platform.apple.rawValue {
                    signInDidAppleAuth()
                } else if self.user?.signInPlatform == User.Platform.google.rawValue {
                    await signInDidGoogleAuth()
                } else {
                    await signInDidKakaoAuth()
                }
            default:
                print("탈퇴 에러: \(error.localizedDescription)")
                print("탈테 에러 코드: \(error._code)")
            }
        }
    }
    
    func plusUserPoint(point: Double) async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        do {
            try await database.collection("users").document(currentUserId).updateData([
                "coin" : FieldValue.increment(point)
            ])
        } catch {
            print("plusUserPoint error occured: \(error.localizedDescription)")
        }
        

        
    }
}
