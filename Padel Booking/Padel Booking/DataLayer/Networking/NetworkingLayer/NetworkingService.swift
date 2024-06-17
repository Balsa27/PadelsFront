import Foundation
import Combine
import KeychainAccess

protocol WebService {
    func execute<D>(_ request: URLRequest, isAuthenticated: Bool, contentType: String?) -> AnyPublisher<D, Error> where D : Decodable
}

class NetworkingService: WebService {
    private let networkSession: NetworkSession
    private let sessionProvider: SessionOperable
    private let decoder: JSONDecoder
    
    init(
        decoder: JSONDecoder = JSONDecoder(),
        networkSession: NetworkSession = DataNetworkSession(),
        sessionProvider: SessionOperable
    ) {
        self.decoder = decoder
        self.networkSession = networkSession
        self.sessionProvider = sessionProvider
    }
    
    func execute<D>(_ request: URLRequest, isAuthenticated: Bool = true, contentType: String?) -> AnyPublisher<D, Error> where D : Decodable {
        var _request = request
        
        if isAuthenticated {
            _request.setAuthorization("\(sessionProvider.session?.accessToken ?? "")", contentType: contentType)
        }
        
        return networkSession.perform(with: _request)
            .decode(type: D.self, decoder: decoder)
            .mapError { error in
                if let error = error as? DecodingError {
                    var errorToReport = error.localizedDescription
                    switch error {
                    case .dataCorrupted(let context):
                        let details = context.underlyingError?.localizedDescription ?? context.codingPath.map { $0.stringValue }.joined(separator: ".")
                        errorToReport = "\(context.debugDescription) - (\(details))"
                    case .keyNotFound(let key, let context):
                        let details = context.underlyingError?.localizedDescription ?? context.codingPath.map { $0.stringValue }.joined(separator: ".")
                        errorToReport = "\(context.debugDescription) (key: \(key), \(details))"
                    case .typeMismatch(let type, let context), .valueNotFound(let type, let context):
                        let details = context.underlyingError?.localizedDescription ?? context.codingPath.map { $0.stringValue }.joined(separator: ".")
                        errorToReport = "\(context.debugDescription) (type: \(type), \(details))"
                    @unknown default:
                        break
                    }
                    print(errorToReport)
                    return APIError.unknown(reason: errorToReport)
                }  else {
                    return error
                }
            }
            .eraseToAnyPublisher()
    }
}

extension URLRequest {
    enum Headers: String {
        case accept = "Accept"
        case authorization = "Authorization"
        case contentType = "Content-Type"
    }
}

private extension URLRequest {
    mutating func setAuthorization(_ token: String, contentType: String?) {
        self.setValue("*/*", forHTTPHeaderField: URLRequest.Headers.accept.rawValue)
        self.setValue(contentType ?? "application/json", forHTTPHeaderField: URLRequest.Headers.contentType.rawValue)
        self.setValue("Bearer \(token)" , forHTTPHeaderField: URLRequest.Headers.authorization.rawValue)
    }
}
