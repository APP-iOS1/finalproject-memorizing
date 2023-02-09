//
//  AddWordView.swift
//  Memorizing
//
//  Created by Jae hyuk Yim on 2023/01/05.
//

import SwiftUI

struct AddWordView: View {
    // MARK: - 바인딩
    @EnvironmentObject var myNoteStore: MyNoteStore
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var coreDataStore: CoreDataStore
    // 상위뷰랑 꼬일 수 있으므로, 그냥 var 선언하기 (Binding X)
    var wordNote: NoteEntity
    var words: [WordEntity] {
        wordNote.words?.allObjects as? [WordEntity] ?? []
    }
    
    // MARK: - 단어, 문장, 질문과 답 피커 만들기 -> 아래 Enum으로 유형 선언되어 있음
    @State private var segmnetationSelection: AddWordCategory = .word
    
    // MARK: - 취소, 등록 시 창을 나가는 dismiss()
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - 값(변수들)
    @State private var wordString: String = ""
    @State private var wordMeaning: String = ""
    @State private var wordLevel: Int = 0
    @State private var displayLists: Bool = false
    @State private var addWordToast: Bool = false
    @Binding var isOnChangeToastToggle: Bool
    
    @State private var isWordCountCheckToggle = false
    
    // MARK: - Navigation Stack 사용 안함
    var body: some View {
        VStack(alignment: .center) {
            // MARK: - Section3 - 단어 / 문장 / 질문과 답 입력하는 창
            Section {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading) {
                        // MARK: - 유형 제거. 일반 암기장 작성 양식
                        VStack(alignment: .leading, spacing: 20) {
                            HStack{
                                HStack {
                                    Text("하나의 암기장에 암기항목은 ")
                                    + Text("최대 50개 ")
                                        .bold()
                                        .foregroundColor(.mainDarkBlue)
                                    + Text("까지 추가 가능합니다.")
                                }
                                .font(.caption2)
                                .padding(.leading, 10)
                                
                                Spacer()
                                
                                Button {
                                    dismiss()
                                } label: {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.gray1)
                                }
                            }
                            .padding(.bottom, 10)
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("암기 항목 (단어/질문 등)")
                                    Spacer()
                                    Text("\(wordNote.words?.count ?? 0)")
                                        .foregroundColor(wordNote.words?.count != 50
                                                         ? .mainDarkBlue
                                                         : .red)
                                    + Text(" / 50")
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 10)
                                
                                TextField("암기해야 할 내용을 단어, 질문 등의 형식으로 자유롭게 입력해보세요:)!", text: $wordString, axis: .vertical)
                                    .padding(.leading, 10)
                                    .padding(.top, 10)
                                    .padding(10)
                                    .accentColor(.mainBlue)
                                    .lineLimit(8...12)
                                    .background(Color.gray6)
                                    .cornerRadius(20, corners: .allCorners)
                                    .fontWeight(.medium)
                                    .font(.footnote)
                                    .multilineTextAlignment(.leading)
                                    
                            }
                            
                            VStack(alignment: .leading) {
                                Text("의미")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.leading,10)
                                TextField("해당 암기 내용의 의미를 입력해주세요", text: $wordMeaning, axis: .vertical)
                                    .padding(.leading, 10)
                                    .padding(.top, 10)
                                    .padding(10)
                                    .accentColor(.mainBlue)
                                    .lineLimit(8...12)
                                    .background(Color.gray6)
                                    .cornerRadius(20, corners: .allCorners)
                                    .fontWeight(.medium)
                                    .font(.footnote)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                    }
                    // MARK: - 빈 공간을 눌렀을 때, 키보드 자동으로 감추기
                    .onAppear {
                        UIApplication.shared.hideKeyboard()
                    }
                }
                .padding()
            }
            
            // MARK: - 추가 등록 버튼
            Section {
                VStack {
                    Button {
                        if wordNote.words?.count ?? 0 < 50 {
                            let id = UUID().uuidString
                            // MARK: - 작성된 Words를 List에 추가할 수 있도록 함
                            myNoteStore.myWordsWillBeSavedOnDB(wordNote: MyWordNote(id: wordNote.id ?? UUID().uuidString,
                                                                                    noteName: wordNote.noteName
                                                                                    ?? "no Name",
                                                                                    noteCategory: wordNote.noteCategory
                                                                                    ?? "no Category",
                                                                                    enrollmentUser: wordNote.enrollmentUser
                                                                                    ?? "no Enrollment User",
                                                                                    repeatCount: Int(wordNote.repeatCount),
                                                                                    firstTestResult:
                                                                                        wordNote.firstTestResult,
                                                                                    lastTestResult:
                                                                                        wordNote.lastTestResult,
                                                                                    updateDate:
                                                                                        wordNote.updateDate ?? Date()),
                                                               word: Word(
                                                                id: id,
                                                                wordString: wordString,
                                                                wordMeaning: wordMeaning,
                                                                wordLevel: wordLevel)
                            )
                            
                            coreDataStore.addWord(note: wordNote,
                                                  id: id,
                                                  wordLevel: Int64(wordLevel),
                                                  wordMeaning: wordMeaning,
                                                  wordString: wordString)
                            
                            wordString = ""
                            wordMeaning = ""
                            wordLevel = 0
                            addWordToast = true
                        } else {
                            isWordCountCheckToggle.toggle()
                        }
                    } label: {
                        Text("등록하기")
                            .fontWeight(.semibold)
                            .modifier(CustomButtonStyle(backgroundColor: wordString.isEmpty
                                                        || wordMeaning.isEmpty
                                                        || words.count >= 100
                                                        ? "Gray4"
                                                        : "MainBlue"))
                            .overlay {
                                if addWordToast {
                                    HStack {
                                        Image("LogoWhite")
                                            .resizable()
                                            .frame(width: UIScreen.main.bounds.size.width * 0.04,
                                                   height: UIScreen.main.bounds.size.width * 0.03)
                                            .padding(.leading, 7)
                                        
                                        Spacer()
                                        
                                        Text("단어 저장 완료!")
                                            .foregroundColor(.primary)
                                            .colorInvert()
                                            .font(.footnote)
                                            .bold()
                                        
                                        Spacer()
                                        
                                    }
                                    .task {
                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                                            addWordToast = false
                                        }
                                    }
                                    .padding(10)
                                    .modifier(CustomButtonStyle(backgroundColor: "MainDarkBlue"))
                                }
                            }
                    }
                    .disabled(wordString.isEmpty
                              || wordMeaning.isEmpty
                              || words.count >= 100)
                }
            }
        }
        .padding()
        .onChange(of: wordNote.words?.count == 50) { _ in
            dismiss()
            isOnChangeToastToggle = true
        }
        // MARK: - Section1 - 타이틀 및 취소/저장 버튼
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Text("뒤로가기")
                        .font(.subheadline)
                        .fontWeight(.regular)
                        .foregroundColor(.mainBlack)
                }
            }
        }
    }
}

// TODO: enum case를 한글에서 영어로 변경해주세요. 3 ~ 40 자 사이
enum AddWordCategory: String, CaseIterable {
    case word = "단어"
    case sentence = "문장"
    case qustionAndAnswer = "질문과 답"
}
