//
//  MarketViewAddButton.swift
//  Memorizing
//
//  Created by 윤현기 on 2023/01/05.
//

import SwiftUI

// MARK: - point에 숫자만 입력하게 필터링
class NumbersOnly: ObservableObject {
    @Published var value = "" {
        didSet {
            let filtered = value.filter { $0.isNumber }
            
            if value != filtered {
                value = filtered
            }
        }
    }
}

// MARK: 마켓에 등록하기 버튼 눌렀을때 이동할 뷰
struct MarketViewAddButton: View {
    @ObservedObject var inputNum = NumbersOnly()
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var marketStore: MarketStore
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedNote: String = ""
//    @State private var pointText: String = ""
    
    var body: some View {
        
        // FIXME: 왜 LazyVStack으로 하면 Spacer()로 안밀리는가...
        VStack {
            // MARK: - 내 암기장 리스트
            HStack {
                Text("내 암기장")
                    .font(.title2) .fontWeight(.semibold)
                Spacer()
            }
            .padding(.leading, 20)
            .padding(.top)
            .padding(.bottom, 20)
            
            ScrollView {
                ForEach(authStore.filterWordNotes) { myWordNote in
                    let id = myWordNote.id
                    
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(selectedNote == id
                                ? Color.mainBlue
                                : Color.gray5)
                        .frame(width: 356, height: 90)
                        .overlay {
                            Button(action: {
                                
                                // TODO: 해당 인덱스 컬러 바꿔주기
                                selectedNote = id
                                
                            }, label: {
                                HStack {
                                    Rectangle()
                                        .cornerRadius(15, corners: [.topLeft, .bottomLeft])
                                        .frame(width: 10)
                                        .padding(.leading, 0.3)
                                        .foregroundColor(selectedNote == id
                                                         ? Color.mainBlue
                                                         : Color.gray5)
                                    
                                    VStack {
                                        // 암기장 카테고리
                                        HStack {
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color.gray3)
                                                .frame(width: 40, height: 20)
                                                .overlay {
                                                    Text(myWordNote.noteCategory)
                                                        .font(.caption2)
                                                        .foregroundColor(.gray2)
                                                }
                                            
                                            Spacer()
                                        }
                                        
                                        // 암기장 제목
                                        HStack {
                                            Text(myWordNote.noteName)
                                                .foregroundColor(.mainBlack)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .multilineTextAlignment(.leading)
                                                .lineLimit(2)
                                                .padding(.leading, 5)
                                                .padding(.top, -1)
                                            
                                            Spacer()
                                        }
                                        .padding(.bottom, 15)
                                    }
                                }
                                
                            })
                        }.padding(.bottom, 3)
                }
            } // ScrollView end
            
            Spacer()
            
            // MARK: - 구분선
            Divider()
                .padding(.horizontal)
                .padding(.top)
            
            // MARK: - 포인트 설정
            HStack {
                Text("포인트 설정")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray5)
                    .backgroundStyle(Color.gray4)
                    .frame(width: 124, height: 32)
                    .overlay {
                        HStack {
                            TextField("포인트 입력", text: $inputNum.value)
                                .padding(.leading)
                                .font(.footnote)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .padding(.bottom, 1)
                            Text("P")
                                .padding(.trailing)
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    }
            }
            .padding(25)
            
            // MARK: - 암기장 마켓에 등록하기 버튼
            Button {
                if selectedNote.isEmpty {
                    marketStore.maketNotesDidSaveDB(noteId: selectedNote,
                                                  userId: authStore.user?.id ?? "",
                                                  notePrice: Int(inputNum.value) ?? 0)
                    dismiss()
                }
            } label: {
                RoundedRectangle(cornerRadius: 20)
                    .fill(selectedNote.isEmpty
                          ? Color.gray2
                          : Color.mainBlue)
                    .frame(width: 355, height: 44)
                    .overlay {
                        Text("암기장 마켓에 등록하기")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
            }
            .padding(.bottom)
        }
        .navigationBarTitle("마켓에 등록하기")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.mainBlue)
                    .frame(width: 60, height: 30)
                    .overlay {
                        Text("\(authStore.user?.coin ?? 0) P")
                            .foregroundColor(.mainBlue)
                            .font(.subheadline)
                    }
            }
        }
        .onAppear {
            authStore.notesWillFetchDB()
        }
        .onDisappear {
            marketStore.marketNotesWillFetchDB()
        }
    }
}

struct MarketViewAddButton_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MarketViewAddButton()
                .environmentObject(AuthStore())
                .environmentObject(MarketStore())
        }
    }
}
