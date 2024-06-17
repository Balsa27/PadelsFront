import Foundation
import Combine

protocol GetAllCourtsUseCase {
    func getAllCourts() -> AnyPublisher<[Court], Error>
}
