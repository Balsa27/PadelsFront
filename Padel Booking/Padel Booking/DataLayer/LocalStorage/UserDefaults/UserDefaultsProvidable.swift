import Foundation

protocol UserDefaultsProvidable: AnyObject {
    func object(forKey defaultName: String) -> Any?
    func string(forKey defaultName: String) -> String?
    func integer(forKey defaultName: String) -> Int
    func bool(forKey defaultName: String) -> Bool
    func dictionary(forKey defaultName: String) -> [String: Any]?
    func array(forKey defaultName: String) -> [Any]?
    func set(_ value: Any?, forKey defaultName: String)
    func removeObject(forKey defaultName: String)

    static var appGroupDefaults: UserDefaultsProvidable { get }
}

extension UserDefaults {
    struct Keys {
        static let profilePhotoURL = "PadelBooking.UserDefaults.profilePhotoURLKey"
        static let hasReadGuidelines = "PadelBooking.UserDefaults.HasReadChatGuidelines"
        static let notificationsID = "PadelBooking.UserDefaults.UserNotificationsID"
        static let fcmToken = "PadelBooking.UserDefaults.FirebaseMessagingToken"
        static let lastReadMessageTimetoken = "PadelBooking.UserDefaults.Chat.LastReadMessageTimeToken"
        static let userRole = "PadelBooking.UserDefaults.Chat.userRole"
        static let userEmail = "PadelBooking.UserDefaults.userEmail"

//        static func key(for notificationType: NotificationFilters) -> String {
//            return "PadelBooking.UserDefaults.\(notificationType.rawValue)"
//        }
    }
}

extension UserDefaults: UserDefaultsProvidable {
    static var appGroupDefaults: UserDefaultsProvidable {
        let suitName = "PadelBookingApp" // This needs to be changed to match staging and prod
        return UserDefaults(suiteName: suitName) ?? UserDefaults.standard
    }
}
