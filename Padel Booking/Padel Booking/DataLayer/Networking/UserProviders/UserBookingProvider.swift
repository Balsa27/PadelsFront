
import Foundation
import Combine

final class UserBookingProvider {
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
    
    func getBookingDetails(id: String) {
        
    }
}
