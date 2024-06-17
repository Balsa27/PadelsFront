import SwiftUI
import UIKit
import Combine

struct CourtDetailsView: View {

    @StateObject var viewModel: ViewModel
    private let numberFormatter: NumberFormatter
    @EnvironmentObject var  appState: AppState
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @Environment(\.dismiss) var dismiss
    @State var isEditing = false

    var isCreatingACourt: Bool { viewModel.court.id.isEmpty || viewModel.court.id == Court.emptyCourt.id  }

    init(court: Court? = nil) {
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.maximumFractionDigits = 2
        _viewModel = StateObject(wrappedValue: ViewModel(court: court))
        if court == nil {
            isEditing = true
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                HStack {
                    Text(isCreatingACourt ? "Create a court" : "Update court")
                        .font(.largeTitle)
                        .bold()
                    
                    Spacer()
                    
                    if !isCreatingACourt {
                        Button(isEditing ? "Cancel" : "Edit") {
                            withAnimation {
                                isEditing.toggle()
                            }
                        }
                        .foregroundStyle(isEditing ? .red : .blue)
                        .padding()
                    }
                }
                .padding(.top, safeAreaInsets.top/3)
                .padding([.bottom, .leading])
                .background(Color("tabBarBackgroundColor"))
            }
            VStack {
                Form {

                    Section {
                        courtInformationView
                    } header: {
                        Text("Court Information")
                    }

                    Section {
                        locationPickerView
                    } header: {
                        Text("Location")
                    }

                    Section {
                        timePickerView
                    } header: {
                        Text("Working hours")
                    }

                    Section {
                        pricePickerView
                    } header: {
                        Text("Pricing")
                    }
                }
                Button(action: viewModel.createACourt, label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text(isCreatingACourt ? "Create a court!" : "Submit")
                    }
                })
                    .buttonStyle(
                        PrimaryButtonStyle(
                            backgroundColor: Color("primaryGreen").opacity(viewModel.isLoading ? 0.5 : 1)
                        )
                    )
                    .disabled(viewModel.isLoading)
                    .padding()
            }
        }
        .onChange(of: viewModel.inputErrorDescription, { _, newValue in
            if let newValue {
                appState.showToast(withMessage: newValue, forError: true)
            }
        })
        .onChange(of: viewModel.successMessage, { _, newValue in
            if let newValue {
                appState.showToast(withMessage: newValue)
                dismiss()
            }
        })
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
    var courtInformationView: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Court name")
                TextField("", text: $viewModel.court.name)
                    .placeholder(when: viewModel.court.name.isEmpty, placeholder: {
                        Text("Court name")
                            .foregroundStyle(.gray.opacity(0.5))
                    })
                    .frame(height: 55)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 4)
                    .cornerRadius(12)
                    .overlay(isEditing ? RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.5)) : nil)
                    .foregroundColor(.black)
                    .disabled(!isEditing && !isCreatingACourt)
            }
            .padding(.vertical)
            
            VStack(alignment: .leading) {
                Text("Court description")
                TextField("", text: $viewModel.court.description, axis: .vertical)
                    .placeholder(when: viewModel.court.description.isEmpty, placeholder: {
                        Text("Description")
                            .foregroundStyle(.gray.opacity(0.5))
                    })
                    .frame(minHeight: 55)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 4)
                    .cornerRadius(12)
                    .overlay(isEditing ? RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.5)) : nil)
                    .foregroundColor(.black)
                    .lineLimit(15)
                    .disabled(!isEditing && !isCreatingACourt)
            }
            .padding(.bottom)
        }
    }
    
    var locationPickerView: some View {
        Group {
            if isEditing || viewModel.court.location != Court.emptyCourt.location {
                VStack(alignment: .leading, spacing: 12) {
                    TextField(
                        "Street name",
                        text: Binding(get: { viewModel.court.location.street }, set: { newValue, _ in
                            viewModel.court.location.street = newValue
                        })
                    )
                    .disabled(!isEditing && !isCreatingACourt)

                    TextField(
                        "City",
                        text: Binding(get: { viewModel.court.location.city}, set: { newValue, _ in
                            viewModel.court.location.city = newValue
                        })
                    )
                    .disabled(!isEditing && !isCreatingACourt)

                    TextField(
                        "State",
                        text: Binding(get: { viewModel.court.location.state}, set: { newValue, _ in
                            viewModel.court.location.state = newValue
                        })
                    )
                    .disabled(!isEditing && !isCreatingACourt)

                    TextField(
                        "Country",
                        text: Binding(get: { viewModel.court.location.country}, set: { newValue, _ in
                            viewModel.court.location.country = newValue
                        })
                    )
                    .disabled(!isEditing && !isCreatingACourt)

                    TextField(
                        "ZipCode",
                        text: Binding(get: { viewModel.court.location.zipCode}, set: { newValue, _ in
                            viewModel.court.location.zipCode = newValue
                        })
                    )
                    .disabled(!isEditing && !isCreatingACourt)

                }
                .padding(.vertical)
            } else {
                NavigationLink(
                    destination: CourtLocationPickerView(
                        courtLocation: Binding(get: {
                            viewModel.court.location
                        }, set: { newValue, _ in
                            if let newValue {
                                viewModel.court.location = newValue
                            }
                        })),
                    label: {
                        Text("Location")
                    }
                )
                .padding(.vertical)
            }
        }
    }
    
    var timePickerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Start of working time:")
            HourMinutePicker(
                hourSelection: $viewModel.court.workingTime.startTimeHours,
                minuteSelection: $viewModel.court.workingTime.startTimeMinutes,
                isEditing: Binding(get: { isEditing || isCreatingACourt }, set: { _ in })
            )
            .disabled(!isEditing && !isCreatingACourt)

            Text("End of working time:")
            HourMinutePicker(
                hourSelection: $viewModel.court.workingTime.endTimeHours,
                minuteSelection: $viewModel.court.workingTime.endTimeMinutes,
                isEditing: Binding(get: { isEditing || isCreatingACourt }, set: { _ in })
            )
            .disabled(!isEditing && !isCreatingACourt)

        }
        .padding(.vertical)
        .frame(minHeight: (isEditing || isCreatingACourt) ? 300 : nil)
    }
    
    var pricePickerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Price per hour:")
            TextField("0.00€", value: $viewModel.court.prices.first!.price, format: .currency(code: Locale.current.currency?.identifier ?? "EUR"))
                .disabled(!isEditing || !isCreatingACourt)

            Text("Price per hour and a half:")
            TextField("0.00€", value: $viewModel.court.prices[1].price, format: .currency(code: Locale.current.currency?.identifier ?? "EUR"))
                .disabled(!isEditing || !isCreatingACourt)
        }
        .padding(.vertical)
        .frame(minHeight: 150)
    }
}

#Preview {
    NavigationStack {
        CourtDetailsView()
    }
}

protocol CreateACourtVMDependencies {
    var createACourtUseCase: CreateACourtUseCase { get }
}

extension CourtDetailsView {
    final class ViewModel: ObservableObject {

        let dependencies: CreateACourtVMDependencies

        init(
            dependencies: CreateACourtVMDependencies = AppDependenciesContainer.shared,
            court: Court? = nil
        ) {
            self.dependencies = dependencies
            if let court {
                self.court = court
            }
        }

        //MARK: - State handling

        @Published var isLoading = false
        @Published var inputErrorDescription: String?
        @Published var successMessage: String?

        @Published var court: Court = .emptyCourt

        private var subscribers = Set<AnyCancellable>()

        func createACourt() {
            guard isValidInput(), court != .emptyCourt else { return }

            isLoading = true
            dependencies.createACourtUseCase.addCourt(court)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.isLoading = false
                    if let apiError = error as? APIError, case .unknown(let reason) = apiError {
                        self?.inputErrorDescription = reason
                    } else {
                        self?.inputErrorDescription = error.localizedDescription
                    }
                }
            } receiveValue: { [weak self] successMessage in
                self?.successMessage = successMessage
                self?.isLoading = false
            }
            .store(in: &subscribers)
        }

        func isValidInput() -> Bool {
            guard !court.name.isEmpty, !court.location.street.isEmpty, !court.prices.isEmpty else {
                inputErrorDescription = "Please fill in all the fields"
                return false
            }

            return true

        }
    }
}

extension Court {
    static var emptyCourt: Court {
        Court(
            id: "",
            name: "",
            description: "",
            location: CourtLocation(street: "", city: "", state: "", country: "", zipCode: ""),
            prices: [
                CourtPricing(price: 20, duration: 1, timeSpan: CourtTimeSpan(startTimeHours: 6, startTimeMinutes: 0, endTimeHours: 24, endTimeMinutes: 0)),
                CourtPricing(price: 24, duration: 1.5, timeSpan: CourtTimeSpan(startTimeHours: 6, startTimeMinutes: 0, endTimeHours: 24, endTimeMinutes: 0))
        ],
            status: .working,
            workingTime: CourtTimeSpan(startTimeHours: 6, startTimeMinutes: 0, endTimeHours: 24, endTimeMinutes: 0),
            bookings: []
        )
    }
}
