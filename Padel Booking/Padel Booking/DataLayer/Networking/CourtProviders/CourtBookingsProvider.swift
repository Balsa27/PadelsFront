import Foundation
import Combine

final class CourtBookingsProvider {
    let webService: WebService

    init(webService: WebService) {
        self.webService = webService
    }

    func getAllPendingBookings(courtIds: [String]) {

    }

    func getPendingBookings(courtId: String) {

    }

    func getUpcomingBookings(courtId: String) {

    }
}
