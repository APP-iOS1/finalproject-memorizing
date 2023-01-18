//
//  TryAgainView.swift
//  Memorizing
//
//  Created by 염성필 on 2023/01/06.
//

import SwiftUI

struct TryAgainView: View {
    @EnvironmentObject var userStore: UserStore
    var wordNote: WordNote
    @Binding var isDismiss: Bool
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("Gray4"), lineWidth: 1)
                    .foregroundColor(.white)
                    .overlay {
                        Image("failicon")
                            .resizable()
                            .frame(width: 200, height: 200)
                    }
            }
            .frame(width: 330, height: 330)
            .padding(.bottom)
            
            Button {
                // 복습하기 리스트 뷰로 이동 --> 해당 리스트 리셋시키기
                userStore.repeatCountDidReset(wordNote: wordNote)
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

// struct TryAgainView_Previews: PreviewProvider {
//    static var previews: some View {
//        TryAgainView()
//    }
// }
