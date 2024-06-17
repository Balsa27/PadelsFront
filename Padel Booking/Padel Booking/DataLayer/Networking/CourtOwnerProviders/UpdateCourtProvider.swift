import Foundation
import Combine

final class UpdateCourtProvider: CreateACourtUseCase {
    let webService: WebService

    init(webService: WebService) {
        self.webService = webService
    }

    func addCourt(_ court: Court) -> AnyPublisher<String, Error> {
        let request = APIRequest(endpoint: .addCourt)
        
        guard var urlRequest = try? request.urlRequest(),
              let courtEncodedData = convertCourtToJsonData(court)
        else {
            return Fail(error: APIRequestError.urlMalformed)
                .eraseToAnyPublisher()
        }

        urlRequest.httpBody = courtEncodedData

        return Just(urlRequest)
            .flatMap {  request -> AnyPublisher<EmptyDTO, Error>  in
                self.webService.execute(urlRequest, isAuthenticated: true, contentType: "application/json")
            }
            .map { _ in  "Court added successfully!" }
            .eraseToAnyPublisher()
        
    }
    
    func removeCourt(id: String) -> AnyPublisher<String, Error> {
        let request = APIRequest(
            endpoint: .removeCourt,
            body: [APIRequest.BodyParameter(key: "courtId", value: id)]
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
    
    func updateCourtStatus(id: String, status: Int) -> AnyPublisher<String, Error> {
        let request = APIRequest(
            endpoint: .updateCourtStatus,
            body: [
                APIRequest.BodyParameter(key: "courtId", value: id),
                APIRequest.BodyParameter(key: "status", value: status),
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
}

struct MessageDTO: Codable {
    let message: String
}

extension CourtLocation: Encodable {
    private enum CodingKeys: String, CodingKey {
        case street, city, state, country, zipCode
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(street, forKey: .street)
        try container.encode(city, forKey: .city)
        try container.encode(state, forKey: .state)
        try container.encode(country, forKey: .country)
        try container.encode(zipCode, forKey: .zipCode)
    }
}

extension UpdateCourtProvider {
    func convertCourtToJsonData(_ court: Court) -> Data? {
        let json = convertCourtToJsonString(court)

        // Serialize JSON
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            return jsonData
        } catch {
            print("Error serializing JSON: \(error)")
            return nil
        }
    }

    private func convertCourtToJsonString(_ court: Court) -> [String: Any] {
        var json = [String: Any]()

        json["Name"] = court.name
        json["Description"] = court.description

        // Address
        json["Address"] = [
            "Street": court.location.street,
            "City": court.location.city,
            "State": court.location.state,
            "Country": court.location.country,
            "ZipCode": court.location.zipCode
        ]

        // Working Time
        json["WorkStartTime"] = formatTime(hours: court.workingTime.startTimeHours, minutes: court.workingTime.startTimeMinutes)
        json["WorkEndTime"] = formatTime(hours: court.workingTime.endTimeHours, minutes: court.workingTime.endTimeMinutes)

        // Prices
        var pricesJson = [[String: Any]]()
        for price in court.prices {
            pricesJson.append([
                "Amount": price.price,
                "Duration": formatDuration(price.duration),
                "TimeStart": formatTime(hours: price.timeSpan.startTimeHours, minutes: price.timeSpan.startTimeMinutes),
                "TimeEnd": formatTime(hours: price.timeSpan.endTimeHours, minutes: price.timeSpan.endTimeMinutes),
                "Days": [/* Array of days */] // Assuming you have a way to determine these
            ])
        }
        json["Prices"] = pricesJson

        // Image URLs (assuming you have these URLs)
        json["ImageUrl"] = "http://example.com/court-image.jpg"
        json["CourtImages"] = [
            "http://example.com/court1.jpg",
            "http://example.com/court2.jpg"
        ]

        return json
    }

    private func formatTime(hours: Int, minutes: Int) -> String {
        String(format: "%02d:%02d:00", hours, minutes)
    }

    private func formatDuration(_ duration: Double) -> String {
        let hours = Int(duration)
        let minutes = Int((duration - Double(hours)) * 60)
        return String(format: "%02d:%02d:00", hours, minutes)
    }
}
