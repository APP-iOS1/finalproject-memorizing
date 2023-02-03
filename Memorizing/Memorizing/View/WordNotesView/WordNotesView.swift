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
    @Namespace var namespace
    @State private var isShowingNewMemorySheet: Bool = false
    // @State private var isShownNotification: Bool = false
    //    @EnvironmentObject var myNoteStore: MyNoteStore
    @EnvironmentObject var coreDataStore: CoreDataStore
    
    var body: some View {
        ZStack {
            VStack {
                Header(memoryStepToggle: $memoryStepToggle,
                       reviewStepToggle: $reviewStepToggle,
                       namespace: namespace.self)
                
                if memoryStepToggle == true && reviewStepToggle == false {
                    ScrollView(showsIndicators: false) {
                        ForEach(coreDataStore.notes) { myWordNote in
                            MyMemoryNote(myWordNote: myWordNote)
                        }
                        .padding(.bottom, 80)
                    }
                    
                } else if memoryStepToggle == false && reviewStepToggle == true {
                    ScrollView(showsIndicators: false) {
                        ForEach(coreDataStore.notes.filter({$0.words?.count != 0})) { myWordNote in
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
                    NavigationLink {
                        NotificationScheduleView()
                    } label: {
                        Image(systemName: "bell")
                            .foregroundColor(.mainDarkBlue)
                            .fontWeight(.medium)
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
    let namespace: Namespace.ID
    
    var body: some View {
        
        VStack(spacing: 5) {
            HStack(spacing: 25) {
                VStack(spacing: 5) {
                    Text("메모 암기장")
                        .foregroundColor(memoryStepToggle ? .mainDarkBlue : .gray3)
                        .fontWeight(.bold)
                        .onTapGesture {
                            memoryStepToggle = true
                            reviewStepToggle = false
                        }
                    
                    if memoryStepToggle {
                        Rectangle()
                            .fill(Color.mainDarkBlue)
                            .frame(width: memoryStepToggle ? 85 : 70, height: 2)
                            .matchedGeometryEffect(id: "underline",
                                                   in: namespace,
                                                   properties: .frame)
                    }
                }
                
                VStack(spacing: 5) {
                    Text("복습하기")
                        .foregroundColor(reviewStepToggle ? .mainDarkBlue : .gray3)
                        .fontWeight(.bold)
                        .onTapGesture {
                            reviewStepToggle = true
                            memoryStepToggle = false
                        }
                    
                    if !memoryStepToggle {
                        Rectangle()
                            .fill(Color.mainDarkBlue)
                            .frame(width: memoryStepToggle ? 85 : 70, height: 2)
                            .matchedGeometryEffect(id: "underline",
                                                   in: namespace,
                                                   properties: .frame)
                    }
                }
                Spacer()
            }
            .animation(.linear(duration: 0.2), value: memoryStepToggle)
            .padding(.top, 10)
            .padding(.leading, 25)
            
        }
        
    }
}

struct WordNotesView_Previews: PreviewProvider {
    static var previews: some View {
        WordNotesView()
            .environmentObject(CoreDataStore())
    }
}
