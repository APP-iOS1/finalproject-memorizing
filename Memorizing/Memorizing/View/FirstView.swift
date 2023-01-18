//
//  FirstView.swift
//  Memorizing
//
//  Created by 윤현기 on 2023/01/06.
//

import SwiftUI

struct FirstView: View {
    @EnvironmentObject var userStore: UserStore
    var body: some View {
        
        // 강제로 딜레이 시켜서 자동로그인 상태면 온보딩 마지막 탭으로 이동
        Text("")
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                    userStore.state = .firstIn
                }
            }
    }
}

struct FirstView_Previews: PreviewProvider {
    static var previews: some View {
        FirstView()
    }
}
