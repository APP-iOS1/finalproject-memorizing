//
//  AddWordToastMessage.swift
//  Memorizing
//
//  Created by 윤현기 on 2023/02/10.
//

import SwiftUI

struct AddWordToastMessage: View {
    var messageWidth = UIScreen.main.bounds.size.width
    
    @Binding var isPresented: Bool
    let message: String
    
    var body: some View {
        HStack {
            Image("LogoWhite")
                .resizable()
                .frame(width: messageWidth * 0.04,
                       height: messageWidth * 0.03)
                .padding(.leading, 7)
            
            Spacer()
            
            Text(message)
                .foregroundColor(.primary)
                .colorInvert()
                .font(.footnote)
                .bold()
            
            Spacer()
        }
        .padding(10)
        .frame(width: UIScreen.main.bounds.width * 0.77,
               height: UIScreen.main.bounds.height * 0.056)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.mainDarkBlue)
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                isPresented = false
            }
        }
    }
}

struct AddWordToastMessage_Previews: PreviewProvider {
    static var previews: some View {
        AddWordToastMessage(isPresented: .constant(true),
                            message: "구매 성공!")
    }
}
