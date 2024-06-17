import Foundation
import Combine

protocol NetworkSession {
    func perform(with request: URLRequest) -> AnyPublisher<Data, Error>
}

class DataNetworkSession: NetworkSession {
    private var hasAlreadyAttemptedRefreshToken = false
    func perform(with request: URLRequest) -> AnyPublisher<Data, Error> {
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 401 {
                            throw APIError.unknown(reason: "unathenticated")
                        }
                        else if httpResponse.statusCode == 422 {
                            throw APIError.canceled
                        }
                        else {
                            if let error =  try? JSONDecoder().decode(ErrorDTO.self, from: data) {
                                throw APIError.unknown(reason: error.error)
                            }
                            throw APIError.dataParseFailed
                        }
                        
                    }
                    throw APIError.dataParseFailed
                }

                return data
            }
            .tryCatch { error -> AnyPublisher<Data, Error> in
                //                if case APIError.unauthenticated = error {
                //                    self.hasAlreadyAttemptedRefreshToken = true
                //                    return AppDependenciesContainer.shared.authProvider.refreshToken()
                //                        .flatMap { _ in
                //                            return self.perform(with: request)
                //                        }
                //                        .tryCatch { error in
                //                            if let logoutAction = AppDependenciesContainer.shared.logoutAction {
                //                                logoutAction()
                //                            }
                //                            return Fail<Data, Error>(error: error)
                //                        }
                //                        .eraseToAnyPublisher()
                //                }
                return Fail(error: error)
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

enum APIError: Error, Equatable {
    case dataParseFailed
    case unauthenticated
    case unknown(reason: String)
    case canceled
}


struct ErrorDTO: Codable {
    let error: String
}

