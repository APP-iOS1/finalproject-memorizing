import SwiftUI

struct CustomToastMessageModifier: ViewModifier {
    
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
                    CustomToastMessage(isPresented: $isPresented,
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
    
    func customToastMessage(
        isPresented: Binding<Bool>,
        message: String,
        delay: Double) -> some View
    {
        modifier(
            CustomToastMessageModifier(
                isPresented: isPresented,
                message: message,
                delay: delay))
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
