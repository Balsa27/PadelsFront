import SwiftUI
import SFSafeSymbols

struct ForgotPasswordView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var email: String = ""
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            
            
            VStack(alignment: .center, spacing: 10) {
                HStack {
                    Text("Forgot Password")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Image(systemSymbol: .xmark)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .onTapGesture {
                            withAnimation {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                        .padding(.trailing)
                }
                .padding(.vertical)
                
                Text("Please enter your email address below. We will send you instructions on how to reset your password.")
                    .multilineTextAlignment(.leading)
                    .font(.body)
            }
            
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Email")
                    .font(.callout)
                    .foregroundColor(.gray)
                
                TextField("", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.system(size: 18))
            }
            .padding(.top, 20)
            
            Button("Submit") {
                // Handle forgot password action
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, 50)
            
            Spacer()
        }
        .padding()
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
