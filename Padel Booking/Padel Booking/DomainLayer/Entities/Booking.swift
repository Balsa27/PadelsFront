import Foundation

struct Booking: Identifiable, Equatable, Hashable {
    let id: String
    let courtId: String
    let username: String = String(UUID().uuidString.prefix(5))
    var startDate: Date
    var endDate: Date
    var title: String
    var isConfirmed: Bool
    let userId: String

    init(id: String = UUID().uuidString, courtId: String, userId: String, startDate: Date, endDate: Date, title: String, isConfirmed: Bool) {
        self.id = id
        self.courtId = courtId
        self.userId = userId
        self.startDate = startDate
        self.endDate = endDate
        self.title = title
        self.isConfirmed = isConfirmed
    }
}

extension Booking {
    func hasOverlap(_ otherBookings: [Booking]) -> Bool {
        for _booking in otherBookings {
            if _booking.courtId == courtId &&
                doesOverlap(startDate, endDate, _booking.startDate, _booking.endDate) {
                return true
            }
        }
        return false
    }

    private func doesOverlap(_ startDate1: Date, _ endDate1: Date, _ startDate2: Date, _ endDate2: Date) -> Bool {
        // Ensuring that end dates are greater than start dates
           guard endDate1 > startDate1, endDate2 > startDate2 else {
               // Return false or handle error as you see fit
               return false
           }

           // Checking for overlap
           if startDate1 >= endDate2 || startDate2 >= endDate1 {
               return false
           } else {
               return true
           }
    }
}
