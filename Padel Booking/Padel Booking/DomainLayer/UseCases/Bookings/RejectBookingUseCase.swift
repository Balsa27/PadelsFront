import Foundation
import Combine

protocol RejectBookingUseCase {
    func reject(_ booking: Booking) -> AnyPublisher<String, Error>
}
