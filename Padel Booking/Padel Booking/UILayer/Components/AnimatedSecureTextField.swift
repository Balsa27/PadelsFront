import Foundation
import SwiftUI
public struct AnimatedSecureTextField: View {
    private enum FocusedField: Int, Hashable {
        case password
    }

    @State var isSecure = false
    @FocusState private var field: FocusedField?
    @State private var isPlaceholderFocused: Bool = false
    public let placeholder: String
    @Binding var text: String

    public init(placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
        self.field = nil
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            HStack {
                Text(placeholder)
                    .font(.body)
                    .fontWeight(text.isEmpty ? .semibold : .regular)
                    .foregroundStyle(field == .password ? .white : .white.opacity(0.7))
                    .offset(y: isPlaceholderFocused || text != "" ? -15 : 0)

                Spacer()
            }
            .padding(.horizontal, 16.0)
            .frame(maxWidth: .infinity)
            .layoutPriority(1)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isPlaceholderFocused = true
                    field = .password
                }
            }

            if isSecure {
                SecureField("", text: $text)
                    .padding(EdgeInsets(top: text.isEmpty && field != .password ? 0 : 20, leading: 16, bottom: 0, trailing: 6))
                    .disableAutocorrection(true)
                    .foregroundStyle(.white)
                    .autocapitalization(.none)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .focused($field, equals: .password)
                    .font(.body)
                    .fontWeight(text.isEmpty ? .semibold : .regular)
                    .contentShape(Rectangle())
                    .onSubmit {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPlaceholderFocused = true
                        }
                    }
                    .onChange(of: field) { _, newValue in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPlaceholderFocused = newValue == .password
                        }
                    }
            } else {
                TextField("", text: $text)
                    .padding(EdgeInsets(top: text.isEmpty && field != .password ? 0 : 20, leading: 16, bottom: 0, trailing: 6))
                    .disableAutocorrection(true)
                    .foregroundStyle(.white)
                    .autocapitalization(.none)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .focused($field, equals: .password)
                    .font(.body)
                    .fontWeight(text.isEmpty ? .semibold : .regular)
                    .contentShape(Rectangle())
                    .onSubmit {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPlaceholderFocused = true
                        }
                    }
                    .onChange(of: field) { _, newValue in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPlaceholderFocused = newValue == .password
                        }
                    }
            }

            HStack {
                Spacer()

                if !text.isEmpty {
                    Button {
                        isSecure.toggle()
                    } label: {
                        if isSecure {
                            Image(systemSymbol: .eye)
                                .resizable()
                                .foregroundStyle(.white)
                                .frame(width: 20, height: 12)
                        } else {
                            Image(systemSymbol: .eyeSlash)
                                .resizable()
                                .foregroundStyle(.white)
                                .frame(width: 20, height: 12)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 70.0)
        .overlay {
            RoundedRectangle(cornerRadius: 10.0)
                .inset(by: 1.0)
                .stroke(.white.opacity(field == .password ? 1 : 0.3), lineWidth: 2)
        }
    }
}

#Preview {
    VStack {
        Spacer()
        AnimatedSecureTextField(placeholder: "Email address", text: .constant("asdasdasd"))
            .background(.clear)
            .padding()
        Spacer()
    }
    .background(.black)
}
