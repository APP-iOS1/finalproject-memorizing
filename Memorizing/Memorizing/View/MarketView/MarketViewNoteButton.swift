//
//  MarketViewNoteButton.swift
//  Memorizing
//
//  Created by 윤현기 on 2023/01/05.
//

import SwiftUI

struct MarketViewNoteButton: View {
    
    @EnvironmentObject var marketStore: MarketStore
    @Binding var isSheetOpen: Bool
    
    @Binding var selectedCategory: String
    private let categoryArray: [String] = ["전체", "영어", "한국사", "IT", "경제", "시사", "기타"]
    
    var selectedWordNote: MarketWordNote
    
    var body: some View {
        
        if selectedCategory == selectedWordNote.noteCategory
        || selectedCategory == "전체" {
            Button {
                marketStore.sendWordNote = selectedWordNote
                
                isSheetOpen.toggle()
            } label: {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray4)
                    .frame(width: 168, height: 111)
                    .overlay {
                        HStack {
                            Rectangle()
                                .cornerRadius(15, corners: [.topLeft, .bottomLeft])
                                .frame(width: 10)
                            
                            // TODO: 카테고리별로 색상 다르게
                                .foregroundColor(selectedWordNote.noteColor)
                            
                            VStack {
                                // 암기장 카테고리
                                HStack {
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(selectedWordNote.noteColor)
                                        .frame(width: 40, height: 20)
                                        .overlay {
                                            Text(selectedWordNote.noteCategory)
                                                .font(.caption2)
                                                .fontWeight(.bold)
                                                .foregroundColor(selectedWordNote.noteColor)
                                        }
                                    
                                    Spacer()
                                }
                                .frame(height: 20)
                                
                                // 암기장 제목
                                HStack(alignment: .top) {
                                    Text(selectedWordNote.noteName)
                                        .foregroundColor(.mainBlack)
                                        .font(.footnote)
                                        .fontWeight(.heavy)
                                        .bold()
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(2)
                                    
                                    Spacer()
                                }
                                .frame(width: 140, height: 30)
                                .padding(.bottom, 3)
                                
                                // 암기장 판매 가격
                                HStack {
                                    Spacer()
                                    Text("\(selectedWordNote.notePrice) P")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.mainDarkBlue)
                                        .padding(.trailing, 5)
                                }
                                .frame(height: 20)
                            }
                            .padding(.horizontal, 3)
                            .padding(.vertical, 10)
                        }
                    }
            }
        }
    }
}

 struct MarketViewNoteButton_Previews: PreviewProvider {
    static var previews: some View {
        MarketViewNoteButton(isSheetOpen: .constant(true),
                             selectedCategory: .constant("IT"),
                             selectedWordNote: MarketWordNote(id: "",
                                                              noteName: "",
                                                              noteCategory: "",
                                                              enrollmentUser: "",
                                                              notePrice: 0,
                                                              updateDate: Date.now,
                                                              salesCount: 0,
                                                              starScoreTotal: 0,
                                                              reviewCount: 0)
                             )
    }
 }
