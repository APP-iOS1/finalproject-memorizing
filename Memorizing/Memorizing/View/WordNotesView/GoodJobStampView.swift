//
//  GoodJobStampView.swift
//  Memorizing
//
//  Created by 염성필 on 2023/01/06.
//

import SwiftUI

// MARK: - 마지막 복습 페이지
struct GoodJobStampView: View {
    @EnvironmentObject var authStore: AuthStore
    var wordNote: WordNote
    @Binding var isDismiss: Bool
    var body: some View {
        VStack {
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
            .frame(width: 330, height: 330)
            .padding(.bottom)
            VStack {
                Button {
                    // FIXME: - 현기 수정
                    Task.init {
                        await authStore.repeatCountDidPlusOne(wordNote: wordNote)
                        isDismiss = true
                    }
                    // 복습하기 리스트 뷰로 이동
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.blue)
                        .frame(width: 330, height: 50)
                        .overlay {
                            Text("학습 마무리 하기")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                }
                
                Button {
                    // 복습하기 리스트 뷰로 이동 --> 해당 리스트 리셋시키기
                    authStore.repeatCountDidReset(wordNote: wordNote)
                    isDismiss = true
                    
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.red)
                        .frame(width: 330, height: 50)
                        .overlay {
                            Text("처음부터 복습 하기")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                }
            }
        }
    }
}

// struct GoodJobStampView_Previews: PreviewProvider {
//    static var previews: some View {
//        GoodJobStampView()
//    }
// }
