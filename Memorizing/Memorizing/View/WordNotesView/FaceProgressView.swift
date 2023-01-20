//
//  FaceProgressView.swift
//  Memorizing
//
//  Created by 윤현기 on 2023/01/06.
//

import SwiftUI

// MARK: 단어장 진행도 view
struct FaceProgressView: View {
    
    var myWordNote: MyWordNote
    
    var body: some View {
        ZStack {
            
            // MARK: ProgressBar baseLine
            Rectangle()
                .frame(width: 260, height: 8)
                .foregroundColor(.gray5)
            
            // MARK: 진행도에 따라 Progressbar 길이 조절
            HStack {
                Rectangle()
                    .frame(width: myWordNote.progressbarWitdh,
                           height: 8)
                    .foregroundColor(myWordNote.noteColor)
                    .padding(.leading, 25)
                    .animation(.linear(duration: 1),
                               value: myWordNote.progressbarWitdh)
                
                Spacer()
            }
            
            HStack(spacing: 55) {
                
                // MARK: 1회차
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(myWordNote.repeatCount <= 0
                                     ? .gray5
                                     : myWordNote.noteColor)
                    .overlay {
                        Text("1")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .overlay {
                        if myWordNote.repeatCount > 0 {
                            ZStack {
                                Circle()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(myWordNote.noteColor)
                                // FIXME: DB수정 후 결과에 따라 표정 변하도록 수정
                                Image("FaceNomal")
                                    .resizable()
                                    .frame(width: 24,
                                           height: 24)
                            }
                        }
                    }
                    .animation(.easeInOut.delay(0.9),
                               value: myWordNote.repeatCount)
                
                // MARK: 2회차
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(myWordNote.repeatCount <= 1
                                     ? .gray5
                                     : myWordNote.noteColor)
                    .overlay {
                        Text("2")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .overlay {
                        if myWordNote.repeatCount > 1 {
                            ZStack {
                                Circle()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(myWordNote.noteColor)
                                Image("CheckMark")
                                    .resizable()
                                    .frame(width: 24,
                                           height: 24)
                            }
                        }
                    }
                    .animation(.linear.delay(0.6),
                               value: myWordNote.repeatCount)
                
                // MARK: 3회차
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(myWordNote.repeatCount <= 2
                                     ? .gray5
                                     : myWordNote.noteColor)
                    .overlay {
                        Text("3")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .overlay {
                        if myWordNote.repeatCount > 2 {
                            ZStack {
                                Circle()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(myWordNote.noteColor)
                                Image("CheckMark")
                                    .resizable()
                                    .frame(width: 24,
                                           height: 24)
                            }
                        }
                    }
                    .animation(.easeInOut.delay(0.6),
                               value: myWordNote.repeatCount)
                
                // MARK: 4회차
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(myWordNote.repeatCount <= 3
                                     ? .gray5
                                     : myWordNote.noteColor)
                    .overlay {
                        Text("4")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .overlay {
                        if myWordNote.repeatCount > 3 {
                            ZStack {
                                Circle()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(myWordNote.noteColor)
                                // FIXME: DB수정 후 결과에 따라 표정 변하도록 수정
                                Image("FaceGood")
                                    .resizable()
                                    .frame(width: 24,
                                           height: 24)
                            }
                        }
                    }
                    .animation(.easeInOut.delay(0.6),
                               value: myWordNote.repeatCount)
            }
        }
    }
}

struct FaceProgressView_Previews: PreviewProvider {
    static var previews: some View {
        FaceProgressView(myWordNote: MyWordNote(id: "",
                                                noteName: "",
                                                noteCategory: "",
                                                enrollmentUser: "",
                                                repeatCount: 0,
                                                firstTestResult: 0,
                                                lastTestResult: 0,
                                                updateDate: Date.now)
        )
    }
}
