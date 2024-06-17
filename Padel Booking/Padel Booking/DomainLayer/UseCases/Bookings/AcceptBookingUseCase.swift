import Foundation
import Combine

protocol AcceptBookingUseCase {
    func accept(_ booking: Booking) -> AnyPublisher<String, Error>
}

