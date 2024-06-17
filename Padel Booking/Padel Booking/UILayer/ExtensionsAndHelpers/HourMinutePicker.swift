import Foundation
import SwiftUI

struct HourMinutePicker: View {
    @Binding var hourSelection: Int
    @Binding var minuteSelection: Int
    @Binding var isEditing: Bool

    static private let maxHours = 24
    static private let maxMinutes = 60
    private let hours = [Int](6...Self.maxHours)
    private let minutes = [0, 15, 30, 45]
    
    // Computed property to dynamically change available minutes
    private var availableMinutes: [Int] {
        hourSelection == 24 ? [0] : [0, 15, 30, 45]
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: .zero) {
                if isEditing {
                    Picker(selection: $hourSelection, label: Text("")) {
                        ForEach(hours, id: \.self) { value in
                            Text("\(value) hr")
                                .tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: isEditing ? geometry.size.width / 2 : 0 , alignment: .center)
                } else {
                    Text("\(String(format: "%02d", hourSelection)) : ")
                }
                if isEditing {
                    Picker(selection: $minuteSelection, label: Text("")) {
                        ForEach(availableMinutes, id: \.self) { value in
                            Text("\(value) min")
                                .tag(value)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .pickerStyle(.wheel)
                    .frame(width: isEditing ? geometry.size.width / 2 : 0, alignment: .center)
                } else {
                    Text("\(String(format: "%02d"))")
                }
            }
        }
    }
}
