import Foundation
import Combine

final class CourtsProvider: GetAllCourtsUseCase {
    let webService: WebService

    init(webService: WebService) {
        self.webService = webService
    }

    func getAllCourts() -> AnyPublisher<[Court], Error> {

        #warning("Hardcoded org id for now")
        let request = APIRequest(
            method: .get,
            endpoint: .courtsByOrgId("3ee4280c-f737-4dbc-849c-f723d1e1c6e6")
        )

        guard let urlRequest = try? request.urlRequest() else {
            return Fail(error: APIRequestError.urlMalformed)
                .eraseToAnyPublisher()
        }

        return Just(urlRequest)
            .flatMap {  request -> AnyPublisher<[CourtDTO], Error>  in
                self.webService.execute(urlRequest, isAuthenticated: false, contentType: "application/json")
            }
            .map { $0.map(\.entity) }
            .eraseToAnyPublisher()
    }

    func court(id: String) -> AnyPublisher<Court, Error> {
        let request = APIRequest(
            method: .get,
            endpoint: .courtById(id)
        )

        guard let urlRequest = try? request.urlRequest() else {
            return Fail(error: APIRequestError.urlMalformed)
                .eraseToAnyPublisher()
        }

        return Just(urlRequest)
            .flatMap {  request -> AnyPublisher<CourtDTO, Error>  in
                self.webService.execute(urlRequest, isAuthenticated: false, contentType: "application/json")
            }
            .map { $0.entity }
            .eraseToAnyPublisher()
    }
}

struct CourtDTO: Codable {
    let courtID, organizationID, name, description: String
    let address: CourtAddressDTO
    let workStartTime, workEndTime: String
    let prices: [CourtPriceDTO]
    let imageURL: String
    let courtImages: [String]
    let status: Int
    let bookings: [BookingDTO]

    enum CodingKeys: String, CodingKey {
        case courtID = "courtId"
        case organizationID = "organizationId"
        case name, description, address, workStartTime, workEndTime, prices
        case imageURL = "imageUrl"
        case courtImages, status, bookings
    }
}

// MARK: - Address
struct CourtAddressDTO: Codable {
    let street, city, state, country: String
    let zipCode: String
}

// MARK: - Price
struct CourtPriceDTO: Codable {
    let id: String
    let amount: Int
    let duration: String
    let days: [Int]
    let timeStart, timeEnd: String
}

extension CourtDTO {
    var entity: Court {
        Court(
            id: courtID,
            name: name,
            description: "", //MARK: Needs to be implemented on BE
            location: address.entity,
            prices: prices.map { $0.entity },
            status: status == 0 ? .working : .notWorking,
            workingTime: CourtsProvider.parseToCourtTimeSpan(times: (start: workStartTime, end: workEndTime))!, //MARK: Remove force unwrap
            bookings: bookings.map { $0.entity }
        )
    }
}

extension CourtAddressDTO {
    var entity: CourtLocation {
        CourtLocation(street: street, city: city, state: state, country: country, zipCode: zipCode)
    }
}

#warning("REMOVE FORCE UNWRAPS")
extension CourtPriceDTO {
    var entity: CourtPricing {
        CourtPricing(
            price: amount,
            duration: duration.timeStringToDouble()!,
            timeSpan: CourtsProvider.parseToCourtTimeSpan(
                times: (start: timeStart, end: timeEnd)
            )!
        )
    }
}

fileprivate extension CourtsProvider {
    static func parseToCourtTimeSpan(times: (start: String, end: String)) -> CourtTimeSpan? {
        guard let (startHours, startMinutes) = parseTime(timeString: times.start),
              let (endHours, endMinutes) = parseTime(timeString: times.end) else {
            return nil
        }

        return CourtTimeSpan(startTimeHours: startHours, startTimeMinutes: startMinutes, endTimeHours: endHours, endTimeMinutes: endMinutes)
    }

    static func parseTime(timeString: String) -> (Int, Int)? {
        let components = timeString.split(separator: ":").compactMap { Int($0) }
        if components.count >= 2 {
            let hours = components[0]
            let minutes = components[1]
            return (hours, minutes)
        } else {
            // The time string is not in the expected format
            return nil
        }
    }

}
