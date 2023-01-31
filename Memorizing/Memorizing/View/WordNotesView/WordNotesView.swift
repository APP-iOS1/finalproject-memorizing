//
//  WordNotesView.swift
//  Memorizing
//
//  Created by 진준호 on 2023/01/05.
//

import SwiftUI
import SwiftUIProgressiveOnboard

// let progressiveOnboardsJson = """
// [
//    {
//        "description": "우측 아래에 +버튼을 눌러서, 나만의 암기장을 만들어보세요!",
//        "previousButtonTitle": "이전",
//        "nextButtonTitle": "시작!"
//    }
// ]
// """

// MARK: 암기장 탭에서 가장 메인으로 보여주는 View
struct WordNotesView: View {
    
    //    @ObservedObject var onboard = ProgressiveOnboard.init(withJson: progressiveOnboardsJson)
    
    @State private var isShowingSheet: Bool = false
    @State private var memoryStepToggle: Bool = true
    @State private var reviewStepToggle: Bool = false
    @State private var menuXAxis: Double = -132
    @State private var isShowingNewMemorySheet: Bool = false
    @State private var isShownNotification: Bool = false
    @EnvironmentObject var myNoteStore: MyNoteStore
    
    var body: some View {
        ZStack {
            VStack {
                Header(memoryStepToggle: $memoryStepToggle, reviewStepToggle: $reviewStepToggle, menuXAxis: $menuXAxis)
                
                if memoryStepToggle == true && reviewStepToggle == false {
                    ScrollView(showsIndicators: false) {
                        ForEach(myNoteStore.myWordNotes) { myWordNote in
                            MyMemoryNote(myWordNote: myWordNote)
                        }
                        .padding(.bottom, 80)
                    }
                    
                } else if memoryStepToggle == false && reviewStepToggle == true {
                    ScrollView(showsIndicators: false) {
                        ForEach(myNoteStore.myWordNotes) { myWordNote in
                            StudyAgainView(myWordNote: myWordNote)
                        }
                    }
                }
                Spacer()
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image("Logo")
                        .resizable()
                        .frame(width: 35, height: 22)
                        .padding(.leading, 10)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShownNotification.toggle()
                        print("알림확인 버튼이 눌렸습니다.")
                    } label: {
                        Image(systemName: "bell")
                            .foregroundColor(.mainDarkBlue)
                            .fontWeight(.medium)
                    }
                    .sheet(isPresented: $isShownNotification) {
                         NotificationView(isShownNotification: $isShownNotification)
                     }
                }
            }
            
            VStack {
                
                if memoryStepToggle == true && reviewStepToggle == false {
                    Button {
                        print("새로운 일기장 만들기 버튼이 눌렸습니다.")
                        isShowingNewMemorySheet.toggle()
                    } label: {
                        Circle()
                            .foregroundColor(.mainBlue)
                            .frame(width: 65, height: 65)
                            .overlay {
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .font(.title3)
                                    .bold()
                            }
                            .shadow(radius: 1, x: 1, y: 1)
                    }
                    .offset(x: UIScreen.main.bounds.width * 0.36, y: UIScreen.main.bounds.height * 0.33)
                    .sheet(isPresented: $isShowingNewMemorySheet) {
                        NewMakeMemoryNote(isShowingNewMemorySheet: $isShowingNewMemorySheet)
                    }
                }
            }
            
            //            if(onboard.showOnboardScreen) {
            //                ProgressiveOnboardView.init(withProgressiveOnboard: self.onboard)
            //            }
        }
        //        .frame(maxWidth: .infinity, maxHeight: .infinity)
        //        .coordinateSpace(name: "OnboardSpace")
        //        .onAppear() {
        //            // Start onboard on appear
        //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { /// Delay for the UI did load
        //                self.onboard.showOnboardScreen = true
        //            }
        //        }
    }
}

struct Header: View {
    @Binding var memoryStepToggle: Bool
    @Binding var reviewStepToggle: Bool
    @Binding var menuXAxis: Double
    
    var body: some View {
        
        VStack(spacing: 5) {
            HStack(spacing: 25) {
                Button {
                    memoryStepToggle = true
                    reviewStepToggle = false
                    menuXAxis = -132
                } label: {
                    Text("메모 암기장")
                        .foregroundColor(memoryStepToggle ? .mainDarkBlue : .gray3)
                        .fontWeight(.bold)
                }
                
                Button {
                    reviewStepToggle = true
                    memoryStepToggle = false
                    menuXAxis = -40
                } label: {
                    Text("복습하기")
                        .foregroundColor(reviewStepToggle ? .mainDarkBlue : .gray3)
                        .fontWeight(.bold)
                }
                
                Spacer()
            }
            .padding(.top, 20)
            .padding(.leading, 25)
            
            Rectangle()
                .fill(Color.mainDarkBlue)
                .animation(.linear(duration: 0.2), value: menuXAxis)
                .offset(x: menuXAxis)
                .frame(width: memoryStepToggle ? 85 : 70, height: 2)
        }
        
    }
}

struct WordNotesView_Previews: PreviewProvider {
    static var previews: some View {
        WordNotesView()
            .environmentObject(MyNoteStore())
    }
}
