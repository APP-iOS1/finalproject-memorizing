//
//  MarketStore.swift
//  Memorizing
//
//  Created by 진준호 on 2023/01/05.
//

import Foundation
import Firebase
import FirebaseFirestore

// MARK: 마켓에 내 단어장 등록하기, 단어장 구매 등 마켓 탭에서 필요한 모든 기능

class MarketStore: ObservableObject {
    @Published var marketWordNotes: [MarketWordNote] = []
    @Published var words: [Word] = []
    
    @Published var sendWordNote = MarketWordNote(id: "",
                                                 noteName: "",
                                                 noteCategory: "",
                                                 enrollmentUser: "",
                                                 notePrice: 0,
                                                 updateDate: Date.now,
                                                 salesCount: 0,
                                                 starScoreTotal: 0,
                                                 reviewCount: 0)
    
    @Published var currentUser: Firebase.User? = Auth.auth().currentUser
    
    let database = Firestore.firestore()
    
    // MARK: - 마켓의 전체 단어장들을 fetch 하는 함수 / Market View에서 전체 Notes를 Fetch 함
    func marketNotesWillFetchDB() async {
        do {
            let documents = try await database.collection("marketWordNotes").getDocuments()
            
            for document in documents.documents {
                let docData = document.data()
                
                let id: String = docData["id"] as? String ?? ""
                let noteName: String = docData["noteName"] as? String ?? ""
                let noteCategory: String = docData["noteCategory"] as? String ?? ""
                let enrollmentUser: String = docData["enrollmentUser"] as? String ?? ""
                let notePrice: Int = docData["notePrice"] as? Int ?? 0
                let createdAtTimeStamp: Timestamp = docData["updateDate"] as? Timestamp ?? Timestamp()
                let updateDate: Date = createdAtTimeStamp.dateValue()
                let salesCount: Int = docData["salesCount"] as? Int ?? 0
                let starScoreTotal: Double = docData["starScoreTotal"] as? Double ?? 0
                let reviewCount: Int = docData["reviewCount"] as? Int ?? 0
                
                let marketWordNote = MarketWordNote(id: id,
                                                    noteName: noteName,
                                                    noteCategory: noteCategory,
                                                    enrollmentUser: enrollmentUser,
                                                    notePrice: notePrice,
                                                    updateDate: updateDate,
                                                    salesCount: salesCount,
                                                    starScoreTotal: starScoreTotal,
                                                    reviewCount: reviewCount)
                
                self.marketWordNotes.append(marketWordNote)
            }
        } catch {
            print("marketNotesWillFetchDB Function Error: \(error)")
        }
    }
    
    // MARK: - 단어장을 들어가면 해당 단어장의 단어들을 fetch 하는 함수 / 마켓에 위치한 Notes의 단어를 Fetch
    func wordsWillFetchDB(wordNoteID: String) async {
        do {
            let documents = try await database.collection("marketWordNotes").document(wordNoteID)
                .collection("words").getDocuments()
            
            for document in documents.documents {
                let docData = document.data()
                
                let id: String = docData["id"] as? String ?? ""
                let wordString: String = docData["wordString"] as? String ?? ""
                let wordMeaning: String = docData["wordMeaning"] as? String ?? ""
                let wordLevel: Int = 0
                let word: Word = Word(
                    id: id,
                    wordString: wordString,
                    wordMeaning: wordMeaning,
                    wordLevel: wordLevel
                )
                
                self.words.append(word)
            }
        } catch {
            print("wordsWillFetchDB Function Error: \(error)")
        }
    }
    
    // MARK: - 마켓에 단어장을 등록하면 해당 단어장이 마켓 DB에 올라가게 하는 함수
    func marketNotesDidSaveDB(noteID: String, notePrice: Int) async {
        do {
            // 유저 암기장에 접근해서 암기장 들고오는 과정
            let myDocument = try await database.collection("users").document(currentUser?.uid ?? "")
                .collection("myWordNotes").document(noteID).getDocument()
            
            let docData = myDocument.data()
            let id: String = docData?["id"] as? String ?? ""
            let noteName: String = docData?["noteName"] as? String ?? ""
            let noteCategory: String = docData?["noteCategory"] as? String ?? ""
            let enrollmentUser: String = docData?["enrollmentUser"] as? String ?? ""
            
            // type의 혼동을 막기위해 정의를 해서 아래 마켓에 넣어줌
            let updateDate: Date = Date.now
            let salesCount: Int = 0
            let starScoreTotal: Double = 0
            let reviewCount: Int = 0
            
            // 마켓에 접근해서 들고온 암기장을 올려주는 과정
            try await database.collection("marketWordNotes").document(noteID)
                .setData([
                    "id": id,
                    "noteName": noteName,
                    "noteCategory": noteCategory,
                    "enrollmentUser": enrollmentUser,
                    "notePrice": notePrice,
                    "updateDate": updateDate,
                    "salesCount": salesCount,
                    "starScoreTotal": starScoreTotal,
                    "reviewCount": reviewCount
                ])
            print("Add WordNote to Market complete")
            
            await self.marketNoteWordsDidSaveDB(noteID: noteID)
            await self.marketNotesWillFetchDB()
            
        } catch {
            print("marketMotesDidSaveDB Function Error: \(error)")
        }
    }
    
    // MARK: - 내 단어장을 마켓에 올리면 안에 단어들이 함께 마켓에 올라가도록 하는 함수
    func marketNoteWordsDidSaveDB(noteID: String) async {
        do {
            let myDocuments = try await database.collection("users").document(currentUser?.uid ?? "")
                .collection("myWordNotes").document(noteID)
                .collection("words").getDocuments()
            
            for document in myDocuments.documents {
                let docData = document.data()
                
                let id: String = docData["id"] as? String ?? ""
                let wordString: String = docData["wordString"] as? String ?? ""
                let wordMeaning: String = docData["wordMeaning"] as? String ?? ""
                
                try await database.collection("marketWordNotes").document(noteID)
                    .collection("words").document(id)
                    .setData([
                        "id": id,
                        "wordString": wordString,
                        "wordMeaning": wordMeaning
                    ])
            }
            print("Add Word to MarketWordNote complete")
        } catch {
            print("marketNoteWordsDidSaveDB Function Error: \(error)")
        }
    }
    
    // MARK: - 현재 유저의 coin 상태를 확인하고 살 수 있으면 coin이 깍이면서 다음 함수로 넘어감 / 현재 User의 Coin 갯수를 Check
    func userCoinWillCheckDB(marketWordNote: MarketWordNote, words: [Word]) {
        // TODO: - 현재 유저의 코인값을 받아와야됨 태영님 작업 끝나면 거기서 접근해서 들고와볼것...
        let userCoin: Int = 0
        
        if userCoin >= marketWordNote.notePrice {
            // 사는 함수 실행
            let calculatedCoin = (userCoin) - marketWordNote.notePrice
            
            database.collection("users")
                .document(currentUser?.uid ?? "")
                .updateData([
                    "coin": calculatedCoin
                ])
            
            database.collection("users")
                .document(marketWordNote.enrollmentUser)
                .updateData([
                    "coin": FieldValue.increment(Int64(marketWordNote.notePrice))
                ])
            
            marketNotesWillBringMyNotesDB(marketWordNote: marketWordNote, words: words)
        }
    }
    
    // MARK: - 마켓에서 단어장 가져오는 기능 (단어장 구매) / Market에서 Note를 구매할 경우, 해당 note를 DB에 저장 및 불러오기
    func marketNotesWillBringMyNotesDB(marketWordNote: MarketWordNote, words: [Word]) {
        let id = UUID().uuidString
        
        let wordNote = ["id": id,
                        "noteName": marketWordNote.noteName,
                        "noteCategory": marketWordNote.noteCategory,
                        "enrollmentUser": marketWordNote.enrollmentUser,
                        "repeatCount": 0,
                        "testResultFirst": 0,
                        "testResultLast": 0,
                        "updateData": Date.now] as [String: Any]
        
        database.collection("users")
            .document(currentUser?.uid ?? "")
            .collection("myWordNotes")
            .document(id)
            .setData(wordNote) { error in
                if let error = error {
                    print(error)
                    return
                }
                
                print("WordNote Complete")
            }
        
        marketWordsWillBringMyWordsDB(marketWords: words, noteId: id)
    }
    
    // MARK: - 위 함수에서 단어들을 받아오는 역할, 개별적으로는 사용하지 않을 예정 / Market에서 Note를 구매할 경우, 해당 words를 DB에 저장 및 불러옴
    func marketWordsWillBringMyWordsDB(marketWords: [Word], noteId: String) {
        
        for marketWord in marketWords {
            let word = [
                "id": marketWord.id,
                "wordString": marketWord.wordString,
                "wordMeaning": marketWord.wordMeaning,
                "wordLevel": 0] as [String: Any]
            
            database.collection("users")
                .document(currentUser?.uid ?? "")
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
    
    // MARK: - 등록해제하면 해당 암기장 데이터들은 마켓컬렉션에서 삭제되도록 하는 함수
    func marketNotesWillDeleteDB(marketWordNote: MarketWordNote, words: [Word]) {
        database.collection("marketWordNotes").document(marketWordNote.id).delete()
    }
    
    // TODO: - 마켓에서 구매하고 나면 다시 중복구매를 방지하기위해 filterWordNotes와 myWordNoteIDArray를 넣어줬는데
    // TODO: - 기존에 만들어져 있는 함수 및 다른 방법을 사용해서 구할 수 있도록 변경해볼것(View에서 변경)
//    // MARK: - Market에서 Note를 구매할 경우, 해당 Notes를 My Notes DB에 저장
//    func notesWillFetchDB() {
//        self.filterWordNotes.removeAll()
//
//        let marketWordNotes = MarketStore().marketWordNotes
//        var marketNoteId: [String] = []
//
//        for marketWordNote in marketWordNotes {
//            marketNoteId.append(marketWordNote.id)
//        }
//
//        for myWordNote in myWordNotes where myWordNote.enrollmentUser == user?.id {
//                self.filterWordNotes.append(myWordNote)
//        }
//    }
//
//    // MARK: - Market에서 Note를 구매할 경우, My Notes Array DB에서 불러옴
//    func notesArrayWillFetchDB() {
//        myWordNoteIdArray.removeAll()
//
//        for myWordNote in myWordNotes {
//            myWordNoteIdArray.append(myWordNote.id)
//        }
//    }
}
