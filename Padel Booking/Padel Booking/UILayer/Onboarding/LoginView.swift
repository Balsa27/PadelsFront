import SwiftUI
import Combine

struct LoginView: View {
    @State private var isForgotPasswordViewPresented = false
    @StateObject var viewModel = ViewModel()
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            // Use the image as a background
            Image("court")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .scaledToFill()
                .blur(radius: 1) // Apply a blur effect to the background
            VStack(spacing: 20) {
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Welcome!")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12)
                    Text("Enhanced padel experience. Only a couple of clicks away!")
                        .font(.subheadline)
                        .fontWeight(.regular)
                        .padding(.horizontal, 12)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10) // Increased side padding
                .padding(.vertical)
                .background(Color.black.opacity(0.25)) // Dark gray semi-transparent background
                .cornerRadius(20)
                .padding(.horizontal, 40) // This ensures that the blur effect is visible around the edges
                .padding(.bottom, 60)
                
                contentView
                    .padding(.horizontal, 10) // Increased side padding
                    .background(Color.black.opacity(0.25)) // Dark gray semi-transparent background
                    .cornerRadius(20)
                    .padding(.horizontal, 50) // This ensures that the blur effect is visible around the edges
            }
            .padding()
        }
        .fullScreenCover(isPresented: $isForgotPasswordViewPresented) {
            ForgotPasswordView()
        }
        .onChange(of: viewModel.errorDescription) { oldValue, newValue in
            if let newValue {
                appState.showToast(withMessage: newValue, forError: true)
            }
        }
        .navigationDestination(item: $viewModel.userRole, destination: { userRole  in
            switch userRole {
            case .user:
                UserTabBarView()
            case .courtOwner:
                CourtOwnerTabBarView()
            }
        })
    }
    
    var contentView: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                AnimatedTextField(
                    placeholder: "Enter your username or email", text: $viewModel.usernameOrEmail)
                
                AnimatedSecureTextField(placeholder: "Password", text: $viewModel.password)
                Text("Forgot your password?")
                    .font(.caption)
                    .underline()
                    .foregroundColor(.green.opacity(0.7))
                    .onTapGesture {
                        isForgotPasswordViewPresented = true
                    }
                    .padding(.top, 8.0)
            }
            .padding(.bottom)

            Button(action: viewModel.login) {
                Group {
                    if viewModel.isLoading {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Login")
                    }
                }
            }
            .buttonStyle(PrimaryButtonStyle(backgroundColor: Color("primaryGreen").opacity(viewModel.isLoading ? 0.5 : 1)))
            .disabled(viewModel.isLoading)
            
            VStack(alignment: .center) {

                
                NavigationLink {
                    SignUpView()
                } label: {
                    HStack {
                        Spacer()
                        Text("Don't have an account yet?")
                            .foregroundStyle(.white)
                        Text("Sign up")
                            .underline()
                            .foregroundColor(.green.opacity(0.7))
                        Spacer()
                    }
                }
            }
        }
        .padding()
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

protocol LoginVMDependencies {
    var loginUseCase: LoginUseCase { get }
}

extension LoginView {
    final class ViewModel: ObservableObject {
        let dependencies: LoginVMDependencies
        @Published var isLoading = false
        @Published var usernameOrEmail = ""
        @Published var password = ""
        var loginSubscriber: AnyCancellable? = nil
        @Published var errorDescription: String?
        @Published var userRole: UserRole?

        init(dependencies: LoginVMDependencies = AppDependenciesContainer.shared) {
            self.dependencies = dependencies
        }
        
        func login() {
            isLoading = true
            loginSubscriber = dependencies.loginUseCase.login(email: usernameOrEmail, password: password)
                .sink(receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        if let _ = self?.errorDescription {
                            self?.errorDescription = nil
                        }
                        if let apiError = error as? APIError, case .unknown(let reason) = apiError {
                            self?.errorDescription = reason
                        } else {
                            self?.errorDescription = error.localizedDescription
                        }
                    }
                }, receiveValue: { [weak self] userRole in
                    self?.userRole = userRole
                    self?.isLoading = false
                })
        }
    }
}
