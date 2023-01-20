//
//  review.swift
//  Memorizing
//
//  Created by 염성필 on 2023/01/18.
//
import SwiftUI

// MARK: - Review 모델 id, 작성자, 리뷰 내용, 날짜, 평점 
struct Review: Identifiable {
    var id: String
    var writer: String
    var reviewText: String
    var createDate: Date
    var starScore: Double
}
