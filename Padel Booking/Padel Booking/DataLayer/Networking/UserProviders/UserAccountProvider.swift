import Foundation
import Combine

final class UserAccountProvider {
    let webService: WebService

    init(webService: WebService) {
        self.webService = webService
    }

    func deleteAccount() -> AnyPublisher<Void, Error> {
        let request = APIRequest(endpoint: .deleteAccount)
        
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
}

struct EmptyDTO: Codable { }
