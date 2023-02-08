//
//  MarketStore.swift
//  Memorizing
//
//  Created by 진준호 on 2023/01/05.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore

// MARK: 마켓에 내 단어장 등록하기, 단어장 구매 등 마켓 탭에서 필요한 모든 기능
@MainActor // wordsWillFetchDB 메서드 내 words 변수에 할당을 위해서
class MarketStore: ObservableObject {
    @Published var marketWordNotes: [MarketWordNote] = []
    @Published var words: [Word] = []
    @Published var filterMyWordNotes: [MyWordNote] = []
    @Published var myWordNoteIdArray: [String] = []
    
    // 리스너를 위해 필요한 프로퍼티
    // @Published var currentCoin: Int = 0
    
    // MARK: - Pagination(InfiniteScroll) 구현 코드
    // @Published var snapshotCounter: Int = 19
    // private var lastDocumentSnapshot: DocumentSnapshot?
    // MARK: - 여기까지
    
    @Published var sendWordNote = MarketWordNote(id: "",
                                                 noteName: "",
                                                 noteCategory: "",
                                                 enrollmentUser: "",
                                                 notePrice: 0,
                                                 updateDate: Date.now,
                                                 salesCount: 0,
                                                 starScoreTotal: 0,
                                                 reviewCount: 0)
    
    let database = Firestore.firestore()
    
    // MARK: - 마켓의 전체 단어장들을 fetch 하는 함수 / Market View에서 전체 Notes를 Fetch 함
    // sortingCategory 현재에는 salesCount도 없는 데이터가 많고 reviewCount도 그렇기 때문에 고정값을 noteName으로 해놓음
    // 나중에 데이터를 유의미하게 바꾼다음 sortingCategory 고정값을 salesCount나 reviewCount, 리뷰 점수 중에 선택해서 넣으면 될 듯
    func marketNotesWillFetchDB(sortingCategory: String = "noteName") async {
        do {
            await MainActor.run(body: {
                marketWordNotes.removeAll()
            })
            
            // MARK: - Pagination(InfiniteScroll) 구현 코드
            // 현재 데이터가 많지않아서 limit가 10인데 나중에 private 변수 하나 만들어서 20으로 고정해주고 20개씩 데이터 받아오면 좋을 듯
            // let documents = try await database.collection("marketWordNotes")
            //     .order(by: sortingCategory).limit(to: 10).getDocuments()
            // MARK: - 여기까지
            
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
                
                await MainActor.run(body: {
                    self.marketWordNotes.append(marketWordNote)
                })
            }
            
            // MARK: - Pagination(InfiniteScroll) 구현 코드
            // self.lastDocumentSnapshot = documents.documents.last
        } catch {
            print("marketNotesWillFetchDB Function Error: \(error)")
        }
    }
    
    // MARK: - Pagination(InfiniteScroll) 구현 코드
//    func marketNotesWillPagingUpdateFetchDB(sortingCategory: String = "noteName") async {
//        do {
//            if let documentSnapshot = lastDocumentSnapshot {
//                await MainActor.run(body: {
//                    snapshotCounter = 0
//                })
//
//                위 메서드와 동일하게 데이터가 많아지면 limit를 변수에서 받아와서 20으로 고정해줘도 괜찮을 듯
//                let documents = try await database.collection("marketWordNotes")
//                    .order(by: sortingCategory).start(afterDocument: documentSnapshot).limit(to: 5).getDocuments()
//
//                if !documents.documents.isEmpty {
//                    for document in documents.documents {
//                        let docData = document.data()
//
//                        let id: String = docData["id"] as? String ?? ""
//                        let noteName: String = docData["noteName"] as? String ?? ""
//                        let noteCategory: String = docData["noteCategory"] as? String ?? ""
//                        let enrollmentUser: String = docData["enrollmentUser"] as? String ?? ""
//                        let notePrice: Int = docData["notePrice"] as? Int ?? 0
//                        let createdAtTimeStamp: Timestamp = docData["updateDate"] as? Timestamp ?? Timestamp()
//                        let updateDate: Date = createdAtTimeStamp.dateValue()
//                        let salesCount: Int = docData["salesCount"] as? Int ?? 0
//                        let starScoreTotal: Double = docData["starScoreTotal"] as? Double ?? 0
//                        let reviewCount: Int = docData["reviewCount"] as? Int ?? 0
//
//                        let marketWordNote = MarketWordNote(id: id,
//                                                            noteName: noteName,
//                                                            noteCategory: noteCategory,
//                                                            enrollmentUser: enrollmentUser,
//                                                            notePrice: notePrice,
//                                                            updateDate: updateDate,
//                                                            salesCount: salesCount,
//                                                            starScoreTotal: starScoreTotal,
//                                                            reviewCount: reviewCount)
//
//                        await MainActor.run(body: {
//                            self.marketWordNotes.append(marketWordNote)
//                            self.snapshotCounter += 1
//                        })
//                    }
//                }
//                print("패치된 마켓 노트 갯수: \(marketWordNotes.count)")
//                self.lastDocumentSnapshot = documents.documents.last
//            }
//        } catch {
//            print("marketNotesWillPagingUpdateFetchDB Function Error: \(error)")
//        }
//    }
    // MARK: - 여기까지
    
    // MARK: - 단어장을 들어가면 해당 단어장의 단어들을 fetch 하는 함수 / 마켓에 위치한 Notes의 단어를 Fetch
    func wordsWillFetchDB(wordNoteID: String) async {
        do {
            await MainActor.run(body: {
                words.removeAll()
            })
            var wordsInMethod: [Word] = []
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
                wordsInMethod.append(word)
            }
            await MainActor.run(body: {
                // 띠리릭 갯수가 올라가지 않게 한번에 할당해줌
                    self.words = wordsInMethod
                
            })
        } catch {
            print("wordsWillFetchDB Function Error: \(error)")
        }
    }
    
    // MARK: - 마켓에 단어장을 등록하면 해당 단어장이 마켓 DB에 올라가게 하는 함수
    func marketNotesDidSaveDB(noteID: String, notePrice: Int) async {
        do {
            // 유저 암기장에 접근해서 암기장 들고오는 과정
            let myDocument = try await database.collection("users").document(Auth.auth().currentUser?.uid ?? "")
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
            
            await self.marketNoteWordsDidSaveDB(noteID: noteID)
            await self.marketNotesWillFetchDB()
            
        } catch {
            print("marketMotesDidSaveDB Function Error: \(error)")
        }
    }
    
    // MARK: - 내 단어장을 마켓에 올리면 안에 단어들이 함께 마켓에 올라가도록 하는 함수
    func marketNoteWordsDidSaveDB(noteID: String) async {
        do {
            let myDocuments = try await database.collection("users").document(Auth.auth().currentUser?.uid ?? "")
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
        } catch {
            print("marketNoteWordsDidSaveDB Function Error: \(error)")
        }
    }
    
    // MARK: - 현재 유저의 coin 상태를 확인하고 살 수 있으면 coin이 깍이면서 다음 함수로 넘어감 / 현재 User의 Coin 갯수를 Check
    func userCoinWillCheckDB(marketWordNote: MarketWordNote, words: [Word], userCoin: Int) {
        if userCoin >= marketWordNote.notePrice {
            // 사는 함수 실행
            let calculatedCoin = (userCoin) - marketWordNote.notePrice
            
            database.collection("users")
                .document(Auth.auth().currentUser?.uid ?? "")
                .updateData([
                    "coin": calculatedCoin
                ])
            
            database.collection("users")
                .document(marketWordNote.enrollmentUser)
                .updateData([
                    "coin": FieldValue.increment(Int64(marketWordNote.notePrice))
                ])
            
            database.collection("marketWordNotes")
                .document(marketWordNote.id)
                .updateData([
                    "salesCount": FieldValue.increment(Int64(1))
                ])
            
            marketNotesWillBringMyNotesDB(marketWordNote: marketWordNote, words: words)
        }
    }
    
    // MARK: - 마켓에서 단어장 가져오는 기능 (단어장 구매) / Market에서 Note를 구매할 경우, 해당 note를 DB에 저장 및 불러오기
    func marketNotesWillBringMyNotesDB(marketWordNote: MarketWordNote, words: [Word]) {
        let id = marketWordNote.id
        
        let wordNote = ["id": id,
                        "noteName": marketWordNote.noteName,
                        "noteCategory": marketWordNote.noteCategory,
                        "enrollmentUser": marketWordNote.enrollmentUser,
                        "repeatCount": 0,
                        "testResultFirst": 0,
                        "testResultLast": 0,
                        "updateDate": Date.now,
                        // MARK: 마켓 거래내역때문에 추가
                        "marketPurchaseDate": Date.now,
                        "notePrice": marketWordNote.notePrice] as [String: Any]
        
        database.collection("users")
            .document(Auth.auth().currentUser?.uid ?? "")
            .collection("myWordNotes")
            .document(id)
            .setData(wordNote) { error in
                if let error = error {
                    print(error)
                    return
                }
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
                .document(Auth.auth().currentUser?.uid ?? "")
                .collection("myWordNotes")
                .document(noteId)
                .collection("words")
                .document(marketWord.id)
                .setData(word) { error in
                    if let error = error {
                        print(error)
                        return
                    }
                }
        }
    }
    
    // MARK: - 등록해제하면 해당 암기장 데이터들은 마켓컬렉션에서 삭제되도록 하는 함수
    func marketNotesWillDeleteDB(marketWordNote: MarketWordNote) async {
        let reviewStore: ReviewStore = ReviewStore()
        
        // 하위 컬렉션으로 review와 word가 존재하는지 확인
        await reviewStore.reviewsWillFetchDB(marketID: marketWordNote.id)
        await wordsWillFetchDB(wordNoteID: marketWordNote.id)
        
        do {
            // 하위 컬렉션으로 review가 존재하면 전부 삭제
            for review in reviewStore.reviews {
                try await database
                    .collection("marketWordNotes").document(marketWordNote.id)
                    .collection("reviews").document(review.id)
                    .delete()
            }
            
            // 하위 컬렉션으로 word가 존재하면 전부 삭제
            for word in self.words {
                try await database
                    .collection("marketWordNotes").document(marketWordNote.id)
                    .collection("words").document(word.id)
                    .delete()
            }
            
        } catch {
            print("marketNotesWillDeleteDB error")
        }
        
        do {
            // 하위 컬렉션 전부 삭제 후 해당 암기장 데이터 삭제
            try? await database
                .collection("marketWordNotes").document(marketWordNote.id)
                .delete()
            
            await marketNotesWillFetchDB()
        }
    }
    
    // MARK: - Market에서 Note를 구매할 경우, 해당 Notes를 My Notes DB에 저장
    func filterMyNoteWillFetchDB() async {
        do {
            await MainActor.run(body: {
                filterMyWordNotes.removeAll()
            })
            
            let currentUserUID = Auth.auth().currentUser?.uid ?? ""
            let documents = try await database.collection("users").document(currentUserUID)
                .collection("myWordNotes").whereField("enrollmentUser", isEqualTo: currentUserUID).getDocuments()
            
            for document in documents.documents {
                let docData = document.data()
                
                let id: String = docData["id"] as? String ?? ""
                let noteName: String = docData["noteName"] as? String ?? ""
                let noteCategory: String = docData["noteCategory"] as? String ?? ""
                let enrollmentUser: String = docData["enrollmentUser"] as? String ?? ""
                let repeatCount: Int = docData["noteName"] as? Int ?? 0
                let firstTestResult: Double = docData["firstTestResult"] as? Double ?? 0
                let lastTestResult: Double = docData["lastTestResult"] as? Double ?? 0
                let updateDate: Date = docData["updateDate"] as? Date ?? Date()
                
                let myWordNote = MyWordNote(id: id,
                                            noteName: noteName,
                                            noteCategory: noteCategory,
                                            enrollmentUser: enrollmentUser,
                                            repeatCount: repeatCount,
                                            firstTestResult: firstTestResult,
                                            lastTestResult: lastTestResult,
                                            updateDate: updateDate)
                
                await MainActor.run(body: {
                    self.filterMyWordNotes.append(myWordNote)
                })
            }
            
            
        } catch {
            print("filterMyNoteWillFetchDB Function Error: \(error)")
        }
    }

    // MARK: - Market에서 Note를 구매할 경우, My Notes Array DB에서 불러옴
    func myNotesArrayWillFetchDB() async {
        do {
            await MainActor.run(body: {
                myWordNoteIdArray.removeAll()
            })
            
            let currentUserUID = Auth.auth().currentUser?.uid ?? ""
            let documents = try await database.collection("users").document(currentUserUID)
                .collection("myWordNotes").getDocuments()
            
            for document in documents.documents {
                let id: String = document.data()["id"] as? String ?? ""
                
                await MainActor.run(body: {
                    myWordNoteIdArray.append(id)
                })
            }
        } catch {
            print("myNotesArrayWillFetchDB Function Error: \(error)")
        }
    }
    
    // MARK: - 코인이 업데이트되면 읽어서 반영해주는 메서드
    // 근데 이거 없이도 기존 메서드로 잘됨...ㅎ
    /*
    func myCoinWillFetchDBWithListener() {
        database.collection("users").document(Auth.auth().currentUser?.uid ?? "")
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                guard let data = document.data() else {
                    print("Document data was empty.")
                    return
                }
                let currentCoin: Int = data["coin"] as? Int ?? 0
                
                self.currentCoin = currentCoin
            }
    }
     */
}
