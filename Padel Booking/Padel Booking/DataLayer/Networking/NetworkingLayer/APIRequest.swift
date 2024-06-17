import Foundation

struct APIRequest {
    private let baseURL: String = "http://164.92.147.250/"
    let endpoint: Endpoint
    let method: Method
    let body: [BodyParameter]
    let headers: [URLRequest.Headers: String]
    
    enum Method: String {
        case post = "POST"
        case get = "GET"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    init(
        method: Method = .post,
        endpoint: Endpoint,
        body: [BodyParameter] = [],
        headers: [URLRequest.Headers: String] = [:]
    ) {
        self.method = method
        self.endpoint = endpoint
        self.body = body
        self.headers = headers
    }
    
    
    func urlRequest() throws -> URLRequest {
        let urlString = baseURL + endpoint.path + endpoint.parameters
        guard let url = URL(string: urlString) else {
            throw APIRequestError.urlMalformed
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = method.rawValue
        
        if !body.isEmpty {
            let body = try? JSONSerialization.data(withJSONObject: body.convertToDictionary())
            request.httpBody = body
        }
        
        if !headers.isEmpty {
            headers.forEach { header in
                request.setValue(header.value, forHTTPHeaderField: header.key.rawValue)
            }
        }
        return request
    }
}

extension APIRequest {
    struct BodyParameter: Equatable {
        let key: String
        let value: AnyHashable
    }
}

extension APIRequest {
    enum Endpoint {
        case register
        case login
        case googleSignIn
        case appleSignIn
        case courtById(String)
        case addCourt
        case removeCourt
        case updateCourtStatus
        case createBooking
        case acceptBooking
        case rejectBooking
        case getBookingById(String)
        case courtPending(String)
        case userPending
        case userUpcoming
        case courtsByOrgId(String)
        case deleteAccount

        var path: String {
            switch self {
            case .register:
                return "api/auth/register"
            case .login:
                return "api/auth/login"
            case .googleSignIn:
                return "api/auth/google-signin"
            case .appleSignIn:
                return "api/auth/apple-signin"
            case .courtById(let id):
                return "court/\(id)"
            case .addCourt:
                return "api/court/add"
            case .removeCourt:
                return "court/remove"
            case .updateCourtStatus:
                return "court/update-status"
            case .createBooking:
                return "api/booking/create"
            case .acceptBooking:
                return "api/booking/accept"
            case .rejectBooking:
                return "api/booking/reject"
            case .getBookingById(let id):
                return "api/booking/get/\(id)"
            case .courtPending(let id):
                return "api/booking/court-pending/\(id)"
            case .userPending:
                return "api/booking/user-pending"
            case .userUpcoming:
                return "api/booking/user-upcoming"
            case .courtsByOrgId(let id):
                return "api/court/organization/\(id)"
            case .deleteAccount:
                return "api/player/delete"
            }
        }
        var parameters: String { "" }
    }
}


enum APIRequestError: Error {
    case urlMalformed
}


private extension URLRequest {
    mutating func setAuthorization(_ token: String, contentType: String?) {
        self.setValue("*/*", forHTTPHeaderField: URLRequest.Headers.accept.rawValue)
        self.setValue(contentType ?? "application/json", forHTTPHeaderField: URLRequest.Headers.contentType.rawValue)
        self.setValue("Bearer \(token)" , forHTTPHeaderField: URLRequest.Headers.authorization.rawValue)
    }
}

extension Array where Element == APIRequest.BodyParameter {
    func convertToDictionary() -> [String: AnyHashable] {
        var dict = [String: AnyHashable]()
        self.forEach {
            dict[$0.key] = $0.value
        }
        return dict
    }
}
