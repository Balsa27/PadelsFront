import Foundation
import Combine

protocol CreateACourtUseCase {
    func addCourt(_ court: Court) -> AnyPublisher<String, Error>
}
