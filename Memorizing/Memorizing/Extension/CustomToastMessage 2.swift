import SwiftUI

struct CustomToastMessage: View {
    
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
        .frame(width: messageWidth * 0.6)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.mainDarkBlue)
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.9) {
                isPresented = false
            }
        }
    }
}

struct CustomToastMessage_Previews: PreviewProvider {
    static var previews: some View {
        CustomToastMessage(
            isPresented: .constant(true),
            message: "구매 성공!")
    }
}
