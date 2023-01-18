//
//  AddWordView.swift
//  Memorizing
//
//  Created by Jae hyuk Yim on 2023/01/05.
//

import SwiftUI

struct AddWordView: View {
    // MARK: - 바인딩
    @EnvironmentObject var marketStore: MarketStore
    @EnvironmentObject var userStore: UserStore
    // 상위뷰랑 꼬일 수 있으므로, 그냥 var 선언하기 (Binding X)
    var wordNote: WordNote
    @Binding var noteLists: [Word]
    // MARK: - 단어, 문장, 질문과 답 피커 만들기 -> 아래 Enum으로 유형 선언되어 있음
    @State private var segmnetationSelection: AddWordCategory = .word
    //    init(wordNote: WordNote, list: [Word]) {
    //        self.wordNote = wordNote
    //        self.list = list
    //        UISegmentedControl.appearance().selectedSegmentTintColor = .systemBlue
    //        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    //        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
    //        // TextEditor 백그라운드 지우기
    //        UISegmentedControl.appearance().backgroundColor = .clear
    //    }
    // MARK: - 취소, 등록 시 창을 나가는 dismiss()
    @Environment(\.dismiss) private var dismiss
    // MARK: - 값(변수들)
    @State private var wordString: String = ""
    @State private var wordMeaning: String = ""
    @State private var wordLevel: Int = 0
    @State private var showingAlert = false
//    @State private var isAddButton: Bool = false
    @State private var displayLists: Bool = false
    // MARK: - TextEditor Plceholder
    //    let placeholder: String = "사용자 입력"
    // MARK: - 추가하기(+) 버튼을 눌렀을 때 이동할 AddWordView
    // MARK: - Navigation Stack 사용 안함
    var body: some View {
        VStack(alignment: .center) {
            // MARK: - Section1 - 타이틀 및 취소/저장 버튼
            Section {
                HStack(spacing: 30) {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Text("취소")
                                .font(.subheadline)
                                .fontWeight(.regular)
                                .foregroundColor(.mainBlack)
                        }
                    }
                    .frame(width: 70)
                    HStack {
                        Text("메모 암기장 만들기")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .frame(width: 180)
                    HStack {
                        Button {
                            showingAlert.toggle()
                        } label: {
                            Text("저장하기")
                                .font(.subheadline)
                                .fontWeight(.regular)
                                .foregroundColor(.mainBlack)
                        }
                        .alert(isPresented: $showingAlert) {
                            Alert(title: Text("암기장을 저장하시겠습니까?"),
                                  message: Text("취소시 저장된 데이터는 사라집니다"),
                                  primaryButton: .destructive(Text("취소하기"),
                                                              action: {}),
                                  secondaryButton: .cancel(Text("저장하기"),
                                                           action: {
                                userStore.myWordsWillFetchDB(wordNote: wordNote) {
                                    self.noteLists = userStore.myWords
                                }
                                dismiss()
                            }))
                        }
                    }
                    .frame(width: 70)
                }
            }
            Divider()
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
            .frame(height: 50)
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
                    .onAppear {
                        UIApplication.shared.hideKeyboard()
                    }
                }
                .padding()
            }
            // MARK: - Section4 - Button1: 계속해서 등록하기(추가) /  Button2: 현재까지 등록한 리스트 보이기
            Section {
                VStack {
                    HStack {
                        Button {
                            // TODO: - List 확인하기
                            displayLists.toggle()
                        } label: {
                            Circle()
                                .frame(width: 50, height: 50)
                                .foregroundColor(Color.mainBlue)
                                .overlay {
                                    Image(systemName: "list.number")
                                        .foregroundColor(.white)
                                        .fontWeight(.regular)
                                        .font(.title2)
                                }
                        }
                        .sheet(isPresented: $displayLists) {
                            AddListView(wordNote: wordNote, word: userStore.myWords)
                        }
                        Button {
                            userStore.myWordsDidSaveDB(wordNote: wordNote,
                                                word: Word(
                                                    id: UUID().uuidString,
                                                    wordString: wordString,
                                                    wordMeaning: wordMeaning,
                                                    wordLevel: wordLevel)
                            )
                            wordString = ""
                            wordMeaning = ""
                            wordLevel = 0
                        } label: {
                            Rectangle()
                                .frame(width: 272, height: 50)
                                .cornerRadius(20, corners: .allCorners)
                                .overlay {
                                    Text("암기목록 추가하기")
                                        .foregroundColor(.white)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                }
                        }
                    }
                }
            }
        }// ------- 전체 VStack
        .padding()
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
// AddWordView(wordNote:
// WordNote(id: "", noteName: "", noteCategory: "", enrollmentUser: "", repeatCount: 0, notePrice: 0)
// ,list: [Word(id: "", wordString: "", wordMeaning: "", wordLevel: 0)])
//    }
// }
