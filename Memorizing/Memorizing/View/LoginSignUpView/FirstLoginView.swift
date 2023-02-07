//
//  FirstLoginView.swift
//  Memorizing
//
//  Created by 진태영 on 2023/02/01.
//

import SwiftUI
import Combine

struct FirstLoginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authStore: AuthStore
    @State private var newName: String = ""
    @Binding var isFirstLogin: Bool
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            
            HStack {
                VStack(alignment: .leading) {
                    Group {
                        Text("메모라이징에")
                        Text("오신 것을")
                        Text("환영합니다.")
                    } // Group
                    .font(.system(size: 36, weight: .bold))
                    .fontWeight(.bold)
                    Text("앱 내에서 사용할 이름을 입력해주세요!")
                        .font(.system(size: 16))
                        .padding(.top, -15)
                } // VStack
                Spacer()
                
            }
            Spacer()
            
            Group {
                TextField(text: $newName) {
                    Text("이름은 5자까지 입력 가능합니다.")
                        .foregroundColor(Color("Gray2"))
                        .font(.subheadline)
                }
                .autocapitalization(.none)
                .modifier(ClearButton(text: $newName))
                .onReceive(Just(newName)) { _ in limitText(5) }
                
                Divider()
                Text("*이름은 마이페이지 > 회원정보 수정에서 변경 가능합니다.")
                    .font(.footnote)
                    .foregroundColor(.mainBlue)
            } // Group
            
            Spacer()
            
            Button {
                Task {
                    authStore.user?.nickName = newName
                    authStore.userInfoDidSaveDB(platform: authStore.user!.signInPlatform)
                    authStore.state = .signedIn
                    isFirstLogin.toggle()
                }
            } label: {
                Text("메모라이징 시작하기")
                    .modifier(newName.isEmpty
                              ? CustomButtonStyle(backgroundColor: "Gray4")
                              : CustomButtonStyle(backgroundColor: "MainBlue")
                    )
            } // Button
            Spacer()
            
        } // vstack
        .padding(.horizontal, 45)
    } // body
    
    // MARK: - 닉네임 글자수 제한 함수
    func limitText(_ upper: Int) {
        // upper: 제한 글자 수
        if newName.count > upper {
            newName = String(newName.prefix(upper))
        }
    }
}

struct FirstLoginView_Previews: PreviewProvider {
    static var previews: some View {
        FirstLoginView(isFirstLogin: .constant(true))
            .environmentObject(AuthStore())
    }
}
