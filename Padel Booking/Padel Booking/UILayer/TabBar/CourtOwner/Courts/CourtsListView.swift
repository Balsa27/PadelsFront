import SwiftUI
import Combine

struct CourtsListView: View {
    @State var isCreateCourtViewPresented = false
    @EnvironmentObject var  appState: AppState
    @StateObject var viewModel = ViewModel()

    var body: some View {
        VStack {
            if !viewModel.courts.isEmpty {
                courtListView

                Spacer()

                NavigationLink(destination: {
                    CourtDetailsView()
                }) {
                    Text("Create another court")
                        .padding()
                }
            } else {
                noCourtsView
            }
        }
        .onAppear(perform: viewModel.getAllCourts)
        .onChange(of: viewModel.errorDescription) { _, newValue in
            if let newValue {
                appState.showToast(withMessage: newValue, forError: true)
            }
        }
    }

    var courtListView: some View {
        List(viewModel.courts) { court in
            NavigationLink {
                CourtDetailsView(court: court)
            } label: {
                HStack {
                    Text(court.name)
                        .padding(.vertical)
                }
            }
        }
        .listStyle(PlainListStyle())
    }

    var noCourtsView: some View {
        ContentUnavailableView {
            Label("No courts created yet!", systemImage: "")
        } description: {
            Text("")
        } actions: {
            NavigationLink(destination: {
                CourtDetailsView()
            }) {
                Text("Create your first court")
            }
        }
    }
}

#Preview {
    NavigationStack {
        CourtsListView()
    }
}

protocol CourtsListVMDependencies {
    var getAllCourtsUseCase: GetAllCourtsUseCase { get }
}

extension CourtsListView {
    final class ViewModel: ObservableObject {
        let dependencies: CourtsListVMDependencies

        init(dependencies: CourtsListVMDependencies = AppDependenciesContainer.shared) {
            self.dependencies = dependencies
            self.isLoading = isLoading
            self.courts = courts
        }

        //MARK: - State and Data management
        @Published var isLoading = false
        @Published var courts = [Court]()
        @Published var errorDescription: String?

        private var subscribers = Set<AnyCancellable>()

        func getAllCourts() {
            isLoading = true

            dependencies.getAllCourtsUseCase.getAllCourts()
                .sink { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        if let apiError = error as? APIError, case .unknown(let reason) = apiError {
                            self?.errorDescription = reason
                        } else {
                            self?.errorDescription = error.localizedDescription
                        }
                    }
                } receiveValue: { [weak self] courts in
                    self?.courts = courts
                    self?.isLoading = false
                }
                .store(in: &subscribers)
        }
    }
}
