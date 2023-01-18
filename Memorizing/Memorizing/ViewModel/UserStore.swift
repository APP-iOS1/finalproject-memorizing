//
//  UserStore.swift
//  Memorizing
//
//  Created by 진준호 on 2023/01/05.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

// MARK: 회원가입, 로그인, 로그아웃, 내 암기장 등록, 암기장에 단어 추가, 암기장, 마이페이지 탭에서 필요한 모든 기능

@MainActor
class UserStore: ObservableObject {
//    // 종현님
    @Published var myWordNotes: [WordNote] = []
    @Published var myWords: [Word] = []
    // 태영
    @Published var state: SignInState = .check
    @Published var user: User?
    @Published var errorMessage: String = "" // Firestore 관련 에러 메세지
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
                UserDefaults.standard.set(email, forKey: UserDefaults.Keys.email.rawValue)
                UserDefaults.standard.set(password, forKey: UserDefaults.Keys.password.rawValue)
                self.state = .signedIn
                print("signed In complete")

            }
            /*
             {result, error in
             print("emailAuth.auth.signIn function")
             if let error = error{
             self.errorMessage = error.localizedDescription
             print("Login error: ", self.errorMessage)}
             if let user = result?.user{
             print("User SignIn")
             print("userId: ", user.uid)
             self.user = User(id: user.uid, email: user.email ?? "No Email", nickName: "", coin: 0)
             // 기기에 로그인 정보 저장
             UserDefaults.standard.set(email, forKey: UserDefaults.Keys.email.rawValue)
             UserDefaults.standard.set(password, forKey: UserDefaults.Keys.password.rawValue)
             self.state = .signedIn
             print("signed In complete")}}
             */
            await self.userInfoWillFetchDB()
        } catch {
            errorMessage = "로그인 정보가 맞지 않습니다."
            print("Login fail: \(self.errorMessage)")
            self.state = .signedOut     // 현기 추가
        }

    } // emailAuthSignIn

    // MARK: - FirebaseAuth SignUp Function /
    func signUpDidAuth(email: String, password: String, nickName: String) {
        self.errorMessage = ""
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }

            switch result {
            case .none:
                self.errorMessage = "계정을 생성할 수 없습니다."
            case .some:
                let id = result?.user.uid ?? UUID().uuidString
                let nickName = nickName
                let email = email
                let coin = 1000
                let user: User = User(id: id, email: email, nickName: nickName, coin: coin)
                self.userInfoDidSaveDB(user: user)
            }
        }
    } // emailAuthSignUp
    // MARK: - Firestore SignUp Function / FireStore-DB에 UserInfo를 저장함
    func userInfoDidSaveDB(user: User) {
        database.collection("users").document(user.id)
            .setData([
                "id": user.id,
                "email": user.email,
                "nickName": user.nickName,
                "coin": user.coin
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
    // MARK: - FetchUser Function / FireStore-DB에서 UserInfo를 불러옴
    func userInfoWillFetchDB() async {
        print("Start FetchUser")
        do {
            let document = try await database.collection("users").document(user?.id ?? "").getDocument()
            /*
             {(document, error) in
             if let document{
             print("start fetchUser function")
             let docData = document.data()
             self.user?.nickName = docData?["nickName"] as! String
             self.user?.coin = docData?["coin"] as! Int
             }

             }
             */
            if document.exists {
                let docData = document.data()
                self.user?.nickName = docData?["nickName"] as? String ?? ""
                self.user?.coin = docData?["coin"] as? Int ?? 0
                print("complete fetchUser Function")
            }
        } catch {
            print("Fail: fetchUser")
        }
        print("finish fetchUser function")
    } // fetchUser
//    // MARK: - myWordNotes를 페치하는 함수 / 내가 작성한 Notes를 Fetch함
//    func myNotesWillFetchDB() {
//        print("start fetchMyWordNotes")
//        database.collection("users").document(user?.id ?? "").collection("myWordNotes")
//            .order(by: "repeatCount")
//            .getDocuments { snapshot, error in
//            self.myWordNotes.removeAll()
//            if let snapshot {
//                for document in snapshot.documents {
//                    let docData = document.data()
//                    let id: String = docData["id"] as? String ?? ""
//                    let noteName: String = docData["noteName"] as? String ?? ""
//                    let noteCategory: String = docData["noteCategory"] as? String ?? ""
//                    let enrollmentUser: String = docData["enrollmentUser"] as? String ?? ""
//                    let repeatCount: Int = docData["repeatCount"] as? Int ?? 0
//                    let notePrice: Int = docData["notePrice"] as? Int ?? 0
//
//                    let myWordNote = WordNote(
//                        id: id,
//                        noteName: noteName,
//                        noteCategory: noteCategory,
//                        enrollmentUser: enrollmentUser,
//                        repeatCount: repeatCount,
//                        notePrice: notePrice
//                    )
//                    self.myWordNotes.append(myWordNote)
//                }
//                print("finished fetchMyWordNotes")
//                print("MyWordNotes: ", self.myWordNotes)
//            }
//        }
//    }
//    // MARK: - myWordNotes를 추가하는 함수 / 내가 작성한 Notes를 DB에 저장함
//    func myNotesDidSaveDB(wordNote: WordNote) {
//        database.collection("users").document(user?.id ?? "").collection("myWordNotes").document(wordNote.id)
//            .setData([
//                "id": wordNote.id,
//                "noteName": wordNote.noteName,
//                "noteCategory": wordNote.noteCategory,
//                "enrollmentUser": wordNote.enrollmentUser,
//                "repeatCount": wordNote.repeatCount,
//                "notePrice": wordNote.notePrice
//            ])
//        myNotesWillFetchDB()
//    }
//    // MARK: - words를 패치하는 함수 / 내가 작성한 Words를 Fetch함
//    func myWordsWillFetchDB(wordNote: WordNote, completion: @escaping () -> Void) {
//        database.collection("users").document(user?.id ?? "")
//            .collection("myWordNotes").document(wordNote.id)
//            .collection("words")
//            .order(by: "wordLevel")
//            .getDocuments { snapshot, error in
//                self.myWords.removeAll()
//                print("removed")
//                if let snapshot {
//                    for document in snapshot.documents {
//                        let docData = document.data()
//                        let id: String = docData["id"] as? String ?? ""
//                        let wordString: String = docData["wordString"] as? String ?? ""
//                        let wordMeaning: String = docData["wordMeaning"] as? String ?? ""
//                        let wordLevel: Int = docData["wordLevel"] as? Int ?? 0
//
//                        let word = Word(id: id, wordString: wordString, wordMeaning: wordMeaning, wordLevel: wordLevel)
//
//                        self.myWords.append(word)
//                    }
//                    print("finished fetchMyWords")
//                    print("fetchMyWords: ", self.myWords)
//                }
//                completion()
//            }
//    }
//
//    // MARK: - words를 추가하는 함수 / 내가 작성한 Words를 DB에 저장함
//    func myWordsDidSaveDB(wordNote: WordNote, word: Word) {
//        database.collection("users").document(user?.id ?? "")
//            .collection("myWordNotes").document(wordNote.id)
//            .collection("words").document(word.id)
//            .setData([
//                "id": word.id,
//                "wordString": word.wordString,
//                "wordMeaning": word.wordMeaning,
//                "wordLevel": word.wordLevel
//            ])
//        myWordsWillFetchDB(wordNote: wordNote) { }
//    }
//
//    // MARK: - 복습 완료시 파베에 repeatCount를 1씩 올림 / 반복학습에 따른 Count를 1씩 증가
//    func repeatCountDidPlusOne(wordNote: WordNote) async {
//        print("start plusRepeatCount")
//        do {
//            _ = try await database.collection("users").document(user?.id ?? "")
//                .collection("myWordNotes").document(wordNote.id)
//                .updateData([
//                    "repeatCount": FieldValue.increment(Int64(1))
//                ])
//            myNotesWillFetchDB()
//            print("finish plusRepeatCount")
//        } catch {
//            fatalError("fail plusRepeat Count")
//        }
//    }
//    // MARK: - 복습 다시하기 repeatcount를 0으로 초기화 / 반복학습이 완료될 경우, Count를 Reset
//    func repeatCountDidReset(wordNote: WordNote) {
//        database.collection("users").document(user?.id ?? "")
//            .collection("myWordNotes").document(wordNote.id)
//            .updateData([
//                "repeatCount": 0
//            ])
//        myNotesWillFetchDB()
//    }

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

//    // MARK: - 학습 시 각각 Words의 Level(난이도)값을 DB에 저장
//    func wordsLevelDidChangeDB(wordNote: WordNote, word: Word, level: Int) {
//        database.collection("users").document(user?.id ?? "")
//            .collection("myWordNotes").document(wordNote.id)
//            .collection("words").document(word.id)
//            .updateData([
//                "wordLevel": level
//            ])
//        print("updateWordLevel success")
//
//    }
}
// MARK: - UserDefaults extention: 기기에 로그인 정보를 담당하는 구조 추가
extension UserDefaults {

    enum Keys: String, CaseIterable {

        case email
        case password

    }

    func reset() {
        Keys.allCases.forEach { removeObject(forKey: $0.rawValue) }
    }
}
