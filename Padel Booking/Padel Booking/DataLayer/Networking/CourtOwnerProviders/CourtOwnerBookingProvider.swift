import Foundation
import Combine

final class CourtOwnerBookingProvider: PendingBookingsProviderProtocol, AcceptBookingUseCase , RejectBookingUseCase, CancelBookingUseCase, CreateABookingUseCase, EditBookingUseCase {
    

    let webService: WebService
    
    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Belgrade")
        return dateFormatter
    }
    
    init(webService: WebService) {
        self.webService = webService
    }
    
    func createBooking(
        courtId: String,
        bookerId: String,
        startTime: Date,
        endtime: Date
    ) -> AnyPublisher<String, Error> {
        
        let bodyStartTime = dateFormatter.string(from: startTime)
        let bodyEndTime = dateFormatter.string(from: endtime)
        
        let request = APIRequest(
            endpoint: .createBooking,
            body: [
                APIRequest.BodyParameter(key: "courtId", value: courtId),
                APIRequest.BodyParameter(key: "bookedId", value: bookerId),
                APIRequest.BodyParameter(key: "startTime", value: bodyStartTime),
                APIRequest.BodyParameter(key: "endTime", value: bodyEndTime)
                
            ]
        )
        
        guard let urlRequest = try? request.urlRequest() else {
            return Fail(error: APIRequestError.urlMalformed)
                .eraseToAnyPublisher()
        }
        
        return Just(urlRequest)
            .flatMap {  request -> AnyPublisher<MessageDTO, Error>  in
                self.webService.execute(urlRequest, isAuthenticated: false, contentType: "application/json")
            }
            .map { $0.message }
            .eraseToAnyPublisher()
        
    }


    func reject(_ booking: Booking) -> AnyPublisher<String, Error> {
        let request = APIRequest(
            endpoint: .acceptBooking,
            body: [
                APIRequest.BodyParameter(key: "bookingId", value: booking.id),
                APIRequest.BodyParameter(key: "courtId", value: booking.courtId),
            ]
        )
        
        guard let urlRequest = try? request.urlRequest() else {
            return Fail(error: APIRequestError.urlMalformed)
                .eraseToAnyPublisher()
        }
        
        return Just(urlRequest)
            .flatMap {  request -> AnyPublisher<MessageDTO, Error>  in
                self.webService.execute(urlRequest, isAuthenticated: true, contentType: "application/json")
            }
            .map { $0.message }
            .eraseToAnyPublisher()
        
    }
    
    func accept(_ booking: Booking)  -> AnyPublisher<String, Error> {
        let request = APIRequest(
            endpoint: .acceptBooking,
            body: [
                APIRequest.BodyParameter(key: "BookingId", value: booking.id),
                APIRequest.BodyParameter(key: "CourtId", value: booking.courtId),
            ]
        )
        
        guard let urlRequest = try? request.urlRequest() else {
            return Fail(error: APIRequestError.urlMalformed)
                .eraseToAnyPublisher()
        }
        
        return Just(urlRequest)
            .flatMap {  request -> AnyPublisher<MessageDTO, Error>  in
                self.webService.execute(urlRequest, isAuthenticated: true, contentType: "application/json")
            }
            .map { $0.message }
            .eraseToAnyPublisher()
    }

    func cancel(booking: Booking)  -> AnyPublisher<String, Error>  {
        return Just("")
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func create(_ booking: Booking) -> AnyPublisher<Void, Error> {
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func replace(id: String, with booking: Booking) {
        
    }

    #warning("Fix response data")
    func getBookingDetails(id: String) -> AnyPublisher<Void, Error> {
        let request = APIRequest(
            method: .get,
            endpoint: .getBookingById(id)
        )

        guard let urlRequest = try? request.urlRequest() else {
            return Fail(error: APIRequestError.urlMalformed)
                .eraseToAnyPublisher()
        }

        return Just(urlRequest)
            .flatMap {  request -> AnyPublisher<EmptyDTO, Error>  in
                self.webService.execute(urlRequest, isAuthenticated: false, contentType: "application/json")
            }
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    func getPendingBookings(allCourtIds: [String]) -> AnyPublisher<[Booking], Error> {
        let allPublishers = allCourtIds.map {
            getPendingBookingsForCourtId($0)
        }

        return Publishers.MergeMany(allPublishers)
            .collect()
            .map { $0.flatMap { $0 } }
            .eraseToAnyPublisher()
    }

    private func getPendingBookingsForCourtId(_ id: String) -> AnyPublisher<[Booking], Error> {
        let request = APIRequest(
            method: .get,
            endpoint: .courtPending(id)
            )

        guard let urlRequest = try? request.urlRequest() else {
            return Fail(error: APIRequestError.urlMalformed)
                .eraseToAnyPublisher()
        }

        return Just(urlRequest)
            .flatMap {  request -> AnyPublisher<[BookingDTO], Error>  in
                self.webService.execute(urlRequest, isAuthenticated: true, contentType: "application/json")
            }
            .map { $0.map { $0.entity } }
            .eraseToAnyPublisher()
    }

    func getUpcomingBookings() {

    }
}

struct BookingDTO: Codable {
    let courtID, bookerID, startTime, endTime: String
    let status: Int

    enum CodingKeys: String, CodingKey {
        case courtID = "courtId"
        case bookerID = "bookerId"
        case startTime, endTime, status
    }

    private func convertStringToDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter.date(from: dateString)
    }

    var entity: Booking {
        Booking(
            id: "\(courtID)-\(bookerID)-\(startTime)-\(endTime)",
            courtId: courtID,
            userId: bookerID,
            startDate: convertStringToDate(startTime) ?? Date(),
            endDate: convertStringToDate(endTime) ?? Date(),
            title: bookerID,
            isConfirmed: status != 0
        )
    }
}
