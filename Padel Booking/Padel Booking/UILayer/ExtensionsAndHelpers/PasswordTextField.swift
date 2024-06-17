import Foundation
import SwiftUI
import SFSafeSymbols

struct PasswordField: View {
    
    @Binding var text: String
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        ZStack(alignment: .trailing) {
            if isPasswordVisible {
                TextField("", text: $text)
                    .placeholder(when: text.isEmpty, placeholder: {
                        Text("Your password")
                            .foregroundStyle(.gray.opacity(0.5))
                    })
                    .font(.system(size: 18))
                    .frame(height: 55)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding([.horizontal], 4)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.5)))
                    .foregroundColor(.white)
            } else {
                SecureField("", text: $text)
                    .placeholder(when: text.isEmpty, placeholder: {
                        Text("Your password")
                            .foregroundStyle(.gray.opacity(0.5))
                    })
                    .font(.system(size: 18))
                    .frame(height: 55)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding([.horizontal], 4)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.5)))
                    .foregroundColor(.white)
            }
            
            if !text.isEmpty {
                Button(action: {
                    withAnimation {
                        isPasswordVisible.toggle()
                    }
                }) {
                    
                    Image(systemSymbol: isPasswordVisible ? .eyeSlash : .eye)
                        .accentColor(.gray)
                        .padding(.trailing, 10)
                }
            }
        }
    }
}
