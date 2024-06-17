import Foundation
import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let foregroundColor: Color
    let buttonHeight: CGFloat
    let minWidth: CGFloat
    
    init(
        buttonHeight: CGFloat = 54,
        minWidth: CGFloat = 0,
        backgroundColor: Color = Color("primaryGreen"),
        foregroundColor: Color = .white
        
    ) {
        self.buttonHeight = buttonHeight
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.minWidth = minWidth
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: minWidth, maxWidth: .infinity)
            .frame(height: buttonHeight)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .fontDesign(.monospaced)
            .fontWeight(.bold)
            .font(.headline)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(backgroundColor, lineWidth: 1))

    }
}

struct SecondaryButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let foregroundColor: Color
    let buttonHeight: CGFloat
    let shouldShowBorder: Bool

    init(
        buttonHeight: CGFloat = 54,
        backgroundColor: Color = .white,
        foregroundColor: Color = Color("primaryGreen"),
        shouldShowBorder: Bool = true

    ) {
        self.buttonHeight = buttonHeight
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.shouldShowBorder = shouldShowBorder
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: buttonHeight)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .fontDesign(.monospaced)
            .fontWeight(.bold)
            .font(.headline)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(shouldShowBorder ? foregroundColor : .clear, lineWidth: 1))
    }
}
