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
    @Published var marketWordNotes: [WordNote] = []
    @Published var words: [Word] = []
    
    @Published var sendWordNote = WordNote(id: "",
                                           noteName: "",
                                           noteCategory: "",
                                           enrollmentUser: "",
                                           repeatCount: 0,
                                           notePrice: 0)
    
    // MARK: - 마켓의 전체 단어장들을 fetch 하는 함수 / Market View에서 전체 Notes를 Fetch 함
    func marketNotesWillFetchDB() {
        Firestore.firestore().collection("marketWordNotes")
            .getDocuments { snapshot, _ in
                self.marketWordNotes.removeAll()
                
                if let snapshot {
                    for document in snapshot.documents {
                        let docData = document.data()
                        
                        let id: String = docData["id"] as? String ?? ""
                        let noteName: String = docData["noteName"] as? String ?? ""
                        let noteCategory: String = docData["noteCategory"] as? String ?? ""
                        let enrollmentUser: String = docData["enrollmentUser"] as? String ?? ""
                        let repeatCount: Int = docData["repeatCount"] as? Int ?? 0
                        let notePrice: Int = docData["notePrice"] as? Int ?? 0
                        
                        let marketWordNote = WordNote(id: id,
                                                      noteName: noteName,
                                                      noteCategory: noteCategory,
                                                      enrollmentUser: enrollmentUser,
                                                      repeatCount: repeatCount,
                                                      notePrice: notePrice)
                        
                        self.marketWordNotes.append(marketWordNote)
                    }
                }
            }
    }
    
    // MARK: - 단어장을 들어가면 해당 단어장의 단어들을 fetch 하는 함수 / 마켓에 위치한 Notes의 단어를 Fetch
    func wordsWillFetchDB(wordNoteId: String) {
        let noteId = wordNoteId
        
        Firestore.firestore().collection("marketWordNotes")
            .document(noteId)
            .collection("words")
            .getDocuments { snapshot, _ in
                self.words.removeAll()
                if let snapshot {
                    for document in snapshot.documents {
                        let docData = document.data()
                        let id: String = docData["id"] as? String ?? ""
                        let wordString: String = docData["wordString"] as? String ?? ""
                        let wordMeaning: String = docData["wordMeaning"] as? String ?? ""
                        let wordLevel: Int = docData["wordLevel"] as? Int ?? 0
                        let word: Word = Word(
                            id: id,
                            wordString: wordString,
                            wordMeaning: wordMeaning,
                            wordLevel: wordLevel
                        )
                        self.words.append(word)
                    }
                }
            }
    }
    // MARK: - 마켓에 단어장을 등록하면 단어장과 단어들이 마켓 DB에 올라가게 하는 함수 / myNotes를 Market에 올릴 경우 해당 Notes를 Fetch
    func maketNotesDidSaveDB(noteId: String, userId: String, notePrice: Int) {
        let noteId = noteId

        Firestore.firestore().collection("users")
            .document(userId)
            .collection("myWordNotes")
            .document(noteId)
            .getDocument { document, _ in
                if let document {
                    let docData = document.data()
                    let id: String = docData?["id"] as? String ?? ""
                    let noteName: String = docData?["noteName"] as? String ?? ""
                    let noteCategory: String = docData?["noteCategory"] as? String ?? ""
                    let enrollmentUser: String = docData?["enrollmentUser"] as? String ?? ""

                    Firestore.firestore().collection("marketWordNotes")
                        .document(noteId)
                        .setData([
                            "id": id,
                            "noteName": noteName,
                            "notePrice": notePrice,
                            "noteCategory": noteCategory,
                            "enrollmentUser": enrollmentUser,
                            "repeatCount": 0
                        ])
                    print("Add WordNote complete")
                }
            }
        Firestore.firestore().collection("users")
            .document(userId)
            .collection("myWordNotes")
            .document(noteId)
            .collection("words")
            .getDocuments { snapshot, _ in
                if let snapshot {
                    for document in snapshot.documents {
                        let docData = document.data()
                        let id: String = docData["id"] as? String ?? ""
                        let wordString: String = docData["wordString"] as? String ?? ""
                        let wordMeaning: String = docData["wordMeaning"] as? String ?? ""
                        Firestore.firestore().collection("marketWordNotes")
                            .document(noteId)
                            .collection("words")
                            .document(id)
                            .setData([
                                "id": id,
                                "wordString": wordString,
                                "wordMeaning": wordMeaning,
                                "wordLevel": 0
                            ])
                    }
                }
            }
    }
}
