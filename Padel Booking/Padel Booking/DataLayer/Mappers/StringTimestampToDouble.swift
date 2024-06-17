import Foundation

extension String {
    func timeStringToDouble() -> Double? {
        let components = self.split(separator: ":").compactMap { Int($0) }
        if components.count == 3 {
            let hours = components[0]
            let minutes = components[1]
            let seconds = components[2]

            return Double(hours) + Double(minutes) / 60 + Double(seconds) / 3600
        } else {
            // The time string is not in the expected format
            return nil
        }
    }
}
