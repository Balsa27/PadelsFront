import Foundation
import Combine

final class AuthenticationProvider: LoginUseCase, SignUpUseCase, GoogleSignInUseCase {
    let webService: WebService
    let sessionService: SessionOperable
    let userDefaults: UserDefaultsProvidable
    
    init(
        webService: WebService,
        sessionService: SessionOperable,
        userDefaults: UserDefaultsProvidable
    ) {
        self.webService = webService
        self.sessionService = sessionService
        self.userDefaults = userDefaults
    }
    
    func login(email username: String, password: String) -> AnyPublisher<UserRole, Error> {
        let request = APIRequest(
            endpoint: .login,
            body: [
                APIRequest.BodyParameter(key: "login", value: username),
                APIRequest.BodyParameter(key: "password", value: password)
            ],
            headers: [.contentType : "application/json"]
        )
        
        guard let urlRequest = try? request.urlRequest() else {
            return Fail(error: APIRequestError.urlMalformed)
                .eraseToAnyPublisher()
        }
        
        return Just(urlRequest)
            .flatMap {  request -> AnyPublisher<TokenDTO, Error>  in
                self.webService.execute(urlRequest, isAuthenticated: false, contentType: "application/json")
            }
            .map {
                self.sessionService.saveSession(
                    session: Session(
                        uuid: UUID().uuidString,
                        username: username,
                        accessToken: $0.token,
                        refreshToken: "",
                        expiryDate: Date(),
                        refreshTokenExpiryDate: Date(),
                        usernameSlug: ""
                    )
                )
                
                return $0.role == 0 ? UserRole.user : UserRole.courtOwner
            }
            .eraseToAnyPublisher()
        
    }
    
    func signUp(email: String, username: String, password: String) -> AnyPublisher<Void, Error> {
        let request = APIRequest(
            endpoint: .register,
            body: [
                APIRequest.BodyParameter(key: "username", value: username),
                APIRequest.BodyParameter(key: "email", value: email),
                APIRequest.BodyParameter(key: "password", value: password)
            ],
            headers: [.contentType : "application/json"]
        )
        
        guard let urlRequest = try? request.urlRequest() else {
            return Fail(error: APIRequestError.urlMalformed)
                .eraseToAnyPublisher()
        }
        return Just(urlRequest)
            .flatMap {  request -> AnyPublisher<TokenDTO, Error>  in
                self.webService.execute(urlRequest, isAuthenticated: false, contentType: "application/json")
            }
            .map {
                return self.sessionService.saveSession(
                    session: Session(
                        uuid: UUID().uuidString,
                        username: username,
                        accessToken: $0.token,
                        refreshToken: "",
                        expiryDate: Date(),
                        refreshTokenExpiryDate: Date(),
                        usernameSlug: ""
                    )
                )
                
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
    
    func googleSignIn(googleToken: String, pushToken: String? = null) -> AnyPublisher<UserRole, Error> {
        let request = APIRequest(
            endpoint: .googleSignIn,
            body: [
                APIRequest.BodyParameter(key: "googleToken", value: googleToken),
                APIRequest.BodyParameter(key: "pushToken", value: pushToken ?? "")
            ],
            headers: [.contentType : "application/json"]
        )

        guard let urlRequest = try? request.urlRequest() else {
            return Fail(error: APIRequestError.urlMalformed)
                .eraseToAnyPublisher()
        }

        return Just(urlRequest)
            .flatMap { request -> AnyPublisher<TokenDTO, Error> in
                self.webService.execute(urlRequest, isAuthenticated: false, contentType: "application/json")
            }
            .map { tokenDTO -> UserRole in
                self.sessionService.saveSession(
                    session: Session(
                        uuid: UUID().uuidString,
                        username: username,
                         accessToken: $0.token,
                        refreshToken: "",
                        expiryDate: Date(),
                        refreshTokenExpiryDate: Date(),
                        usernameSlug: ""
                    )
                )

                return tokenDTO.role == 0 ? UserRole.user : UserRole.courtOwner
            }
            .eraseToAnyPublisher()
    }
}

struct TokenDTO: Codable {
    let token: String
    let id: String
    let role: Int
}
