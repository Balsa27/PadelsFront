import Foundation
import KeychainAccess
import Foundation

protocol KeychainConfiguration {
    var service: String { get }
    var accessTokenKey: String { get }
    var refreshTokenKey: String { get }
    var expiresKey: String { get }
}

extension KeychainConfiguration {
    var service: String { Bundle.main.bundleIdentifier ?? "PadelBookingApp" }
    var accessTokenKey: String { "session_access_token" }
    var refreshTokenKey: String { "session_refresh_token" }
    var usernameKey: String { "username_key" }
    var uuidKey: String { "session_uuid" }
    var expiresKey: String { "session_expires_in" }
    var usernameSlug: String { "username_slug" }
}

struct DefaultKeychainConfiguration: KeychainConfiguration { }

protocol KeychainProvidable {
    var service: String { get }

    subscript(key: String) -> String? { get set }

    func removeAll() throws
}

extension Keychain: KeychainProvidable {}
