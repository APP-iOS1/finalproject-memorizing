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
    @EnvironmentObject var coreDataStore: CoreDataStore
    @State private var nickName: String = ""
    @State private var isShownDeleteAccountAlert: Bool = false
    @State private var isShownSignOutAlert: Bool = false
    @State private var isShownToastMessage: Bool = false
    
    let maximumCount: Int = 5
    
    private var isOverCount: Bool {
        nickName.count > maximumCount
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // MARK: 닉네임 변경 파트
            VStack(alignment: .leading) {
                Text("이름 변경")
                    .fontWeight(.semibold)
                
                HStack{
                    VStack{
                        TextField("이름을 입력해주세요.(최대 5자까지 가능)", text: $nickName)
                            .font(.subheadline)
                            .shakeEffect(trigger: isOverCount)
                            .onChange(of: nickName) { newValue in
                                if newValue.count > maximumCount {
                                    nickName = String(newValue.prefix(maximumCount))
                                }
                            }
                        
                        Divider()
                            .overlay(Color.black)
                    }
                    Button {
                        Task {
                            // 이름변경에 성공시 ToastMessage 출력
                            isShownToastMessage
                                = try await authStore.userInfoDidChangeDB(nickName: nickName)
                            dismiss()
                        }
                    } label: {
                        Text("변경하기")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(nickName.isEmpty ? Color.gray4 : Color.black)
                            .cornerRadius(10)
                    }
                    .disabled(nickName.isEmpty)
                }
                .padding(.leading, 3)
                .padding(.vertical, 5)
            }
            .padding(.top, 40)
            .padding(.horizontal, 20)
            
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
                            coreDataStore.deleteAll()
                        }},
                     withCancelButton: true,
                     cancelButtonText: "취소")
        .customToastMessage(isPresented: $isShownToastMessage,
                            message: "이름이 변경이 완료되었습니다!",
                            delay: 0)
        
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
