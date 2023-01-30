//
//  TabView.swift
//  Memorizing
//
//  Created by 진준호 on 2023/01/05.
//

import SwiftUI

// MARK: 암기장, 마켓, 마이페이지를 Tab으로 보여주는 View
struct MainView: View {
    @State private var tabSelection = 1
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var marketStore: MarketStore
    @EnvironmentObject var myNoteStore: MyNoteStore
    
    var body: some View {
        TabView(selection: $tabSelection) {
            NavigationStack {
                WordNotesView()
            }.tabItem {
                VStack {
                    Image(systemName: "note.text")
                    Text("암기장")
                }
            }.tag(1)
            
            NavigationStack {
                MarketView()
            }.tabItem {
                VStack {
                    Image(systemName: "basket")
                    Text("마켓")
                }
            }.tag(2)
            
            NavigationStack {
                MyPageView()
            }.tabItem {
                VStack {
                    Image(systemName: "person")
                    Text("마이페이지")
                }
            }.tag(3)
        }
        .onAppear {
            if authStore.user != nil {
                myNoteStore.myNotesWillBeFetchedFromDB()
                Task {
                    await marketStore.marketNotesWillFetchDB()
                    await marketStore.filterMyNoteWillFetchDB()
                    await marketStore.myNotesArrayWillFetchDB()
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(AuthStore())
            .environmentObject(MyNoteStore())
            .environmentObject(MarketStore())
    }
}
