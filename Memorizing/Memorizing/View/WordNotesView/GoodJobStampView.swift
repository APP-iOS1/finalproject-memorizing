//
//  GoodJobStampView.swift
//  Memorizing
//
//  Created by 염성필 on 2023/01/06.
//

import SwiftUI

// MARK: - 마지막 복습 페이지
struct GoodJobStampView: View {
    @EnvironmentObject var myNoteStore: MyNoteStore
    @EnvironmentObject var coreDataStore: CoreDataStore
    @EnvironmentObject var authStore: AuthStore
    
    var lastTestResult: Double
    var wordNote: NoteEntity
    
    @Binding var isDismiss: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("학습 완료")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("학습을 마무리 했어요! 장기기억 속으로 숑숑!")
                        .font(.footnote)
                }
                .frame(width: 320, alignment: .leading)
                .padding(.bottom, 10)
                .padding(.leading, 5)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("Gray4"), lineWidth: 1)
                        .foregroundColor(.white)
                        .overlay {
                            Image("goodicon")
                                .resizable()
                                .frame(width: 200, height: 200)
                        }
                }
                .frame(width: 320, height: 320)
                .padding(.bottom)
                VStack {
                    Button {
                        // FIXME: - 현기 수정
                        Task.init {
                            async let repeatCountWillBePlusOne: ()
                                = myNoteStore.repeatCountWillBePlusOne(wordNote: wordNote,
                                                                       nextStudyDate: nil,
                                                                       firstTestResult: wordNote.firstTestResult,
                                                                       lastTestResult: lastTestResult)
                            async let plusUserPoint: () = authStore.plusUserPoint(point: 5)
                            
                            let _ = await (repeatCountWillBePlusOne, plusUserPoint)
                            
                            coreDataStore.plusRepeatCount(note: wordNote,
                                                          firstTestResult: wordNote.firstTestResult,
                                                          lastTestResult: lastTestResult)
                            
                            isDismiss = true
                        }
                        // 복습하기 리스트 뷰로 이동
                    } label: {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("MainBlue"))
                            .frame(width: 320, height: 50)
                            .overlay {
                                Text("학습 마무리 하기")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                    }
                    
                    Button {
                        // 복습하기 리스트 뷰로 이동 --> 해당 리스트 리셋시키기
                        myNoteStore.repeatCountWillBeResetted(wordNote: wordNote)
                        coreDataStore.resetRepeatCount(note: wordNote)
                        isDismiss = true
                        
                    } label: {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("MainDarkBlue"))
                            .frame(width: 320, height: 50)
                            .overlay {
                                Text("처음부터 다시 학습 하기")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                    }
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("구매한 암기장은 어떠셨나요?")
                        Text("후기를 작성해보시면 10P을 드립니다!")
                    }.font(.caption) .foregroundColor(.gray2)
                    Spacer()
                    
                    NavigationLink {
                        CreateReviewView(wordNote: wordNote)
                    } label: {
                        HStack {
                            Text("후기 작성 하기")
                            Image(systemName: "chevron.right")
                        }
                        .font(.subheadline) .fontWeight(.semibold)
                    }
                }
                .frame(width: 320, alignment: .leading)
                .padding(.top, 20)
                
            }
        }
    }
}

// struct GoodJobStampView_Previews: PreviewProvider {
//    static var previews: some View {
//        GoodJobStampView()
//    }
// }
