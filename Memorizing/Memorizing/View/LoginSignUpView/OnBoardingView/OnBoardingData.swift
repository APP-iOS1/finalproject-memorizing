//
//  OnBoardingData.swift
//  Memorizing
//
//  Created by 김혜지 on 2023/01/06.
//

struct OnBoardingData: Hashable, Identifiable {
    let id: Int
    let objectImage: String
    let text: String

    static let list: [OnBoardingData] = [
        OnBoardingData(id: 0, objectImage: "onboarding1", text: "반복학습을 통해\n자연스럽게 암기해보세요💡 "),
        OnBoardingData(id: 1, objectImage: "onboarding2", text: "총 4번의 복습을 마무리하면,\n참 잘했어요 도장도 드릴게요😊 "),
        OnBoardingData(id: 2, objectImage: "onboarding3", text: "나의 암기장을\n마켓에서 판매도 해보세요💵"),
        OnBoardingData(id: 3, objectImage: "onboarding4", text: "")
    ]
}
