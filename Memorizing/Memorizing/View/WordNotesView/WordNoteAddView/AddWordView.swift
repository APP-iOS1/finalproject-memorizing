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
//    var noteLists: [WordEntity]
    
    // MARK: - 단어, 문장, 질문과 답 피커 만들기 -> 아래 Enum으로 유형 선언되어 있음
    @State private var segmnetationSelection: AddWordCategory = .word
    
    // MARK: - 취소, 등록 시 창을 나가는 dismiss()
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - 값(변수들)
    @State private var wordString: String = ""
    @State private var wordMeaning: String = ""
    @State private var wordLevel: Int = 0
    //    @State private var showingAlert = false
    @State private var displayLists: Bool = false
    
    // MARK: - Navigation Stack 사용 안함
    var body: some View {
        VStack(alignment: .center) {
            // MARK: - Section2 - 카테고리 세그먼트 피커
            Section {
                HStack {
                    Text("유형")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Picker("", selection: $segmnetationSelection) {
                        ForEach(AddWordCategory.allCases, id: \.self) { option in
                            Text(option.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .backgroundStyle(Color.white)
                    .padding()
                }
                .padding()
            }
            Divider()
            // MARK: - Section3 - 단어 / 문장 / 질문과 답 입력하는 창
            Section {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading) {
                        // MARK: - 1. 단어 암기장 만들기
                        if segmnetationSelection == .word {
                            VStack(alignment: .leading) {
                                VStack(alignment: .leading) {
                                    Text("단어")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    TextField("단어를 입력해주세요", text: $wordString, axis: .vertical)
                                        .padding(10)
                                        .accentColor(.mainBlue)
                                        .lineLimit(3...5)
                                        .background(Color.gray6)
                                        .cornerRadius(20, corners: .allCorners)
                                        .fontWeight(.semibold)
                                        .font(.subheadline)
                                        .multilineTextAlignment(.leading)
                                }
                                VStack(alignment: .leading) {
                                    Text("뜻")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color.mainBlack)
                                    TextField("뜻을 입력해주세요", text: $wordMeaning, axis: .vertical)
                                        .padding(10)
                                        .accentColor(.mainBlue)
                                        .lineLimit(3...5)
                                        .background(Color.gray6)
                                        .cornerRadius(20, corners: .allCorners)
                                        .fontWeight(.semibold)
                                        .font(.subheadline)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }
                        // MARK: - 2. 문장 암기장 만들기
                        else if segmnetationSelection == .sentence {
                            VStack(alignment: .leading, spacing: 10) {
                                VStack(alignment: .leading) {
                                    Text("문장")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    TextField("문장을 입력해주세요", text: $wordString, axis: .vertical)
                                        .padding(10)
                                        .accentColor(.mainBlue)
                                        .lineLimit(5...8)
                                        .background(Color.gray6)
                                        .cornerRadius(20, corners: .allCorners)
                                        .fontWeight(.semibold)
                                        .font(.subheadline)
                                        .multilineTextAlignment(.leading)
                                }
                                VStack(alignment: .leading) {
                                    Text("의미")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    TextField("의미를 입력해주세요", text: $wordMeaning, axis: .vertical)
                                        .padding(10)
                                        .accentColor(.mainBlue)
                                        .lineLimit(6...9)
                                        .background(Color.gray6)
                                        .cornerRadius(20, corners: .allCorners)
                                        .fontWeight(.semibold)
                                        .font(.subheadline)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }
                        // MARK: - 3. 질문답변 암기장 만들기
                        else {
                            VStack(alignment: .leading, spacing: 10) {
                                VStack(alignment: .leading) {
                                    Text("질문")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    TextField("문장을 입력해주세요", text: $wordString, axis: .vertical)
                                        .padding(10)
                                        .accentColor(.mainBlue)
                                        .lineLimit(8...12)
                                        .background(Color.gray6)
                                        .cornerRadius(20, corners: .allCorners)
                                        .fontWeight(.semibold)
                                        .font(.subheadline)
                                        .multilineTextAlignment(.leading)
                                }
                                VStack(alignment: .leading) {
                                    Text("답변")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    TextField("의미를 입력해주세요", text: $wordMeaning, axis: .vertical)
                                        .padding(10)
                                        .accentColor(.mainBlue)
                                        .lineLimit(8...12)
                                        .background(Color.gray6)
                                        .cornerRadius(20, corners: .allCorners)
                                        .fontWeight(.semibold)
                                        .font(.subheadline)
                                        .multilineTextAlignment(.leading)
                                }
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
                        // MARK: - 작성된 Words를 List에 추가할 수 있도록 함
                        // TODO: - 주석 풀기
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
                                                            id: UUID().uuidString,
                                                            wordString: wordString,
                                                            wordMeaning: wordMeaning,
                                                            wordLevel: wordLevel)
                        )
                        
                        coreDataStore.addWord(note: wordNote,
                                              id: UUID().uuidString,
                                              wordLevel: Int64(wordLevel),
                                              wordMeaning: wordMeaning,
                                              wordString: wordString)
                        
                        // MARK: coreData 정상 작동 시 코드 삭제
//                        myNoteStore.myWordsWillBeFetchedFromDB(wordNote: wordNote) {
//                            self.noteLists = myNoteStore.myWords
//                        }
                        
                        // MARK: - 텍스트 필드를 비워주고..
                        wordString = ""
                        wordMeaning = ""
                        wordLevel = 0
                        print("텍스트 필드 Reset")
                    } label: {
                        Text("등록하기")
                    }
                    
                }
            }
        }
        .padding()
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
//
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button {
//                    myNoteStore.myWordsWillBeFetchedFromDB(wordNote: wordNote) {
//                        self.noteLists = myNoteStore.myWords
//                    }
//                    dismiss()
//                } label: {
//                    Text("저장하기")
//                        .font(.subheadline)
//                        .fontWeight(.regular)
//                        .foregroundColor(.mainBlack)
//
//                }
//
//            }
        }
    }
}

// TODO: enum case를 한글에서 영어로 변경해주세요. 3 ~ 40 자 사이
enum AddWordCategory: String, CaseIterable {
    case word = "단어"
    case sentence = "문장"
    case qustionAndAnswer = "질문과 답"
}

// struct AddWordView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            AddWordView(wordNote: NoteEntity(),
//                        noteLists: .constant([Word(id: "",
//                                                   wordString: "Hello",
//                                                   wordMeaning: "안녕",
//                                                   wordLevel: 0)]))
//        }
//    }
// }
