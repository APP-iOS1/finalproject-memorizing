//
//  NewMakeMemoryNote.swift
//  Memorizing
//
//  Created by 염성필 on 2023/01/05.
//

import SwiftUI

var noteCategories: [String] = ["영어", "한국사", "IT", "경제", "시사", "기타"]

var noteCategoryColor: [
    Color] = [
        Color("EnglishColor"),
        Color("HistoryColor"),
        Color("ITColor"),
        Color("EconomyColor"),
        Color("KnowledgeColor"),
        Color("EtcColor")
    ]

struct NewMakeMemoryNote: View {
    
    // MARK: - 재혁 추가 (취소, 등록 시 창을 나가는 dismiss())
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var myNoteStore: MyNoteStore
    @EnvironmentObject var marketStore: MarketStore
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var coreDataStore: CoreDataStore
    @Binding var isShowingNewMemorySheet: Bool
    @Binding var isToastToggle: Bool
    @State private var noteName: String = ""
    // 카테고리를 눌렀을때 담기는 변수
    @State private var noteCategory: String = ""
    @State private var categoryColorIndex: Int = 0
    
    // MARK: - 총 3개 뷰 (상단 Header / 암기장 타이틀 입력 / 카테고리 선택)
    var body: some View {
        VStack(spacing: 50) {
            // 새로운 암기장 만들기
            makeNewNote
            // 암기장 이름
            noteTitle
            // 카테고리
//            category
            Spacer()
                .frame(height: 90)
            // 버튼
            makeNoteButton
            Spacer()
        }
        .padding()
    }
    
    // 최상단 (새로운 암기장 만들기 ~ X 표시)
    var makeNewNote: some View {
        HStack(spacing: 30) {
            VStack {
                // 아무 버튼도 아님
                Button {
                    //
                } label: {
                    Text("")
                        .font(.subheadline)
                        .fontWeight(.regular)
                        .foregroundColor(.mainBlack)
                }
            }
            .frame(width: 50)
            
            VStack {
                Text("새로운 암기장 만들기")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .frame(width: 200)
            
            VStack {
                Button {
                    print("취소버튼이 눌렸습니다.")
                    isShowingNewMemorySheet.toggle()
                    dismiss()
                } label: {
                    Text("취소")
                        .font(.subheadline)
                        .fontWeight(.regular)
                        .foregroundColor(.mainBlack)
                }
            }
            .frame(width: 50)
            
        }
    }
    
    // MARK: - 암기장 제목 / 카테고리 두개요소 묶음
    var noteTitle: some View {
        VStack(alignment: .leading, spacing: 40) {
            VStack(alignment: .leading) {
                Text("암기장 이름")
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                TextField("암기장 제목을 입력해주세요(필수)", text: $noteName)
                    .padding(15)
                    .accentColor(.mainBlue)
                    .lineLimit(3...5)
                    .background(Color.gray6)
                    .cornerRadius(20, corners: .allCorners)
                    .fontWeight(.semibold)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .onAppear {
                        UIApplication.shared.hideKeyboard()
                    }
            }
            
            VStack(alignment: .leading, spacing: 20) {
                Text("카테고리")
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                
                // MARK: - 버튼 눌리는 색상 표시 외 레이아웃 변경
                HStack {
                    ForEach(Array(zip(noteCategories.indices, noteCategories)), id: \.0) { (index, category) in
                        Button {
                            noteCategory = category
                        } label: {
                            Text("\(category)")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .foregroundColor(
                                    noteCategory == category ? Color.white : Color.gray4)
                        }
                        .frame(width: 53, height: 25)
                        .background {
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .fill(noteCategory == category ? noteCategoryColor[index] : Color.white)
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .stroke(noteCategory == category ? noteCategoryColor[index] : Color.gray4)
                        }
                        
                    }
                }
            }
        }
    }
    
    // 중 하단 ( 카테고리 )
//    var category: some View {
//
//        VStack(alignment: .leading, spacing: 20) {
//            Text("카테고리")
//                .font(.headline)
//                .fontWeight(.bold)
//                .multilineTextAlignment(.leading)
//
//            HStack {
//
//                ForEach(Array(zip(noteCategories.indices, noteCategories)), id: \.0) { (index, category) in
//                    Button {
//                        noteCategory = category
//                        print("선택된 카테고리 : \(noteCategory)")
//                    } label: {
//                        RoundedRectangle(cornerRadius: 30)
//                            .stroke(noteCategory == category ? noteCategoryColor[index] : Color.gray4)
//                            .frame(width: 50, height: 25)
//                            .overlay {
//                                Text("\(category)")
//                                    .font(.footnote)
//                                    .foregroundColor(
//                                        noteCategory == category ? noteCategoryColor[index] : Color.gray4
//                                    )
//                            }
//                    }
//                }
//            }
//        }
//    }
    
    // 하단 ( 버튼 )
    var makeNoteButton: some View {
        RoundedRectangle(cornerRadius: 30)
            .fill(!noteName.isEmpty && !noteCategory.isEmpty ? .blue : .gray)
            .frame(width: 350, height: 40)
            .overlay {
                Button {
                    let id = UUID().uuidString
                    myNoteStore.myNotesWillBeSavedOnDB(
                        wordNote: MyWordNote(id: id,
                                             noteName: noteName,
                                             noteCategory: noteCategory,
                                             enrollmentUser: authStore.user?.id ?? "",
                                             repeatCount: 0,
                                             firstTestResult: 0,
                                             lastTestResult: 0,
                                             updateDate: Date.now
                        )
                    )
                    
                    // coreData에 저장
                    coreDataStore.addNote(id: id,
                                          noteName: noteName,
                                          enrollmentUser: authStore.user?.id ?? "No Enrollment User",
                                          noteCategory: noteCategory,
                                          firstTestResult: 0,
                                          lastTestResult: 0,
                                          updateDate: Date())
                    
                    Task {
                        await marketStore.filterMyNoteWillFetchDB()
                        isToastToggle = true
                    }
                    
                    isShowingNewMemorySheet = false
                    print("새로운 암기장 만들기")
                } label: {
                    Text("새로운 암기장 만들기")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
            }
            .disabled(!noteName.isEmpty && !noteCategory.isEmpty ? false : true)
    }
}

struct NewMakeMemoryNote_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NewMakeMemoryNote(isShowingNewMemorySheet: .constant(true),
                              isToastToggle: .constant(true))
        }
    }
}
