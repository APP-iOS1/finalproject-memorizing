//
//  WordNotesView.swift
//  Memorizing
//
//  Created by 진준호 on 2023/01/05.
//

import SwiftUI

// MARK: 암기장 탭에서 가장 메인으로 보여주는 View
struct WordNotesView: View {
    @EnvironmentObject var myNoteStore: MyNoteStore
    @State private var isShowingSheet: Bool = false
    @State private var memoryStepToggle: Bool = true
    @State private var reviewStepToggle: Bool = false
    @State private var isToastToggle: Bool = false
    @State private var isShowingNewMemorySheet: Bool = false
    @Namespace var namespace
    @EnvironmentObject var coreDataStore: CoreDataStore
    
    var body: some View {
        ZStack {
            VStack {
                Header(memoryStepToggle: $memoryStepToggle,
                       reviewStepToggle: $reviewStepToggle,
                       namespace: namespace.self)
                
                if memoryStepToggle == true && reviewStepToggle == false {
                    
                    if coreDataStore.notes.isEmpty {
                        VStack {
                            Spacer()
                            
                            Text("등록된 암기장이 없습니다")
                                .padding(.bottom, 5)
                                .font(.headline)
                            HStack(spacing: 0) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.mainBlue)
                                Text(" 를 눌러 단어를 추가해주세요!")
                            }
                            .font(.footnote)
                            
                            Spacer()
                        }
                        .foregroundColor(Color.gray1)
                        .fontWeight(.medium)
                    } else {
                        ScrollView(showsIndicators: false) {
                            ForEach(coreDataStore.notes) { myWordNote in
                                MyMemoryNote(myWordNote: myWordNote)
                            }
                            .padding(.bottom, 80)
                        }
                    }
                    
                    
                    
                } else if memoryStepToggle == false && reviewStepToggle == true {
                    if coreDataStore.notes.isEmpty {
                        VStack {
                            Spacer()
                            
                            Text("등록된 암기장이 없습니다")
                                .padding(.bottom, 5)
                                .font(.headline)
                            HStack(spacing: 0) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.mainBlue)
                                Text(" 를 눌러 단어를 추가해주세요!")
                            }
                            .font(.footnote)
                            Spacer()
                        }
                        .foregroundColor(Color.gray1)
                        .fontWeight(.medium)
                    } else {
                        ScrollView(showsIndicators: false) {
                            ForEach(coreDataStore.notes.filter({$0.words?.count != 0})) { myWordNote in
                                StudyAgainView(myWordNote: myWordNote)
                            }
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
                    .offset(x: UIScreen.main.bounds.width * 0.36,
                            y: UIScreen.main.bounds.height * 0.33)
//                    , y: UIScreen.main.bounds.height * 0.33
                    .sheet(isPresented: $isShowingNewMemorySheet) {
                        NewMakeMemoryNote(isShowingNewMemorySheet: $isShowingNewMemorySheet,
                                          isToastToggle: $isToastToggle)
                    }
                }
            }
            
        }
        .customToastMessage(isPresented: $isToastToggle,
                            message: "새로운 암기장 등록완료!",
                            delay: 0)
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
                    Text("나의 암기장")
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
