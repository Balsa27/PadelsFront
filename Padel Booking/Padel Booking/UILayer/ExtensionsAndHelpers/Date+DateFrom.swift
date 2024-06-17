import Foundation
extension Date {
    static func dateFrom(_ day: Int, _ month: Int, _ year: Int, _ hour: Int = 0, _ minute: Int = 0) -> Date {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)
        return calendar.date(from: dateComponents) ?? .now
    }

    func formatted(with format: String) -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format

        return dateFormatter.string(from: self)
    }

    static func from(_ longDate: String) -> Date {

        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "EEE MMM dd yyyy HH:mm:ss 'GMT'Z (zzzz)"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        return dateFormatter.date(from: longDate) ?? Date()
    }

    func distance(from date: Date, only component: Calendar.Component, calendar: Calendar = .current) -> Int {

        let days1 = calendar.component(component, from: self)
        let days2 = calendar.component(component, from: date)
        return days1 - days2
    }

    func hasSame(_ component: Calendar.Component, as date: Date) -> Bool {

        distance(from: date, only: component) == 0
    }

    var isWorkingDay: Bool {

        !Calendar.current.isDateInWeekend(self)
    }

    func hasSameDayAs(_ date: Date) -> Bool {

        let day1 = Calendar.current.component(.day, from: self)
        let day2 = Calendar.current.component(.day, from: date)

        return day1 == day2
    }

    func hourAndMinute() -> (hour: Int, minute: Int) {

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)
        return (hour, minute)
    }
}
