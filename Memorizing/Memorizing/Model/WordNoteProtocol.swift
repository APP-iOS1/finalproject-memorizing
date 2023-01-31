//
//  WordNoteProtocol.swift
//  Memorizing
//
//  Created by 이종현 on 2023/02/01.
//

import Foundation

protocol Note {
    var id: String { get set}
    // 암기장 이름
    var noteName: String { get set}
    // 암기장 카테고리
    var noteCategory: String { get set }
    // 등록한 유저 UID
    var enrollmentUser: String { get set }
    // 등록한 날짜
    var updateDate: Date { get set }

}
