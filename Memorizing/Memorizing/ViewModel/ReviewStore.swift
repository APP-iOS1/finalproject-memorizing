//
//  ReviewStore.swift
//  Memorizing
//
//  Created by 염성필 on 2023/01/18.
//

import Foundation
import Firebase
import FirebaseFirestore

class ReviewStore: ObservableObject {
    
    @Published var reviews: [Review] = []
    @Published var currentUser: User?
    @Published var reviewText: String = ""
    @Published var reviewWriter: String = ""
    @Published var reviewStarScore: Double = 0.0
    
    // Todo - user를 CurrentUser 적용하기
    
    let database = Firestore.firestore()
    
    // MARK: - reviews를 페치하는 함수 / 내가 작성한 review를 Fetch함

    ///  내가 작성한 review를 fetch함
    /// - Returns: reviews배열에 review를 담고 쉽게 말해 추가 되는게 있으면 새로고침을 한다.
    func reviewsWillFetchDB(marketID: String) async {
        let marketID = marketID
        do {
            print("start fetchReviews")
            let documents = try await  database
                .collection("marketWordNotes")
                .document(marketID)
                .collection("reviews")
                .order(by: "createDate", descending: true)
                .getDocuments()
            
            for document in documents.documents {
                let docData = document.data()
                let id: String = docData["id"] as? String ?? ""
                let writer: String = docData["writer"] as? String ?? ""
                let reviewText: String = docData["reviewText"] as? String ?? ""
                // 서버에서 createDate를 TimeStamp 타입으로 받아오는 변수
                let createdAtTimeStamp: Timestamp = docData["createDate"] as? Timestamp ?? Timestamp()
                // createdAtTimeStamp의 value를 이용해서 Date타입으로 바꿔주고 앱 내의 구조체 배열에 넣어주기 위한 변수
                let createDate: Date = createdAtTimeStamp.dateValue()
                let starScore: Double = docData["starScore"] as? Double ?? 0.0
                
                let myReview = Review(id: id,
                                      writer: writer,
                                      reviewText: reviewText,
                                      createDate: createDate,
                                      starScore: starScore)
                self.reviews.append(myReview)
                print("finished fetchMyWordNotes")
            }
        } catch {
            print("reviewsWillFetchDB: \(error)")
        }
    }
    
    // MARK: - reviews를 추가하는 함수 / 내가 작성한 review를 DB에 저장함
    
    // Todo - WordNote --> MarketWordNotes로 변경
    /// marketWordNotes DB의 Id의 컬렉션에 review를 컬렉션을 추가한다.
    /// - Parameter marketWord: marketWordnote의 id의 컬레션에 reviews를 추가한다.
    ///  reviews안에 현재 user의 id로 구조체로된 review가 생성된다.
    func reviewDidSaveDB(wordNoteID: String, reviewText: String, reviewStarScore: Int, currentUser: User) {
     
        database
            .collection("marketWordNotes")
            .document(wordNoteID)
            .collection("reviews")
            .document(currentUser.id)
            .setData([
                "id": currentUser.id,
                "writer": currentUser.nickName,
                "reviewText": reviewText,
                "createDate": Timestamp(),
                "starScore": reviewStarScore
            ])
//        starScoreDidPlusMarketWordNote(marketWordNote: marketWord)
//        reviewCountDidPlusOne(marketWordNote: marketWord)
    }
    // MARK: - MarketWordnote에 starScore를 추가함
    
    // Todo - WordNote --> MarketWordNotes로 변경
    /// marketWordNote.id에 StarScore를 추가한다.
    /// - Parameter marketWordNote: review에서 평가한 starScore를 marketWordNote.id의 starScore에 추가한다.
    func starScoreDidPlusMarketWordNote(marketWordNote: MarketWordNote) {
        print("스코어를 추가합니다.")
        // marketWord.id로 간다음 starScore에 reviewDidSaveDB에서 추가한 starScore를 더해준다.
        database
            .collection("marketWordNotes")
            .document(marketWordNote.id)
            .updateData([
                "starScore": FieldValue.increment(reviewStarScore)
            ])
        print("marketWord.id에 스코어를 추가했습니다.")
        
    }
    
    // MARK: - 평점을 남기면 리뷰 카운트 + 1 올림
    
    /// marketWordNote.id에 있는 reviewCount를 +1씩 한다.
    /// - Parameter marketWordNote: reviewDidSaveDB를 통해 생성이 되면 review가 작성되고,
    /// marketWordNote.id안에 있는 reviewCount를 +1를 한다.
    func reviewCountDidPlusOne(marketWordNote: MarketWordNote) {
        print("리뷰 카운트를 1증가 시킵니다.")
        // marketWord.id로 접근해서 reviewCount에 +1를 해준다.
        database
            .collection("marketWordNotes")
            .document(marketWordNote.id)
            .updateData([
                "reviewCount": FieldValue.increment(Int64(1))
            ])
        print("리뷰 카운트에 +1 되었습니다.")
    }

    // MARK: - 해당 review 삭제
    
    /// 해당 리뷰를 삭제한다.
    /// - Parameters:
    ///   - marketWordNote: marketWordNote의 정보를 가져온다. ??? 왜 필요한지 모르겠음
    ///   - review: 지우고자 하는 리뷰를 가져온다.
    func reviewDidDeleteDB(marketWordNote: MarketWordNote, review: Review) {
        database.collection("marketWordNotes")
            .document(marketWordNote.id)
            .collection("reviews")
            .document(currentUser?.id ?? "")
            .delete { err in
                if let err = err {
                    print("reviewDidDeleteDB 데이터를 삭제할 때 오류 발생 : \(err.localizedDescription)")
                } else {
                    print("성공적으로 reviewDidDeleteDB를 삭제 했습니다.")
                }
            }
    }
    
    // MARK: - 해당 review 수정
    
    /// review를 수정한다.
    /// - Parameters:
    ///   - marketWordNote: marketWordNote의 정보를 가져온다.? 왜 필요한가
    ///   - review: 수정하고자 하는 리뷰를 가져온다.
    func reviewDidModifyDB(marketWordNote: MarketWordNote, review: Review) {
        // 수정 버튼을 누르고 수정하게 되면 수정한 내용(리뷰 내용, 평점) 다시 업데이트
        database
            .collection("marketWordNotes")
            .document(marketWordNote.id)
            .collection("reviews")
            .document(currentUser?.id ?? "")
            .updateData([
                "reviewText": reviewText,
                "starScore": reviewStarScore
            ]) { err in
                if let err = err {
                    print("reviewDidUpdateDB 해당 리뷰 업데이트 실패: \(err.localizedDescription)")
                } else {
                    print("reviewDidUpdateDB 해당 리뷰 업데이트 성공")
                }
            }
    }
    
    func reviewPreviewsWillFetchDB(marketNoteID: String) async {
        do {
            print("start fetchReviews")
            let documents = try await  database
                .collection("marketWordNotes")
                .document(marketNoteID)
                .collection("reviews")
                .order(by: "createDate", descending: true)
                .limit(to: 2)
                .getDocuments()
            
            for document in documents.documents {
                let docData = document.data()
                let id: String = docData["id"] as? String ?? ""
                let writer: String = docData["writer"] as? String ?? ""
                let reviewText: String = docData["reviewText"] as? String ?? ""
                let createdAtTimeStamp: Timestamp = docData["createDate"] as? Timestamp ?? Timestamp()
                let createDate: Date = createdAtTimeStamp.dateValue()
                let starScore: Double = docData["starScore"] as? Double ?? 0.0
                
                let myReview = Review(id: id,
                                      writer: writer,
                                      reviewText: reviewText,
                                      createDate: createDate,
                                      starScore: starScore)
                self.reviews.append(myReview)
                print("finished fetchMyWordNotes")
            }
        } catch {
            print("reviewsWillFetchDB: \(error)")
        }
    }
}
