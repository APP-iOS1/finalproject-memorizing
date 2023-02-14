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
    
    @State private var heightRate: CGFloat = 0.133
    
    var selectedWordNote: MarketWordNote
    
    var body: some View {
        
        if selectedCategory == selectedWordNote.noteCategory
            || selectedCategory == "전체" {
            Button {
                marketStore.sendWordNote = selectedWordNote
                
                isSheetOpen.toggle()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray4)
                        // .frame(width: UIScreen.main.bounds.width * 0.43)
                    
                    HStack {
                        Rectangle()
                            .cornerRadius(30, corners: [.topLeft, .bottomLeft])
                            .frame(width: UIScreen.main.bounds.width * 0.035)
                        
                        // TODO: 카테고리별로 색상 다르게
                            .foregroundColor(selectedWordNote.noteColor)
                        
                        VStack(alignment: .leading) {
                            // 암기장 카테고리
                            HStack(alignment: .top) {
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(selectedWordNote.noteColor)
                                    .frame(width: 40, height: 18)
                                    .overlay {
                                        Text(selectedWordNote.noteCategory)
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(selectedWordNote.noteColor)
                                    }
                                
                                Spacer()
                            }
                            .frame(height: UIScreen.main.bounds.height * 0.02)
                            
                            // 암기장 제목
                            HStack{
                                Text(selectedWordNote.noteName)
                                    .foregroundColor(.mainBlack)
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                                
                                Spacer()
                            }
                            .padding(.vertical, 1)
                            .frame(width: UIScreen.main.bounds.width * 0.34,
                                   height: UIScreen.main.bounds.height * 0.045)
                            
                            // 암기장 판매 가격
                            HStack {
                                HStack(spacing: 2) {
                                    let reviewCount: Int = selectedWordNote.reviewCount
                                    let reviewScore: Double = selectedWordNote.starScoreTotal / Double(reviewCount)
                                    let score: String = String(format: "%.1f", reviewScore) // "5.1"
                                    
                                    if reviewCount == 0 {
                                        Text(" ")
                                            .font(.caption2)
                                            .foregroundColor(Color.gray3)
                                    } else {
                                        Image(systemName: "star.fill")
                                            .font(.caption)
                                            .foregroundColor(Color.iTColor)
                                            .padding(.trailing, 1)
                                        
                                        Text("\(score) (\(reviewCount))")
                                            .font(.caption2)
                                            .foregroundColor(Color.gray2)
                                    }
                                }
                                
                                Spacer()
                                Text("\(selectedWordNote.notePrice) P")
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.mainDarkBlue)
                                    .padding(.trailing, 8)
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
