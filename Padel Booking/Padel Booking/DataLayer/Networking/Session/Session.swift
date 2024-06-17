import Foundation

protocol SessionType {
    var uuid: String { get }
    var username: String { get }
    var accessToken: String { get }
    var refreshToken: String { get }
    var expiryDate: Date { get }
    var hasExpired: Bool { get }
    var usernameSlug: String { get }
    var hasRefreshTokenExpired: Bool { get }
}

struct Session: SessionType {
    private let lock = NSLock()
    public let uuid: String
    public let username: String
    private let accessTokenValue: String
    private let refreshTokenValue: String
    private let expiryDateValue: Date
    private let refreshTokenExpiryDateValue: Date
    private let usernameSlugValue: String

    init(
        uuid: String,
        username: String,
        accessToken: String,
        refreshToken: String,
        expiryDate: Date,
        refreshTokenExpiryDate: Date,
        usernameSlug: String
    ) {
        self.uuid = uuid
        self.accessTokenValue = accessToken
        self.refreshTokenValue = refreshToken
        self.username = username
        self.expiryDateValue = expiryDate
        self.refreshTokenExpiryDateValue = refreshTokenExpiryDate
        self.usernameSlugValue = usernameSlug
    }

    var accessToken: String {
        lock.lock()
        defer { lock.unlock() }

        return accessTokenValue
    }

    var refreshToken: String {
        lock.lock()
        defer { lock.unlock() }

        return refreshTokenValue
    }

    var expiryDate: Date {
        lock.lock()
        defer { lock.unlock() }

        return expiryDateValue
    }

    var refreshTokenExpiryDate: Date {
        lock.lock()
        defer { lock.unlock() }

        return refreshTokenExpiryDateValue
    }

    var hasExpired: Bool {
        expiryDate.compare(Date()) != .orderedDescending
    }

    var hasRefreshTokenExpired: Bool {
        refreshTokenExpiryDateValue.compare(Date()) != .orderedDescending
    }

    var usernameSlug: String {
        lock.lock()
        defer { lock.unlock() }

        return usernameSlugValue
    }
}
