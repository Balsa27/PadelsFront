import Foundation

protocol EditBookingUseCase {
    func replace(id: String, with booking: Booking)
}
