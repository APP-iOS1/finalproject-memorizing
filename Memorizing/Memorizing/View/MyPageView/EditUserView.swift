//
//  EditUserView.swift
//  Memorizing
//
//  Created by 김혜지 on 2023/01/05.
//

import SwiftUI
import Combine

struct EditUserView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authStore: AuthStore
    //    @Environment(\.dismiss) private var dismiss
    //    @Binding var isShownNickNameToggle: Bool
    @State private var nickName: String = ""
    @State private var isShownDeleteAccountAlert: Bool = false
    @State private var isShownSignOutAlert: Bool = false
    
    var body: some View {
        /*
         VStack {
         ZStack(alignment: .topLeading) {
         VStack {
         // MARK: - 상단 로고 및 뷰 이름
         
         HStack {
         
         Button {
         dismiss()
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
         try await authStore.userInfoDidChangeDB(nickName: nickName)
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
         Text("현재 닉네임: \(authStore.user?.nickName ?? "홍길동")")
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
         */
        
        VStack(spacing: 30) {
            // MARK: 닉네임 변경 파트
            VStack(alignment: .leading) {
                Text("이름 변경")
                    .fontWeight(.semibold)
                
                HStack{
                    VStack{
                        TextField(text: $nickName) {
                            Text("이름을 입력해주세요.(최대 5자까지 가능)")
                                .font(.subheadline)
                        }
                        Divider()
                            .overlay(Color.black)
                    }
                    Button {
                        Task {
                            try await authStore.userInfoDidChangeDB(nickName: nickName)
                        }
                    } label: {
                        Text("변경하기")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black)
                            .cornerRadius(10)
                    }
                }
                .padding(.leading, 3)
                .padding(.vertical, 5)
            }
            .padding(.top, 40)
            .padding(.horizontal, 20)
            
            /*
            // MARK: 비밀번호 변경 파트, securefield로 할지 그냥 textfield로 할지 고민 중
            VStack(alignment: .leading) {
                Text("비밀번호 변경")
                
                HStack {
                    TextField(text: $nickName) {
                        Text("변경할 비밀번호")
                    }
                    .padding(.vertical, 13)
                    .padding(.horizontal, 25)
                    .background(Color("Gray5"))
                    .cornerRadius(30)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .foregroundColor(Color("Black"))
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Text("변경하기")
                            .foregroundColor(.white)
                            .bold()
                            .padding(.vertical, 13)
                            .padding(.horizontal, 20)
                            .background {
                                Color.mainDarkBlue
                            }
                            .cornerRadius(40)
                    }
                }
            }
             */
            
            Divider()
                .padding(.horizontal, 10)
            
            HStack {
                Button {
                    isShownDeleteAccountAlert.toggle()
                } label: {
                    Text("회원 탈퇴")
                        .foregroundColor(.gray2)
                        .font(.footnote)
                }
                Spacer()
            }
            .padding(.horizontal, 30)
            .padding(.top, -10)
            
            Spacer()
            
        }
        .navigationBarBackButtonHidden(true)
        // MARK: navigationLink destination 커스텀 백 버튼
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                backButton
            }
        }
        .navigationTitle("내 정보 수정")
        .navigationBarTitleDisplayMode(.inline)
        .customAlert(isPresented: $isShownDeleteAccountAlert,
                     title: "회원 탈퇴하기",
                     message: "정말 가실거에요?\n삭제된 회원정보는 복구할 수 없어요!",
                     primaryButtonTitle: "탈퇴하기",
                     primaryAction: {
            Task {
                await authStore.deleteAccount()
            }
        },
                     withCancelButton: true,
                     cancelButtonText: "취소")
        
    }// ZStack
    
    // MARK: - 닉네임 글자수 제한 함수
    func limitText(_ upper: Int) {
        // upper: 제한 글자 수
        if nickName.count > upper {
            nickName = String(nickName.prefix(upper))
        }
    }
    
    // MARK: NavigationLink 커스텀 뒤로가기 버튼
    var backButton : some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
        }
    }
    
}

struct EditUserView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EditUserView()
                .environmentObject(AuthStore())
        }
    }
}
