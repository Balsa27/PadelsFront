import Foundation
import SwiftUI

public struct AnimatedTextField: View {
    private enum FocusedField: Int, Hashable {
        case username
    }

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
                    .fontWeight(text.isEmpty && field != .username ? .semibold : .regular)
                    .foregroundStyle(field == .username ? .white : .white.opacity(0.7))

                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .layoutPriority(1)
            .offset(y: isPlaceholderFocused || text != "" ? -15 : 0)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isPlaceholderFocused = true
                    field = .username
                }
            }

            TextField("", text: $text)
                .padding(EdgeInsets(
                    top: text.isEmpty && field != .username ? 0 : 20.0,
                    leading: 16.0,
                    bottom: 0,
                    trailing: 6.0)
                )
                .disableAutocorrection(true)
                .foregroundStyle(.white)
                .autocapitalization(.none)
                .frame(height: 50)
                .tint(.white)
                .frame(maxWidth: .infinity)
                .focused($field, equals: .username)
                .font(.body)
                .fontWeight(.semibold)
                .contentShape(Rectangle())
                .onSubmit {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isPlaceholderFocused = true
                    }
                }
                .onChange(of: field) { _, newValue in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isPlaceholderFocused = newValue == .username
                    }
                }
        }
        .frame(height: 70.0)
        .overlay {
            RoundedRectangle(cornerRadius: 10.0)
                .inset(by: 1.0)
                .stroke(.white.opacity(field == .username ? 1 : 0.3), lineWidth: 2)
        }
        .onTapGesture {
            field = .username
        }
    }
}

#Preview {
    VStack {
        Spacer()
        AnimatedTextField(placeholder: "Email address", text: .constant("asdasdasd"))
            .background(.clear)
            .padding()
        Spacer()
    }
    .background(.black)
}
