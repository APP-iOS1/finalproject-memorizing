//
//  AddWordToastMessageModifier.swift
//  Memorizing
//
//  Created by 윤현기 on 2023/02/10.
//

import SwiftUI

struct AddWordToastMessageModifier: ViewModifier {
    
    @Binding var isPresented: Bool
    let message: String
    var delay: Double
    
    init(
        isPresented: Binding<Bool>,
        message: String,
        delay: Double  = 0
    ) {
        _isPresented = isPresented
        self.message = message
        self.delay = delay
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            VStack {
                if isPresented {
                    Spacer()
                    AddWordToastMessage(isPresented: $isPresented,
                                       message: message)
                    .padding(.bottom, 17)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)))
                }
            }
            .animation(.easeInOut(duration: 0.3).delay(delay), value: isPresented)
        }
    }
}

extension View {
    
    func AddWordToastMessage(
        isPresented: Binding<Bool>,
        message: String,
        delay: Double) -> some View
    {
        modifier(
            AddWordToastMessageModifier(
                isPresented: isPresented,
                message: message,
                delay: delay))
    }
}

struct AddWordToastMessageModifier_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("가즈아")
        }
        .modifier(
            AddWordToastMessageModifier(
                isPresented: .constant(true),
                message: "내용"
            )
        )
    }
}
