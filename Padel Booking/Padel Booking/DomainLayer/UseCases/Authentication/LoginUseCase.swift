import Foundation
import Combine

protocol LoginUseCase {
    func login(email username: String, password: String) -> AnyPublisher<UserRole, Error>
}
