//
//  FaceProgressView.swift
//  Memorizing
//
//  Created by 윤현기 on 2023/01/06.
//

import SwiftUI

// MARK: 단어장 진행도 view
struct FaceProgressView: View {
    
    //    @Binding var faceArray: [String]
    var myWordNote: WordNote
    
    // 한 번도 안 하면 -1, 한 번씩 할 때마다 1씩 증가
    //    @State var repeatCount: Int = 0
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 260, height: 8)
                .foregroundColor(.gray5)
            
            HStack {
                Rectangle()
                    .frame(width: myWordNote.progressbarWitdh, height: 8)
                    .foregroundColor(myWordNote.noteColor)
                    .padding(.leading, 25)
                Spacer()
            }
            
            HStack(spacing: 55) {
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(myWordNote.repeatCount <= 0 ? .gray5 : myWordNote.noteColor)
                    .overlay {
                        if myWordNote.repeatCount <= 0 {
                            Text("1")
                                .font(.headline)
                                .foregroundColor(.white)
                        } else {
                            Image("FaceNomal")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                    }
                
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(myWordNote.repeatCount <= 1 ? .gray5 : myWordNote.noteColor)
                    .overlay {
                        if myWordNote.repeatCount <= 1 {
                            Text("2")
                                .font(.headline)
                                .foregroundColor(.white)
                        } else {
                            Image("CheckMark")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                    }
                
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(myWordNote.repeatCount <= 2 ? .gray5 : myWordNote.noteColor)
                    .overlay {
                        if myWordNote.repeatCount <= 2 {
                            Text("3")
                                .font(.headline)
                                .foregroundColor(.white)
                        } else {
                            Image("CheckMark")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                    }
                
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(myWordNote.repeatCount <= 3 ? .gray5 : myWordNote.noteColor)
                    .overlay {
                        if myWordNote.repeatCount <= 3 {
                            Text("4")
                                .font(.headline)
                                .foregroundColor(.white)
                        } else {
                            Image("FaceGood")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                    }
            }
            
            // 테스트용 버튼
            //            HStack(spacing: 55) {
            //                Button("-1") {
            //                    self.repeatCount -= 1
            //                }
            //
            //                Text("\(self.repeatCount)")
            //                    .font(.headline)
            //
            //                Button("+1") {
            //                    self.repeatCount += 1
            //                }
            //            }
            //            .padding(.top, 450)
            
        }
    }
}

struct FaceProgressView_Previews: PreviewProvider {
    static var previews: some View {
        FaceProgressView(myWordNote: WordNote(id: "9MvRSpz3zdisXon4ZTtI",
                                              noteName: "테스트노트",
                                              noteCategory: "영어",
                                              enrollmentUser: "hKWRjBcFi0NTuR5IjGHSsGMZUaV2",
                                              repeatCount: 1,
                                              notePrice: 0)
                         //                         repeatCount: 0
        )
    }
}
