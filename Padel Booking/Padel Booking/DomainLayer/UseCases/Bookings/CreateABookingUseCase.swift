import Foundation
import Combine

protocol CreateABookingUseCase {
    func create(_ booking: Booking) -> AnyPublisher<Void, Error>
}
