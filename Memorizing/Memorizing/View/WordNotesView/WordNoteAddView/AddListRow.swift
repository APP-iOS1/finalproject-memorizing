//
//  AddListRow.swift
//  Memorizing
//
//  Created by Jae hyuk Yim on 2023/01/06.
//

import SwiftUI

struct AddListRow: View {
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var marketStore: MarketStore
    
    var word: WordEntity
    
    @State private var selectedWord: [String] = []
    
    var body: some View {
        if selectedWord.contains(word.wordString ?? "no word name") {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.clear)
                .backgroundStyle(Color.gray7)
                .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.1)
                .overlay {
                    Button {
                        if let index = selectedWord.firstIndex(of: word.wordString ?? "no word name") {
                            selectedWord.remove(at: index)
                        }
                    } label: {
                        VStack(spacing: 0) {
                            Text(word.wordString ?? "no word name")
                                .font(.headline)
                                .foregroundColor(.mainBlack)
                                .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.05)
                                .multilineTextAlignment(.center)
                            
                            Text(word.wordMeaning ?? "no word meaning")
                                .font(.headline)
                                .foregroundColor(.mainBlue)
                                .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.05)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 15)
                    }
                }
                .animation(.spring(), value: selectedWord)
        } else {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.clear)
                .backgroundStyle(Color.gray7)
                .frame(width: 343, height: 53)
                .overlay {
                    HStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 1)
                            .backgroundStyle(Color.gray5)
                            .frame(width: 1, height: 14)
                        Spacer()
                    }
                }
                .overlay {
                    Button {
                        selectedWord.append(word.wordString ?? "no word name")
                    } label: {
                        HStack {
                            Text(word.wordString ?? "no word name")
                                .font(.headline)
                                .foregroundColor(.mainBlack)
                                .frame(maxWidth: 343/2)
                                .lineLimit(nil)
                            Spacer()
                            
                            Text(word.wordMeaning ?? "no word meaning")
                                .font(.headline)
                                .foregroundColor(.mainBlue)
                                .frame(maxWidth: 343/2)
                                .lineLimit(nil)
                            
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 15)
                    }
                }
                .animation(.spring(), value: selectedWord)
        }
        
    }
}

// struct AddListRow_Previews: PreviewProvider {
//    static let word = Word(id: "장범준", wordString: "맥북", wordMeaning: "우리의 밥줄", wordLevel: 0)
//    static var previews: some View {
//        AddListRow(word: word)
//    }
// }
