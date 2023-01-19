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

@MainActor
class AuthStore: ObservableObject {
    
    // 태영
    @Published var state: SignInState = .signedOut
    @Published var user: User?
    @Published var errorMessage: String = "" // Firestore 관련 에러 메세지
    
    // 종현님
    @Published var myWordNotes: [WordNote] = []
    @Published var myWords: [Word] = []
    
    // 준호
    @Published var filterWordNotes: [WordNote] = []
    @Published var myWordNoteIdArray: [String] = []
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
                self.user = User(id: result.uid, email: result.email ?? "No Email", nickName: "", coin: 0)
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
            UserDefaults.standard.reset()
            state = .signedOut
            self.user = nil
            self.myWords = []
            self.myWordNotes = []
            print("finish emailAuthSignOut")
        } catch let signOutError as NSError {
            self.errorMessage = signOutError.localizedDescription
            print("SignOut Fail: ", errorMessage)
        }
    } // emailAuthSignOut
    
    // MARK: - GoogleAuth SignOut Function
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
    
    // MARK: - myWordNotes를 페치하는 함수 / 내가 작성한 Notes를 Fetch함
    func myNotesWillFetchDB() {
        print("start fetchMyWordNotes")
        database.collection("users").document(user?.id ?? "").collection("myWordNotes")
            .order(by: "repeatCount")
            .getDocuments { snapshot, _ in
                self.myWordNotes.removeAll()
                if let snapshot {
                    for document in snapshot.documents {
                        let docData = document.data()
                        let id: String = docData["id"] as? String ?? ""
                        let noteName: String = docData["noteName"] as? String ?? ""
                        let noteCategory: String = docData["noteCategory"] as? String ?? ""
                        let enrollmentUser: String = docData["enrollmentUser"] as? String ?? ""
                        let repeatCount: Int = docData["repeatCount"] as? Int ?? 0
                        let notePrice: Int = docData["notePrice"] as? Int ?? 0
                        
                        let myWordNote = WordNote(
                            id: id,
                            noteName: noteName,
                            noteCategory: noteCategory,
                            enrollmentUser: enrollmentUser,
                            repeatCount: repeatCount,
                            notePrice: notePrice
                        )
                        self.myWordNotes.append(myWordNote)
                    }
                    print("finished fetchMyWordNotes")
                    print("MyWordNotes: ", self.myWordNotes)
                }
            }
    }
    
    // MARK: - myWordNotes를 추가하는 함수 / 내가 작성한 Notes를 DB에 저장함
    func myNotesDidSaveDB(wordNote: WordNote) {
        database.collection("users").document(user?.id ?? "").collection("myWordNotes").document(wordNote.id)
            .setData([
                "id": wordNote.id,
                "noteName": wordNote.noteName,
                "noteCategory": wordNote.noteCategory,
                "enrollmentUser": wordNote.enrollmentUser,
                "repeatCount": wordNote.repeatCount,
                "notePrice": wordNote.notePrice
            ])
        myNotesWillFetchDB()
    }
    
    // MARK: - words를 패치하는 함수 / 내가 작성한 Words를 Fetch함
    func myWordsWillFetchDB(wordNote: WordNote, completion: @escaping () -> Void) {
        database.collection("users").document(user?.id ?? "")
            .collection("myWordNotes").document(wordNote.id)
            .collection("words")
            .order(by: "wordLevel")
            .getDocuments { snapshot, _ in
                self.myWords.removeAll()
                print("removed")
                if let snapshot {
                    for document in snapshot.documents {
                        let docData = document.data()
                        let id: String = docData["id"] as? String ?? ""
                        let wordString: String = docData["wordString"] as? String ?? ""
                        let wordMeaning: String = docData["wordMeaning"] as? String ?? ""
                        let wordLevel: Int = docData["wordLevel"] as? Int ?? 0
                        
                        let word = Word(id: id, wordString: wordString, wordMeaning: wordMeaning, wordLevel: wordLevel)
                        
                        self.myWords.append(word)
                    }
                    print("finished fetchMyWords")
                    print("fetchMyWords: ", self.myWords)
                }
                completion()
            }
    }
    
    // MARK: - words를 추가하는 함수 / 내가 작성한 Words를 DB에 저장함
    func myWordsDidSaveDB(wordNote: WordNote, word: Word) {
        database.collection("users").document(user?.id ?? "")
            .collection("myWordNotes").document(wordNote.id)
            .collection("words").document(word.id)
            .setData([
                "id": word.id,
                "wordString": word.wordString,
                "wordMeaning": word.wordMeaning,
                "wordLevel": word.wordLevel
            ])
        myWordsWillFetchDB(wordNote: wordNote) { }
    }
    
    // MARK: - 복습 완료시 파베에 repeatCount를 1씩 올림 / 반복학습에 따른 Count를 1씩 증가
    func repeatCountDidPlusOne(wordNote: WordNote) async {
        print("start plusRepeatCount")
        do {
            _ = try await database.collection("users").document(user?.id ?? "")
                .collection("myWordNotes").document(wordNote.id)
                .updateData([
                    "repeatCount": FieldValue.increment(Int64(1))
                ])
            myNotesWillFetchDB()
            print("finish plusRepeatCount")
        } catch {
            fatalError("fail plusRepeat Count")
        }
    }
    
    // MARK: - 복습 다시하기 repeatcount를 0으로 초기화 / 반복학습이 완료될 경우, Count를 Reset
    func repeatCountDidReset(wordNote: WordNote) {
        database.collection("users").document(user?.id ?? "")
            .collection("myWordNotes").document(wordNote.id)
            .updateData([
                "repeatCount": 0
            ])
        myNotesWillFetchDB()
    }
    
    // MARK: - 현재 유저의 coin 상태를 확인하고 살 수 있으면 coin이 깍이면서 다음 함수로 넘어감 / 현재 User의 Coin 갯수를 Check
    func userCoinWillCheckDB(marketWordNote: WordNote, words: [Word]) {
        if user?.coin ?? 0 >= marketWordNote.notePrice {
            // 사는 함수 실행
            let calculatedCoin = (user?.coin ?? 0) - marketWordNote.notePrice
            
            database.collection("users")
                .document(user?.id ?? "")
                .updateData([
                    "coin": calculatedCoin
                ])
            
            database.collection("users")
                .document(marketWordNote.enrollmentUser)
                .updateData([
                    "coin": FieldValue.increment(Int64(marketWordNote.notePrice))
                ])
            
            notesWillBringDB(marketWordNote: marketWordNote, words: words)
            
        }
    }
    
    // MARK: - 마켓에서 단어장 가져오는 기능 (단어장 구매) / Market에서 Note를 구매할 경우, 해당 note를 DB에 저장 및 불러오기
    func notesWillBringDB(marketWordNote: WordNote, words: [Word]) {
        let id = UUID().uuidString
        
        let wordNote = ["id": id,
                        "noteName": marketWordNote.noteName,
                        "notePrice": marketWordNote.notePrice,
                        "noteCategory": marketWordNote.noteCategory,
                        "enrollmentUser": marketWordNote.enrollmentUser,
                        "repeatCount": marketWordNote.repeatCount] as [String: Any]
        
        database.collection("users")
            .document(user?.id ?? "")
            .collection("myWordNotes")
            .document(id)
            .setData(wordNote) { error in
                if let error = error {
                    print(error)
                    return
                }
                
                print("WordNote Complete")
            }
        
        wordsWillBringDB(marketWords: words, noteId: id)
    }
    
    // MARK: - 위 함수에서 단어들을 받아오는 역할, 개별적으로는 사용하지 않을 예정 / Market에서 Note를 구매할 경우, 해당 words를 DB에 저장 및 불러옴
    func wordsWillBringDB(marketWords: [Word], noteId: String) {
        
        for marketWord in marketWords {
            let word = [
                "id": marketWord.id,
                "wordString": marketWord.wordString,
                "wordMeaning": marketWord.wordMeaning,
                "wordLevel": marketWord.wordLevel
            ] as [String: Any]
            
            database.collection("users")
                .document(user?.id ?? "")
                .collection("myWordNotes")
                .document(noteId)
                .collection("words")
                .document(marketWord.id)
                .setData(word) { error in
                    if let error = error {
                        print(error)
                        return
                    }
                    
                    print("Buy Market WordNote Success")
                }
        }
    }
    
    // MARK: - Market에서 Note를 구매할 경우, 해당 Notes를 My Notes DB에 저장
    func notesWillFetchDB() {
        self.filterWordNotes.removeAll()
        
        let marketWordNotes = MarketStore().marketWordNotes
        var marketNoteId: [String] = []
        
        for marketWordNote in marketWordNotes {
            marketNoteId.append(marketWordNote.id)
        }
        
        for myWordNote in myWordNotes where myWordNote.enrollmentUser == user?.id {
            self.filterWordNotes.append(myWordNote)
        }
    }
    
    // MARK: - Market에서 Note를 구매할 경우, My Notes Array DB에서 불러옴
    func notesArrayWillFetchDB() {
        myWordNoteIdArray.removeAll()
        
        for myWordNote in myWordNotes {
            myWordNoteIdArray.append(myWordNote.id)
        }
    }
    
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
    
    // MARK: - 학습 시 각각 Words의 Level(난이도)값을 DB에 저장
    func wordsLevelDidChangeDB(wordNote: WordNote, word: Word, level: Int) {
        database.collection("users").document(user?.id ?? "")
            .collection("myWordNotes").document(wordNote.id)
            .collection("words").document(word.id)
            .updateData([
                "wordLevel": level
            ])
        print("updateWordLevel success")
        
    }
}

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
