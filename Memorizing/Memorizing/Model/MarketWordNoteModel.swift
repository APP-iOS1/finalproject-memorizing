//
//  MarketNoteModel.swift
//  Memorizing
//
//  Created by 진준호 on 2023/01/18.
//

import Foundation
import SwiftUI

struct MarketWordNote: Identifiable, NoteProtocol {
    var id: String
    // 암기장 이름
    var noteName: String
    // 암기장 카테고리
    var noteCategory: String
    // 등록한 유저 UID
    var enrollmentUser: String
    // 암기장 가격
    var notePrice: Int
    // 등록한 날짜
    var updateDate: Date
    // 판매된 횟수
    var salesCount: Int
    // 암기장 총평점
    var starScoreTotal: Double
    // 등록된 리뷰 횟수
    var reviewCount: Int
    
    // 카테고리와 색상 매칭
    var noteColor: Color {
        switch noteCategory {
        case "영어":
            return Color.englishColor
        case "한국사":
            return Color.historyColor
        case "IT":
            return Color.iTColor
        case "경제":
            return Color.economyColor
        case "시사":
            return Color.knowledgeColor
        case "기타":
            return Color.etcColor
        default:
            return Color.mainDarkBlue
        }
    }
    
    // 날짜 형식 변경
    var updateDateFormatter: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        return dateFormatter.string(from: updateDate)
    }
}
