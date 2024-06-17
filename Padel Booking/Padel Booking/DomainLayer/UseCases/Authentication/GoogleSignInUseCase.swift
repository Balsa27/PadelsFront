import Foundation
import Combine

protocol GoogleSignInUseCase{
    func googleSignIn(googleToken: String, pushToken: String? = null) -> AnyPublisher<UserRole, Error>
}
