import Foundation
import Combine

protocol GetAllPendingBookingsUseCase {
    func getPendingBookings(allCourtIds: [String]) -> AnyPublisher<[Booking], Error>
}
