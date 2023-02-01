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
            self.state = .signedIn
            self.user = User(id: user.uid, email: user.email ?? "email", nickName: "", coin: 0)
            await self.userInfoWillFetchDB()
        }
    }
    
    // MARK: - FirebaseAuth SignIn Function / Auth에 signIn을 진행함
    func signInDidAuth(email: String, password: String) async {
        print("start signInDidAuth function")
        self.errorMessage = ""
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            if let result = Auth.auth().currentUser {
                print("userId: ", result.uid)
                self.user = User(
                    id: result.uid,
                    email: result.email ?? "No Email",
                    nickName: result.displayName ?? "No Name",
                    coin: 0
                )
                // 기기에 로그인 정보 저장
                UserDefaults.standard.set(true, forKey: UserDefaults.Keys.isExistingAuth.rawValue)
                self.state = .signedIn
                print("signed In complete")
                
            }
            await self.userInfoWillFetchDB()
        } catch {
            errorMessage = "로그인 정보가 맞지 않습니다."
            print("Login fail: \(self.errorMessage)")
            self.state = .signedOut     // 현기 추가
        }
        
    } // emailAuthSignIn
    
    // MARK: - GoogleAuth SignIN Function
    func signInDidGoogleAuth() async {
        // 사전 로그인 기록이 있다면,
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
                Task {
                    await authenticateUser(for: user, with: error)
                    self.user = User(
                        id: user?.userID ?? "No User Id",
                        email: user?.profile?.email ?? "No Email",
                        nickName: user?.profile?.name ?? "No name",
                        coin: 0
                    )
                    print("Google restore Login")
                    UserDefaults.standard.set(true, forKey: UserDefaults.Keys.isExistingAuth.rawValue)
                    await userInfoWillFetchDB()
                    self.state = .signedIn
                }
            }
        } else {
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            let configuration = GIDConfiguration(clientID: clientID)
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
            
            GIDSignIn.sharedInstance.signIn(
                with: configuration,
                presenting: rootViewController
            ) { [unowned self] user, error in
                Task {
                    await authenticateUser(for: user, with: error)
                    
                    guard error == nil else { return }
                    guard let user = user else { return }
                    
                    self.user = User(
                        id: user.userID ?? "No ID",
                        email: user.profile?.email ?? "No Email",
                        nickName: user.profile?.name ?? "No name",
                        coin: 0
                    )
                    print("Google first Login")
                    UserDefaults.standard.set(true, forKey: UserDefaults.Keys.isExistingAuth.rawValue)
                    await userInfoWillFetchDB()
                    self.state = .signedIn
                }
            }
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
            print("google sign state signIn")
            self.state = .signedIn
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
                    print("Kakao Email: ", kakaoUser?.kakaoAccount?.email ?? "No Email")
                    await self.signUpDidAuth(
                        email: "Kakao_" + "\(kakaoUser?.kakaoAccount?.email ?? "No Email")",
                        password: "\(String(describing: kakaoUser?.id))",
                        nickName: kakaoUser?.kakaoAccount?.profile?.nickname ?? "No NickName"
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
                    print("New kakao Login")
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
                    print("New kakao Login")
                    _ = oauthToken
                    Task {
                        await self.loadingInfoDidKakaoAuth() // 사용자 정보 불러와서 Firebase Auth 로그인하기
                    }                                } // 로그인 성공
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
    func signUpDidAuth(email: String, password: String, nickName: String) async {
        self.errorMessage = ""
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            let id = result.user.uid
            let nickName = nickName
            let email = email
            let coin = 1000
            let user: User = User(id: id, email: email, nickName: nickName, coin: coin)
            self.userInfoDidSaveDB(user: user)
            
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("Email Sign up Error: ", self.errorMessage)
        }
    } // emailAuthSignUp
    
    // MARK: - Firestore SignUp Function / FireStore-DB에 UserInfo를 저장함
    func userInfoDidSaveDB(user: User) {
        database.collection("users").document(user.id)
            .setData([
                "id": user.id,
                "email": user.email,
                "nickName": user.nickName,
                "coin": 1000
            ])
    } // FireStore-DB에 UserInfo를 저장함
    
    // MARK: - FirebaseAuth SignOut Function / Auth에 signOut을 진행함
    func signOutDidAuth() {
        print("start emailAuthSignOut")
        self.errorMessage = ""
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            self.signOutDidKakao()
            UserDefaults.standard.reset()
            state = .signedOut
            self.user = nil
            print("finish emailAuthSignOut")
        } catch let signOutError as NSError {
            self.errorMessage = signOutError.localizedDescription
            print("SignOut Fail: ", errorMessage)
        }
    } // emailAuthSignOut
    
    // MARK: - GoogleAuth SignOut Function
    /*
    func signOutDidGoogleAuth() {
        self.errorMessage = ""
        GIDSignIn.sharedInstance.signOut()
        
        do {
            try Auth.auth().signOut()
            state = .signedOut
            UserDefaults.standard.reset()
            self.user = nil
        } catch {
            self.errorMessage = error.localizedDescription
            print("google Sign Out error: ", self.errorMessage)
        }
    }
    */
    
    // MARK: - KakaoAuth SignOut Function
    func signOutDidKakao() {
        UserApi.shared.logout { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                print("Kakao logout error: ", self.errorMessage)
            } else {
                print("Kakao SignOut")
            }
        }
    }
    
    // MARK: - FetchUser Function / FireStore-DB에서 UserInfo를 불러옴
    func userInfoWillFetchDB() async {
        print("Start FetchUser")
        do {
            let document = try await database.collection("users").document(user?.id ?? "").getDocument()
            if document.exists {
                let docData = document.data()
                self.user?.nickName = docData?["nickName"] as? String ?? ""
                self.user?.coin = docData?["coin"] as? Int ?? 0
                print("complete fetchUser Function")
            } else {
                self.userInfoDidSaveDB(user: self.user!)
                self.user?.coin = 1000
            }
        } catch {
            print("Fail: fetchUser")
        }
        print("finish fetchUser function")
    } // fetchUser
    
    // MARK: - 현재 유저의 coin 상태를 확인하고 살 수 있으면 coin이 깍이면서 다음 함수로 넘어감 / 현재 User의 Coin 갯수를 Check
    // TODO: - 나중에 태영님쪽에서 유저정보를 받아오게되면 그 부분에서 사용해줘야할 수도 있음
//    func userCoinWillCheckDB(marketWordNote: WordNote, words: [Word]) {
//        if user?.coin ?? 0 >= marketWordNote.notePrice {
//            // 사는 함수 실행
//            let calculatedCoin = (user?.coin ?? 0) - marketWordNote.notePrice
//
//            database.collection("users")
//                .document(user?.id ?? "")
//                .updateData([
//                    "coin": calculatedCoin
//                ])
//
//            database.collection("users")
//                .document(marketWordNote.enrollmentUser)
//                .updateData([
//                    "coin": FieldValue.increment(Int64(marketWordNote.notePrice))
//                ])
//
//            notesWillBringDB(marketWordNote: marketWordNote, words: words)
//
//        }
//    }
    
    // MARK: - User의 닉네임을 변경
    func userInfoDidChangeDB(nickName: String) async throws {
        do {
            _ = try await database.collection("users").document(user?.id ?? "").updateData([
                "nickName": nickName
            ])
            
            await userInfoWillFetchDB()
        } catch {
            fatalError("fail update User")
        }
    }
}
