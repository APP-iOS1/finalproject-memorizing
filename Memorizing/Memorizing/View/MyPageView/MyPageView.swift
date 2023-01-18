//
//  MyPageView.swift
//  Memorizing
//
//  Created by 진준호 on 2023/01/05.
//

import SwiftUI

// MARK: 마이페이지 탭에서 가장 메인으로 보여주는 View
struct MyPageView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var signOutAlertToggle: Bool = false
    @State private var isShownNickNameToggle: Bool = false
    @EnvironmentObject var notiManager: NotificationManager
    
    var body: some View {
        
        NavigationStack {

            VStack {
    
    // MARK: - 유저 정보
                VStack(alignment: .leading) {
                    
                        VStack(alignment: .leading, spacing: 2) {
                            Text("안녕하세요")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Text("\(userStore.user?.nickName ?? "")님!")
                                .font(.title)
                                .fontWeight(.semibold)
                            Text("\(userStore.user?.email ?? "")")
                                .font(.footnote)
                                .fontWeight(.light)
                                .foregroundColor(.gray2)
                                
                        } // 그리팅메세지
                        .padding(.leading, 10)
                        .padding(.top, -30)
                      
                    HStack {
                        
                        Text("내 암기장 개수 \(userStore.myWordNotes.count)")
                        Text("|")
                        Text("받은 도장 개수 \(calculateStamp(myWordNotes: userStore.myWordNotes))")
                        
                    } // 내 암기장개수 . 받은 도장 개수
                    .font(.footnote)
                    .padding(.vertical, 2)
                    .padding(.leading, 10)
                    
                    HStack {
                        
                        Button {
                            
                            // 포인트 충전하기
                            
                        } label: {
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 100)
                                    .foregroundColor(.mainBlue)
                                    .frame(width: 158, height: 45)
                                Text("포인트 충전하기")
                                    .foregroundColor(.white)
                                    .padding(15)
                                    .padding(.horizontal, 20)
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                
                            }

                        } // 포인트 충전하기 버튼
                        
                        Spacer()
                        
                        Button {
                            
                            // 포인트 선물하기
                            
                        } label: {
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 100)
                                    .stroke(Color("MainBlue"), lineWidth: 1)
                                    .frame(width: 158, height: 45)
                                Text("포인트 선물하기")
                                    .foregroundColor(.gray2)
                                    .padding(15)
                                    .padding(.horizontal, 10)
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                
                            }

                        } // 포인트 선물하기 버튼
   
                    } // 충전하기 버튼
                    .padding(.vertical, 15)
                    
                } // 유저정보
                
    // MARK: - 유저 버튼
                VStack {
                    
                    Divider()
                    
                    Button {
                        isShownNickNameToggle.toggle()
                    } label: {
                        HStack {
                            Text("닉네임 변경하기")
                                .font(.body)
                                .fontWeight(.medium)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.title3)
                                .fontWeight(.light)
                        } // 문의하기
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .foregroundColor(.mainBlack)
                    }
                    .sheet(isPresented: $isShownNickNameToggle) {
                        EditUserView(isShownNickNameToggle: $isShownNickNameToggle)
                            .presentationDetents([.medium, .large])
                    }

                    Divider()
                    
                    Button {
                        // 문의하기
                    } label: {
                        HStack {
                            Text("문의하기")
                                .font(.body)
                                .fontWeight(.medium)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.title3)
                                .fontWeight(.light)
                        } // 문의하기
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .foregroundColor(.mainBlack)
                    }

                    Divider()
                    
                    Button {
                        // 문의하기
                    } label: {
                        HStack {
                            Text("개인정보처리방침")
                                .font(.body)
                                .fontWeight(.medium)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.title3)
                                .fontWeight(.light)
                        } // 문의하기
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .foregroundColor(.mainBlack)
                    }

                    Divider()
                    
                    Button {
                        signOutAlertToggle.toggle()
                        notiManager.removeAllRequest()
                    } label: {
                        HStack {
                            Text("로그아웃하기")
                                .font(.body)
                                .fontWeight(.medium)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.title3)
                                .fontWeight(.light)
                        } // 문의하기
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .foregroundColor(.mainBlack)
                        
                    }
                    .alert(
                        "로그아웃",
                        isPresented: $signOutAlertToggle
                    ) {
                        HStack {
                            Button {
                                userStore.signOutDidAuth()
                            }label: {
                                Text("로그아웃")
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
                        Text("정말 로그아웃 하시겠습니까?")
                    }
                    
                    Divider()
                    
                    Spacer()
                    
                } // 문의하기, 개인정보 처리 방침
                .frame(maxHeight: .infinity)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Image("Logo")
                            .resizable()
                            .frame(width: 35, height: 22)
                            .padding(.leading, 10)
                    }
                    ToolbarItem(placement: .principal) {
                        Text("마이페이지")
                            .font(.title3.bold())
                            .accessibilityAddTraits(.isHeader)
                    }
                }
            }
            .padding(.horizontal, 30)
        
        }
        
    }
    
    // MARK: - 도장 숫자 계산 함수
    func calculateStamp(myWordNotes: [WordNote]) -> Int {
        var count: Int = 0
        
        for wordNote in myWordNotes where wordNote.repeatCount == 4 {
                count += 1
        }
        return count
    }
}

struct MyPageView_Previews: PreviewProvider {
    static var previews: some View {
        MyPageView()
            .environmentObject(UserStore())
    }
}
