//
//  EditUserView.swift
//  Memorizing
//
//  Created by 김혜지 on 2023/01/05.
//

import SwiftUI
import Combine

struct EditUserView: View {
    @EnvironmentObject var userStore: UserStore
    @Environment(\.presentationMode) var presentationMode
    @Binding var isShownNickNameToggle: Bool
    @State private var nickName: String = ""
    @State private var isShownAlertToggle: Bool = false
    
    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                VStack {
                    // MARK: - 상단 로고 및 뷰 이름
                    
                    HStack {
                        
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.black)
                        } // 닫기
                        .frame(width: 60)
                        
                        Spacer()
                        
                        Text("회원 정보 변경")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button {
                            isShownAlertToggle.toggle()
                        } label: {
                            Text("변경하기")
                                .foregroundColor(.mainBlue)
                                .font(.body)
                        }
                        .frame(width: 60)
                        .alert(
                            "닉네임 변경",
                            isPresented: $isShownAlertToggle
                        ) {
                            HStack {
                                Button {
                                    Task {
                                        try await userStore.userInfoDidChangeDB(nickName: nickName)
                                            isShownNickNameToggle.toggle()
                                                        }
                                                    }label: {
                                                        Text("변경")
                                                            .foregroundColor(.accentColor)
                                                    }
                                                    Spacer()
                                                    Button {
                                                        
                                                    }label: {
                                                        Text("닫기")
                                                            .foregroundColor(.black)
                                                    }
                                                }
                                            } message: {
                                                Text("정말 변경하시겠습니까?")
                                            }
                    }
                    .padding(.horizontal, 20)
                    
                    // MARK: - 유저 정보
                    VStack(alignment: .leading) {
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("현재 닉네임: \(userStore.user?.nickName ?? "홍길동")")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .padding(.top, 23)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            // MARK: 닉네임
                            TextField(text: $nickName) {
                                Text("변경할 닉네임을 입력해 주세요(최대 6자)")
                                    .foregroundColor(Color("Gray2"))
                                    .font(.subheadline)
                            }
                            .autocapitalization(.none)
                            .textFieldStyle(CustomTextField())
                            .modifier(ClearButton(text: $nickName))
                            .onReceive(Just(nickName)) { _ in limitText(6) }
                            
                        }
                        .padding(.vertical, 20)
                        
                    } // 유저정보
                    
                    Spacer()
 
                } .padding(.top, 20)
            } // VStack
            
        }
    }// ZStack
       
    // MARK: - 닉네임 글자수 제한 함수
    func limitText(_ upper: Int) {
        // upper: 제한 글자 수
        if nickName.count > upper { 
            nickName = String(nickName.prefix(upper))
        }
    }

}

struct EditUserView_Previews: PreviewProvider {
    static var previews: some View {
        EditUserView(isShownNickNameToggle: .constant(false))
            .environmentObject(UserStore())
    }
}
