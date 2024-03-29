import SwiftUI

struct CustomAlertModifier: ViewModifier {
    
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let primaryButtonTitle: String
    let primaryAction: () -> Void
    let withCancelButton: Bool
    let cancelButtonText: String
    
    init(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        primaryButtonTitle: String,
        primaryAction: @escaping () -> Void,
        withCancelButton: Bool,
        cancelButtonText: String)
    {
        _isPresented = isPresented
        self.title = title
        self.message = message
        self.primaryButtonTitle = primaryButtonTitle
        self.primaryAction = primaryAction
        self.withCancelButton = withCancelButton
        self.cancelButtonText = cancelButtonText
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            ZStack {
                if isPresented {
                    Rectangle()
                        .fill(.black.opacity(0.3))
                        .ignoresSafeArea()
                        .transition(.opacity)
                    
                    CustomAlert(
                        isPresented: _isPresented,
                        title: self.title,
                        message: self.message,
                        primaryButtonTitle: self.primaryButtonTitle,
                        primaryAction: self.primaryAction,
                        withCancelButton: self.withCancelButton,
                        cancelButtonText: self.cancelButtonText)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isPresented)
        }
    }
}

extension View {
    
    func customAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        primaryButtonTitle: String,
        primaryAction: @escaping () -> Void,
        withCancelButton: Bool,
        cancelButtonText: String) -> some View
    {
        modifier(
            CustomAlertModifier(
                isPresented: isPresented,
                title: title,
                message: message,
                primaryButtonTitle: primaryButtonTitle,
                primaryAction: primaryAction,
                withCancelButton: withCancelButton,
                cancelButtonText: cancelButtonText))
    }
}

struct CustomAlertModifier_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("가즈아")
        }
        .modifier(
            CustomAlertModifier(
                isPresented: .constant(true),
                title: "제목",
                message: "내용",
                primaryButtonTitle: "확인버튼",
                primaryAction: { },
                withCancelButton: true,
                cancelButtonText: "취소")
        )
    }
}
