import Foundation
import Combine

enum RestoreSessionError: Error {
    case emptySession
}

protocol SessionProvidable {
    var session: SessionType? { get }
}

protocol RefreshSessionOperable: AnyObject, SessionProvidable {
    func refreshSession(completion: @escaping (Result<Void, Error>) -> Void)
}

protocol SessionOperable: RefreshSessionOperable {
    func restoreSession() -> Future<SessionType, Error>
    func saveSession(session: SessionType?) -> Future<Void, Error>
    func clearSession() -> Future<Void, Error>

    func save(email: String?)
    func restoreEmail() -> String?
}

final class SessionService: SessionOperable {
    struct Service {
        let keychainService: KeychainProvidable
        let appDefaultsService: UserDefaultsProvidable
    }

    private(set) var session: SessionType?

    private let keychainConfiguration: KeychainConfiguration
    private let service: Service

    static let kEmail = "last_used_email"

    init(
        service: Service,
        keychainConfiguration: KeychainConfiguration
    ) {
        self.keychainConfiguration = keychainConfiguration
        self.service = service
    }

    func restoreSession() -> Future<SessionType, Error> {
        .init { [weak self] promise in
            guard let self = self else { return }
            let keychain = self.service.keychainService
            let configuration = self.keychainConfiguration

            guard let accessToken = keychain[configuration.accessTokenKey],
                  let uuid = keychain[configuration.uuidKey],
                let username = keychain[configuration.usernameKey],
                let refreshToken = keychain[configuration.refreshTokenKey],
                let expiresDateString = keychain[configuration.expiresKey],
                let slug = keychain[configuration.usernameSlug],
                let milliseconds = TimeInterval(expiresDateString)
            else {
                promise(.failure(RestoreSessionError.emptySession))
                return
            }

            let expiresDate = Date(timeIntervalSince1970: milliseconds)
            let session = Session(
                uuid: uuid,
                username: username,
                accessToken: accessToken,
                refreshToken: refreshToken,
                expiryDate: expiresDate,
                refreshTokenExpiryDate: expiresDate,
                usernameSlug: slug
            )
            self.session = session
            promise(.success(session))
        }
    }

    func saveSession(session: SessionType?) -> Future<(), Error> {
        .init { [weak self] promise in
            guard let self = self else { return }
            guard let session = session else {
                promise(.failure(RestoreSessionError.emptySession))
                return
            }
            promise(.success(self.save(session: session)))
        }
    }

    private func save(session: SessionType) {
        var keychain = service.keychainService
        let configuration = keychainConfiguration

        keychain[configuration.uuidKey] = session.uuid
        keychain[configuration.accessTokenKey] = session.accessToken
        keychain[configuration.refreshTokenKey] = session.refreshToken
        keychain[configuration.usernameKey] = session.username
        keychain[configuration.usernameSlug] = session.usernameSlug
        keychain[configuration.expiresKey] = String(session.expiryDate.timeIntervalSince1970)

        self.session = session
    }

    func clearSession() -> Future<(), Error> {
        .init { [weak self] promise in
            do {
                try self?.service.keychainService.removeAll()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
    }

    func save(email: String?) {
        service.appDefaultsService.set(email, forKey: type(of: self).kEmail)
    }

    func restoreEmail() -> String? {
        service.appDefaultsService.string(forKey: type(of: self).kEmail)
    }

    func refreshSession(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let _ = self.session else {
            completion(.failure(RestoreSessionError.emptySession))
            return
        }
        // TODO:- Implement refresh session request
        completion(.success(()))
    }
}

enum SessionServiceError: Error {
    case noSession
}
