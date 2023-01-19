//
//  Model.swift
//  Memorizing
//
//  Created by 진준호 on 2023/01/05.
//

import SwiftUI

// MARK: User
struct User: Identifiable {
    var id: String
    var email: String
    var nickName: String
    var coin: Int
}

//// MARK: WordNote - 암기장
//struct WordNote: Identifiable {
//    var id: String
//    var noteName: String
//    var noteCategory: String
//    var enrollmentUser: String
//    var repeatCount: Int
//    var notePrice: Int
//
//    // 카테고리와 색상 매칭
//    var noteColor: Color {
//        switch noteCategory {
//        case "영어":
//            return Color.englishColor
//        case "한국사":
//            return Color.historyColor
//        case "IT":
//            return Color.iTColor
//        case "경제":
//            return Color.economyColor
//        case "시사":
//            return Color.knowledgeColor
//        case "기타":
//            return Color.etcColor
//        default:
//            return Color.mainDarkBlue
//        }
//    }
//    
//    // 학습 횟수에 따른 프로그래스바 길이 매칭
//    var progressbarWitdh: Double {
//        switch repeatCount {
//        case 0, 1:
//            return 0.0
//        case 2:
//            return 97.0
//        case 3:
//            return 185.0
//        default:
//            return 260.0
//        }
//    }
//}

// MARK: Word - 단어, 용어 등
struct Word: Identifiable {
    var id: String
    var wordString: String
    var wordMeaning: String
    var wordLevel: Int
}
