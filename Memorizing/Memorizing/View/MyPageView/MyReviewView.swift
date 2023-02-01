//
//  MyReviewView.swift
//  Memorizing
//
//  Created by Jae hyuk Yim on 2023/02/01.
//

import SwiftUI

struct MyReviewView: View {
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var marketStore: MarketStore
    @EnvironmentObject var myNoteStore: MyNoteStore
    @EnvironmentObject var reviewStore: ReviewStore

    var body: some View {
        NavigationStack {
            VStack {
                Text("hello")
                ScrollView(showsIndicators: false) {
                    ForEach(reviewStore.reviews) { reviews in
                        MyReviewCell(reviews: reviews)
                    }
                }
            }
        }
    }
}

struct MyReviewView_Previews: PreviewProvider {
    static var previews: some View {
        MyReviewView()
    }
}
