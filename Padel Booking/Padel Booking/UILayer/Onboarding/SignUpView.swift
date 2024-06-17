import SwiftUI
import Combine

struct SignUpView: View {
    @EnvironmentObject var googleSignInManager: GoogleSignInManager
    @StateObject var viewModel = ViewModel()

    var body: some View {
        ZStack {
            Image("court")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .scaledToFill()
                .blur(radius: 1) // Apply a blur effect to the background
            contentView
                .onChange(of: viewModel.errorDescription) { _, newValue in
                    if let newValue {
                        appState.showToast(withMessage: newValue, forError: true)
                    }
                }
        }
        .navigationDestination(isPresented: $viewModel.hasCompletedSignUp) {
            UserTabBarView()
        }
        .navigationTitle(
            Text("Welcome!")
                .foregroundStyle(.white)
        )
    }

    var contentView: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 15) {
                AnimatedTextField(placeholder: "Email", text: $viewModel.email)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)

                AnimatedTextField(placeholder: "Username", text: $viewModel.username)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                AnimatedSecureTextField(placeholder: "Password", text: $viewModel.password)
                AnimatedSecureTextField(placeholder: "Repeat password", text: $viewModel.repeatPassword)

                Button(action: viewModel.signup) {
                    Group {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .tint(.white)
                        } else {
                            Text("Sign up")
                        }
                    }
                }
                .buttonStyle(PrimaryButtonStyle(backgroundColor: Color("primaryGreen").opacity(viewModel.isLoading ? 0.5 : 1)))

                Button("Sign in with Google") {
                    viewModel.initiateGoogleSignIn()
                }
                .buttonStyle(PrimaryButtonStyle(backgroundColor: Color.red.opacity(googleSignInManager.isSignedIn ? 0.5 : 1)))

                NavigationLink {
                    LoginView()
                } label: {
                    HStack {
                        Text("Already have an account?")
                            .foregroundStyle(.white)
                        Text("Log in")
                            .underline()
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(.horizontal, 20) // Increased side padding
            .padding(.vertical, 40)
            .background(Color.black.opacity(0.25)) // Dark gray semi-transparent background
            .cornerRadius(20)
            .padding(.horizontal, 40) // This ensures that the blur effect is visible around the edges
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView().environmentObject(GoogleSignInManager())
    }
}


protocol SignUpVMDependencies {
    var signUpUseCase: SignUpUseCase { get }
    var googleSignInUseCase: GoogleSignInUseCase { get }
}

extension SignUpView {
    class ViewModel: ObservableObject {
        let dependencies: SignUpVMDependencies

        @Published var email: String = ""
        @Published var username: String = ""
        @Published var password: String = ""
        @Published var repeatPassword: String = ""

        @Published var isLoading = false
        @Published var errorDescription: String?
        @Published var hasCompletedSignUp = false

        private var cancellables = Set<AnyCancellable>()

        init(dependencies: SignUpVMDependencies) {
            self.dependencies = dependencies
        }

        func signup() {
            guard password == repeatPassword else {
                errorDescription = "Passwords do not match. Please try again."
                return
            }

            guard email.isValidEmail() else {
                errorDescription = "Email format is invalid. Please change it and try again."
                return
            }

            isLoading = true
            dependencies.signUpUseCase.signUp(email: email, username: username, password: password)
                .sink(receiveCompletion: { [weak self] completion in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        if case .failure(let error) = completion {
                            self?.errorDescription = error.localizedDescription
                        }
                    }
                }, receiveValue: { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.hasCompletedSignUp = true
                        self?.isLoading = false
                    }
                })
                .store(in: &cancellables)
        }

        func initiateGoogleSignIn() {
            guard !isLoading else { return }
            isLoading = true
            errorDescription = nil
            googleSignInManager.signIn()
        }
    }
}

class GoogleSignInManager: ObservableObject {
    @Published var isSignedIn = false
    @Published var errorDescription: String?
    var googleSignInUseCase: GoogleSignInUseCase?

    func signIn() {
        guard let clientID = GIDSignIn.sharedInstance().clientID else {
            errorDescription = "Google Client ID not set"
            return
        }

        GIDSignIn.sharedInstance().signIn(withConfiguration: GIDConfiguration(clientID: clientID), presenting: UIApplication.shared.windows.first!.rootViewController!) { [weak self] user, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorDescription = error.localizedDescription
                    return
                }

                guard let authentication = user?.authentication, let idToken = authentication.idToken else {
                    self?.errorDescription = "Failed to authenticate with Google."
                    return
                }

                self?.sendTokenToBackend(idToken: idToken)
            }
        }
    }

    private func sendTokenToBackend(idToken: String) {
        googleSignInUseCase?.googleSignIn(googleToken: idToken, pushToken: null)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    DispatchQueue.main.async {
                        self?.errorDescription = error  .localizedDescription
                    }
                }
            }, receiveValue: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.isSignedIn = true
                }
            })
            .store(in: &cancellables)
    }
}
