import Foundation

struct Court: Identifiable, Hashable, Equatable {
    let id: String
    var name: String
    var description: String
    var location: CourtLocation
    var prices: [CourtPricing]
    var status: CourtStatus
    var workingTime: CourtTimeSpan
    let bookings: [Booking]
}

struct CourtLocation: Equatable, Hashable {
    var street: String
    var city: String
    var state: String
    var country: String
    var zipCode: String
}

struct CourtTimeSpan: Equatable, Hashable {
    var startTimeHours: Int
    var startTimeMinutes: Int
    var endTimeHours: Int
    var endTimeMinutes: Int
}

struct CourtPricing: Equatable, Hashable {
    enum CourtPricingType {
        case perHour
        case perHourAndHalf
    }

    var courtPricingType: CourtPricingType {
        Int(duration * 60) % 60 == 0 ? .perHour : .perHourAndHalf
    }
    
    var price: Int
    var duration: Double
    var timeSpan: CourtTimeSpan
}

enum CourtStatus {
    case working
    case notWorking
}
