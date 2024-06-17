import Foundation
import KeychainAccess

final class AppDependenciesContainer: CourtOwnerBookingsVMDependencies, CourtOwnerRequestsVMDependencies, BookACourtVMDependencies, UserBookingsDetailVMDependencies, LoginVMDependencies, SignUpVMDependencies, CreateACourtVMDependencies, CourtsListVMDependencies, UserBookingsVMDependencies  {

    static let shared = AppDependenciesContainer()

    //MARK: - Foundation Blocks
    let sessionService: SessionOperable = SessionService(
        service: SessionService.Service(
            keychainService: Keychain(),
            appDefaultsService: UserDefaults.appGroupDefaults
        ),
        keychainConfiguration: DefaultKeychainConfiguration()
    )
    
    lazy var webService: WebService = NetworkingService(sessionProvider: sessionService)

    //MARK: - Bookings



    //MARK: - Authentication
    lazy var authProvider = AuthenticationProvider(webService: webService, sessionService: sessionService, userDefaults: UserDefaults.appGroupDefaults)
    
    lazy var googleSignInUseCase: GoogleSignInUseCase = authProvider
    lazy var loginUseCase: LoginUseCase = authProvider
    lazy var signUpUseCase: SignUpUseCase = authProvider
    
    //MARK: - Court Management
    lazy var updateCourtProvider = UpdateCourtProvider(webService: webService)
    lazy var courtsProvider = CourtsProvider(webService: webService)

    lazy var createACourtUseCase: CreateACourtUseCase = updateCourtProvider
    lazy var getAllCourtsUseCase: GetAllCourtsUseCase = courtsProvider

    lazy var courtOwnerBookingsProvider = CourtOwnerBookingProvider(webService: webService)

    lazy var getAllPendingBookingsUseCase: GetAllPendingBookingsUseCase = courtOwnerBookingsProvider

    lazy var cancelBookingUseCase: CancelBookingUseCase = courtOwnerBookingsProvider

    lazy var acceptBookingUseCase: AcceptBookingUseCase = courtOwnerBookingsProvider

    lazy var rejectBookingsUseCase: RejectBookingUseCase = courtOwnerBookingsProvider

    lazy var createBookingUseCase: CreateABookingUseCase = courtOwnerBookingsProvider

    lazy var editBookingUseCase: EditBookingUseCase = courtOwnerBookingsProvider

}
