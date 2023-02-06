import SwiftUI

struct CustomToastMessageModifier: ViewModifier {
    
    @Binding var isPresented: Bool
    let message: String
    
    init(
        isPresented: Binding<Bool>,
        message: String
    ) {
        _isPresented = isPresented
        self.message = message
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            VStack {
                if isPresented {
                    Spacer()
                    CustomToastMessage(isPresented: $isPresented,
                                       message: message)
                    .padding(.bottom, 17)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isPresented)
        }
    }
}

extension View {
    
    func customToastMessage(
        isPresented: Binding<Bool>,
        message: String) -> some View
    {
        modifier(
            CustomToastMessageModifier(
                isPresented: isPresented,
                message: message))
    }
}

struct CustomToastMessageModifier_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("가즈아")
        }
        .modifier(
            CustomToastMessageModifier(
                isPresented: .constant(true),
                message: "내용"
            )
        )
    }
}
