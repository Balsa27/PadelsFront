import Foundation
import Combine

protocol SignUpUseCase {
    func signUp(email: String, username: String, pushToken: String) -> AnyPublisher<Void, Error>
}
