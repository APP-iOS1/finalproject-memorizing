import SwiftUI

struct CustomAlert: View {
    
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let primaryButtonTitle: String
    let primaryAction: () -> Void
    let withCancelButton: Bool
    let cancelButtonText: String
    
    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .foregroundColor(.black)
                .font(.title3)
                .bold()
            
            Text(message)
                .foregroundColor(.gray1)
                .multilineTextAlignment(.center)
                .frame(minHeight: 60)
                .font(.subheadline)
            
            Divider()
            
            HStack {
                if withCancelButton {
                    Button(action: { isPresented = false }) {
                        Text(cancelButtonText)
                            .padding(.vertical, 6)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.gray2)
                }
                
                Button {
                    primaryAction()
                    isPresented = false
                } label: {
                    Text(primaryButtonTitle)
                        .bold()
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.mainBlue)
            }
        }
        .padding(16)
        .frame(width: 300)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray3.opacity(0.5), lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white)
                )
        )
        .padding(.bottom, 35)
    }
}

struct CustomAlert_Previews: PreviewProvider {
    static var previews: some View {
        CustomAlert(
            isPresented: .constant(true),
            title: "타이틀",
            message: "메시지메시지메시지~",
            primaryButtonTitle: "확인!",
            primaryAction: { },
            withCancelButton: true,
            cancelButtonText: "취소")
    }
}
