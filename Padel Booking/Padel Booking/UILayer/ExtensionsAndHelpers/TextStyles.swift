import Foundation
import SwiftUI

struct PrimaryButtonTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 54)
            .background(Color("primaryGreen"))
            .foregroundColor(.white)
            .font(.system(.headline, design: .monospaced))
            .fontWeight(.bold)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color("primaryGreen"), lineWidth: 1))
    }
}

extension View {
    func primaryButtonTextStyle() -> some View {
        self.modifier(PrimaryButtonTextStyle())
    }
}

struct SecondaryButtonTextStyle: ViewModifier {
    var buttonHeight: CGFloat
    var backgroundColor: Color
    var foregroundColor: Color

    func body(content: Content) -> some View {
        content
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: buttonHeight)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .font(.system(.headline, design: .monospaced))
            .fontWeight(.bold)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(backgroundColor, lineWidth: 1))
    }
}

extension View {
    func secondaryButtonTextStyle(buttonHeight: CGFloat = 54, backgroundColor: Color = .white, foregroundColor: Color = Color("primaryGreen")) -> some View {
        self.modifier(SecondaryButtonTextStyle(buttonHeight: buttonHeight, backgroundColor: backgroundColor, foregroundColor: foregroundColor))
    }
}

