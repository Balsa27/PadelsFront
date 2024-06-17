import Foundation
import Combine

protocol CancelBookingUseCase {
    func cancel(booking: Booking) -> AnyPublisher<String, Error>
}
