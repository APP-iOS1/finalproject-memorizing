//
//  StudyAgainView.swift
//  Memorizing
//
//  Created by 염성필 on 2023/01/06.
//

import SwiftUI

struct StudyAgainView: View {
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var myNoteStore: MyNoteStore
    @EnvironmentObject var coreDataStore: CoreDataStore
    var myWordNote: NoteEntity
    @State private var noteLists: [Word] = []
    // 한 번도 안 하면 -1, 한 번씩 할 때마다 1씩 증가
    @State var progressStep: Int = 0
    
    var body: some View {
        VStack {
            // if list.isEmpty가 빠졌으니 앱 빌드해서 꺼지는지 확인해보기
            VStack(spacing: 25) {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray4, lineWidth: 1)
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.15)
                    .overlay {
                        HStack {
                            Rectangle()
                                .cornerRadius(10, corners: [.topLeft, .bottomLeft])
                                .frame(width: 20)
                                .foregroundColor(coreDataStore.returnColor(category: myWordNote.noteCategory ?? ""))
                            
                            VStack(spacing: 5) {
                                HStack(alignment: .top) {
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(coreDataStore.returnColor(category: myWordNote.noteCategory ?? ""),
                                                lineWidth: 1)
                                        .frame(width: 45, height: 23)
                                        .overlay {
                                            Text(myWordNote.noteCategory ?? "No Categoryname")
                                                .font(.caption2)
                                        }
                                    Spacer()
                                }
                                .padding(.horizontal, 8)
                                
                                HStack {
                                    HStack {
                                        Text(myWordNote.noteName ?? "No Notename")
                                            .foregroundColor(.mainBlack)
                                            .font(.body)
                                            .fontWeight(.semibold)
                                            .padding(.top, 7)
                                            .padding(.leading, 6)
                                            .padding(.bottom, 3)
                                            .lineLimit(1)
                                        
                                        Spacer()
                                    }
                                    .frame(width: UIScreen.main.bounds.width * 0.64)
                                    .padding(.leading, 6)
                                    .padding(.bottom, 10)
                                    
                                    Spacer()
                                }
                                // MARK: 얼굴 진행도
                                FaceProgressView(myWordNote: myWordNote)
                            }
                            .padding(.trailing, 15)
                        }
                    }
                    .overlay {
                        HStack {
                            Spacer()
                            
                            VStack {
                                // 학습시작
                                if myWordNote.repeatCount == 0 {
                                    NavigationLink {
                                        // 첫번째 단어 뷰
                                        FirstTryCardView(myWordNote: myWordNote)
                                    } label: {
                                        RoundedRectangle(cornerRadius: 3)
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(coreDataStore.returnColor(category:
                                                                                        myWordNote.noteCategory ?? ""))
                                            .overlay {
                                                VStack(spacing: 6) {
                                                    Image(systemName: "play.circle")
                                                        .font(.headline)
                                                    Text("학습시작")
                                                        .font(.caption2)
                                                }
                                                .foregroundColor(.white)
                                            }
                                    }
                                } else if myWordNote.repeatCount == 1 {
                                    // 복습시작
                                    NavigationLink {
                                        OtherTryCardView(myWordNote: myWordNote)
                                    } label: {
                                        RoundedRectangle(cornerRadius: 3)
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(coreDataStore.returnColor(category:
                                                                                        myWordNote.noteCategory ?? ""))
                                            .overlay {
                                                VStack(spacing: 6) {
                                                    Image(systemName: "play.circle")
                                                        .font(.title3)
                                                    Text("복습시작")
                                                        .font(.caption2)
                                                }
                                                .foregroundColor(.white)
                                            }
                                    }
                                } else if myWordNote.repeatCount == 2 {
                                    NavigationLink {
                                        OtherTryCardView(myWordNote: myWordNote)
                                    } label: {
                                        RoundedRectangle(cornerRadius: 3)
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(coreDataStore.returnColor(category:
                                                                                        myWordNote.noteCategory ?? ""))
                                            .overlay {
                                                VStack(spacing: 6) {
                                                    Image(systemName: "play.circle")
                                                        .font(.title3)
                                                    Text("복습시작")
                                                        .font(.caption2)
                                                }
                                                .foregroundColor(.white)
                                            }
                                    }
                                } else if myWordNote.repeatCount == 3 {
                                    NavigationLink {
                                        // 첫번째 단어 뷰
                                        LastTryCardView(myWordNote: myWordNote)
                                    } label: {
                                        RoundedRectangle(cornerRadius: 3)
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(coreDataStore.returnColor(category:
                                                                                        myWordNote.noteCategory ?? ""))
                                            .overlay {
                                                VStack(spacing: 6) {
                                                    Image(systemName: "play.circle")
                                                        .font(.headline)
                                                    Text("복습시작")
                                                        .font(.caption2)
                                                    
                                                }
                                                .foregroundColor(.white)
                                            }
                                    }
                                } else {
                                    // 도장 이미지
                                    Image("goodicon")
                                        .resizable()
                                        .frame(width: 70, height: 70)
                                        .rotationEffect(.degrees(10))
                                        .padding(.top, 2)
                                        .padding(.bottom, 35)
                                        .padding(.leading, 55)
                                }
                                
                                Spacer()
                            }
                            .padding(.top, myWordNote.repeatCount == 4 ? 6 : 11)
                        }
                        .padding(.trailing, myWordNote.repeatCount == 4 ? 8 : 15 )
                        .bold()
                    }
                    .padding(.vertical, 5)
            }
        }
    }
}

//
// struct StudyAgainView_Previews: PreviewProvider {
//    static var previews: some View {
//        StudyAgainView()
//    }
// }
