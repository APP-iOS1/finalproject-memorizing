//
//  Model.swift
//  Memorizing
//
//  Created by 진준호 on 2023/01/05.
//

import SwiftUI

// MARK: Word - 단어, 용어 등
struct Word: Identifiable {
    var id: String
    var wordString: String
    var wordMeaning: String
    var wordLevel: Int
}
