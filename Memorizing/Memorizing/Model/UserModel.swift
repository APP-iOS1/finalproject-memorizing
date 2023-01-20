//
//  UserModel.swift
//  Memorizing
//
//  Created by 진준호 on 2023/01/19.
//

import Foundation

// MARK: User
struct User: Identifiable {
    var id: String
    var email: String
    var nickName: String
    var coin: Int
}
