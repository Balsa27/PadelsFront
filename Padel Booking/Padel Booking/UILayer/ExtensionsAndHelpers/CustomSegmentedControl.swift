import Foundation
import SwiftUI

struct CustomSegmentedControl: View {

    typealias Header = UserBookingsView.ViewModel.DateHeaderUIModel
    @Binding private var selectedIndex: Int

    @State private var frames: [CGRect]
    @State private var backgroundFrame = CGRect.zero

    private let titles: [Header]

    init(selectedIndex: Binding<Int>, titles: [Header]) {

        self._selectedIndex = selectedIndex
        self.titles = titles
        self.frames = [CGRect](repeating: .zero, count: titles.count)
    }

    var body: some View {
        VStack {

            ScrollView(.horizontal, showsIndicators: false) {

                HStack(spacing: 0) {

                    ForEach(titles.indices, id: \.self) { index in

                        Button {
                            self.selectedIndex = index
                        } label: {

                            VStack(spacing: 0) {

                                if self.titles[index].isToday {
                                    Text("TODAY")
                                        .frame(maxWidth: .infinity)
                                        .font(.system(size: index == selectedIndex ? 14 : 12, weight: index == selectedIndex ? .bold : .light))
                                        .foregroundColor(Color("primaryGreen"))
                                }

                                Text(self.titles[index].title)
                                    .frame(maxWidth: .infinity)
                                    .font(.system(size: index == selectedIndex ? 14 : 12, weight: index == selectedIndex ? .bold : .light))
                                    .foregroundColor(Color("primaryGreen"))
                            }
                        }
                        .buttonStyle(CustomSegmentButtonStyle())
                        .background(
                            GeometryReader { geoReader in
                                Color.clear.preference(key: RectPreferenceKey.self, value: geoReader.frame(in: .global))
                                    .onPreferenceChange(RectPreferenceKey.self) {
                                        self.setFrame(index: index, originalFrame: $0)
                                    }
                            }
                        )
                    }
                }
                .frame(width: backgroundFrame.width)
                .modifier(UnderlineModifier(selectedIndex: self.selectedIndex,
                                            frames: self.frames))
            }
        }
        .background(
            GeometryReader { geoReader in
                Color.clear.preference(key: RectPreferenceKey.self, value: geoReader.frame(in: .global))
                    .onPreferenceChange(RectPreferenceKey.self) {

                        self.setBackgroundFrame(frame: $0)
                    }
            }
        )
    }

    private func setFrame(index: Int, originalFrame: CGRect) {

        let divider: CGFloat = self.titles.isEmpty ? 1.0 : CGFloat(self.titles.count)

        let frame = CGRect(x: originalFrame.origin.x,
                           y: originalFrame.origin.y,
                           width: backgroundFrame.size.width / divider,
                           height: originalFrame.height)

        self.frames[index] = frame
    }

    private func setBackgroundFrame(frame: CGRect) {

        backgroundFrame = frame
    }
}

struct RectPreferenceKey: PreferenceKey {

    typealias Value = CGRect

    static var defaultValue = CGRect.zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {

        value = nextValue()
    }
}

private struct CustomSegmentButtonStyle: ButtonStyle {

    private enum Constants {

        static let insets = EdgeInsets(top: 10,
                                       leading: 8,
                                       bottom: 10,
                                       trailing: 8)
    }

    func makeBody(configuration: Configuration) -> some View {

        configuration
            .label
            //.padding(Constants.insets)
            .padding(.bottom, 8)
            .background(Color.clear)
    }
}

struct UnderlineModifier: ViewModifier {

    var selectedIndex: Int
    let frames: [CGRect]

    func body(content: Content) -> some View {
        content
            .background(
                Rectangle()
                    .fill(Color("primaryGreen"))
                    .frame(width: frames[selectedIndex].width - 16,
                           height: 2)
                    .offset(x: (frames[selectedIndex].minX - frames[0].minX) + 8),
                alignment: .bottomLeading
            )
            .background(
                Rectangle()
                    .fill(.gray.opacity(0.5))
                    .frame(height: 1),
                alignment: .bottomLeading
            )
            .animation(.default, value: selectedIndex)
    }
}
