//
//  CreateReviewView.swift
//  Memorizing
//
//  Created by 윤현기 on 2023/01/18.
//

import SwiftUI

// MARK: - 리뷰 작성 페이지
struct CreateReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var reviewStore: ReviewStore
    @EnvironmentObject var coreDataStore: CoreDataStore
    @State private var reviewText: String = ""
    @State private var reviewStarCount: Int = 5
    
    var wordNote: NoteEntity
    var marketPurchaseDate: Date?
    @State private var reviewPlaceholder: String = "리뷰를 작성해주세요. 다른 사용자분들께 도움이 된답니다!"
    
    var body: some View {
        // MARK: - 단어장 정보
        VStack {
            // 암기장 카테고리
            HStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(coreDataStore.returnColor(category: wordNote.noteCategory ?? ""))
                    .frame(width: 40, height: 20)
                    .overlay {
                        Text(wordNote.noteCategory ?? "No Category")
                            .font(.footnote)
                            .foregroundColor(.white)
                    }
                
                Spacer()
            }
            
            // 암기장 제목
            HStack {
                Text(wordNote.noteName ?? "No Name")
                    .foregroundColor(.mainBlack)
                    .font(.title3)
                    .bold()
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                
                Spacer()
            }
            .padding(.vertical, 5)
            
            // 암기장 마켓등록일, 판매 금액
            HStack {
                // FIXME: 마켓 등록일 관련 데이터 추가 후 수정
                Text("\((marketPurchaseDate ?? Date()).formatted(.dateTime.day().month().year()))")
                    .font(.footnote)
                    .foregroundColor(.gray2)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                
                Spacer()
                
            }
            
            // MARK: - 구분선
            Divider()
                .frame(width: 400, height: 5)
                .overlay { Color.gray5 }
                .padding(.bottom)
            
            Text("즐거운 학습이 되셨나요?")
                .font(.headline)
                .padding(.bottom, 10)
            
            HStack(spacing: 3) {
                
                ForEach(1 ... reviewStarCount, id: \.self) { count in
                    Button {
                        reviewStarCount = count
                    } label: {
                        Image(systemName: "star.fill")
                    }
                }
                
                if reviewStarCount < 5 {
                    ForEach(1 ... (5 - reviewStarCount), id: \.self) { count in
                        Button {
                            reviewStarCount += count
                        } label: {
                            Image(systemName: "star")
                        }
                    }
                }
            }
            .font(.title)
            .foregroundColor(Color.iTColor)
            .padding(.bottom, 30)
            
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray6)
                .frame(width: 350, height: 160)
                .overlay {
                    TextField(reviewPlaceholder, text: $reviewText, axis: .vertical)
                        .padding()
                        .lineLimit(3)
                        .font(.caption)
                }
                .padding(.bottom, 30)
            
            //            ZStack {
            //                if reviewText.isEmpty {
            //                    TextEditor(text: $reviewPlaceholder)
            //                        .font(.body)
            //                        .foregroundColor(.red)
            //                        .disabled(true)
            //                        .padding()
            //                        .scrollContentBackground(.hidden) // <- Hide it
            //                        .background(Color.gray6) // To see this
            //                }
            //                TextEditor(text: $reviewText)
            //                    .font(.body)
            //                    .opacity(self.reviewText.isEmpty ? 0.25 : 1)
            //                    .padding()
            //                    .foregroundColor(Color.mainBlack)
            //                    .scrollContentBackground(.hidden) // <- Hide it
            //                    .background(Color.gray6) // To see this
            //            }
            //            .frame(width: 350, height: 160)
            // MARK: - 버튼 아래 추가 -태영
            Button {
                
                // review에 setdata로 등록
                reviewStore.reviewDidSaveDB(
                    wordNoteID: wordNote.id ?? "No Id",
                    reviewText: reviewText,
                    reviewStarScore: reviewStarCount,
                    currentUser: authStore.user ?? User(
                        id: "",
                        email: "",
                        nickName: "",
                        coin: 0,
                        signInPlatform: User.Platform.google.rawValue)
                )
                dismiss()
            } label: {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.mainBlue)
                    .frame(width: 350, height: 50, alignment: .top)
                    .overlay {
                        Text("등록하기")
                            .font(.footnote)
                            .bold()
                            .foregroundColor(.white)
                    }
            }
            
            Spacer()
        }
        .padding(.horizontal, 30)
    }
}

// struct CreateReviewView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateReviewView(wordNote: MarketWordNote(id: "",
//                                                  noteName: "",
//                                                  noteCategory: "",
//                                                  enrollmentUser: "",
//                                                  notePrice: 0,
//                                                  updateDate: Date.now,
//                                                  salesCount: 0,
//                                                  starScoreTotal: 0,
//                                                  reviewCount: 0))
//        .environmentObject(ReviewStore())
//    }
// }
