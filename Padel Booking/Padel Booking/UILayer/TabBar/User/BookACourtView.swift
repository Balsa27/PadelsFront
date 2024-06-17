import SwiftUI
import Combine

struct BookACourtView: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = ViewModel()

    let hourHeight = 50.0
    @State var startTime: Date = Date().addingTimeInterval(3600)
    @State var endTime: Date = Date().addingTimeInterval(7200)
    @State var isDetailSheetPresented = false
    
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
            VStack {
                headerView
                
                courtAndDatePickerView
                
                calendarView
                
                Spacer()
            }
            .ignoresSafeArea(edges: .top)
            .onAppear {

            }
            
            Button {
                isDetailSheetPresented = true
            } label: {
                Image(systemSymbol: .plus)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
                    .background(Circle().fill(Color.gray.opacity(0.5)))
                    .shadow(radius: 10)
            }
            .offset(x: -20, y: -20)
        }
        .sheet(isPresented: $isDetailSheetPresented) {
            timePickerSheet
                .presentationDetents([.height(300)])
        }
        .onChange(of: viewModel.hasCompleted) { newValue in
            if newValue {
                withAnimation {
                    isDetailSheetPresented = false
                }
            }
        }
    }
    
    var headerView: some View {
        HStack {
            Text("Book a court")
            
            Spacer()
            
            Image(systemSymbol: .xmark)
                .font(.headline)
                .padding(.trailing, 30)
                .onTapGesture {
                    withAnimation {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        }
        .padding(.top, safeAreaInsets.top + 10)
        .padding([.bottom, .leading])
        .background(Color("tabBarBackgroundColor"))
    }
    
    var courtAndDatePickerView: some View {
        HStack {
            Menu(viewModel.selectedCourt?.name ?? "Select a court") {
                ForEach(viewModel.courts, id: \.self) { court in
                    Button {
                        viewModel.selectedCourt = court
                    } label: {
                        Text(court.name)
                    }
                }
            }
            .foregroundColor(Color("primaryGreen"))
            
            DatePicker(
                selection: $viewModel.selectedDate,
                displayedComponents: .date) { }
                .tint(Color("primaryGreen"))
        }
        .padding()
    }
    
    var calendarView: some View {
        VStack(alignment: .leading) {
            ScrollView(showsIndicators: false) {
                ZStack(alignment: .topLeading) {
                    
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(7..<24) { hour in
                            HStack {
                                Text("\(hour)")
                                    .font(.caption)
                                    .frame(width: 20, alignment: .trailing)
                                Color.gray
                                    .frame(height: 1)
                            }
                            .frame(height: hourHeight)
                        }
                    }
                    
//                    ForEach(bookingsInteractor.bookings.filter {
//                        $0.courtId == viewModel.selectedCourt?.id &&
//                        Calendar.current.isDate($0.startDate, inSameDayAs: viewModel.selectedDate)
//                    }) { event in
//                        eventCell(event)
//                    }
                }
            }
        }
        .padding()
    }
    
    func eventCell(_ event: Booking) -> some View {
        
        let duration = event.endDate.timeIntervalSince(event.startDate)
        let height = duration / 60 / 60 * hourHeight
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: event.startDate)
        let offset = Double(hour-7) * (hourHeight)
        
        
        return getCellForEvent(event)
            .font(.caption)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(4)
            .frame(height: height, alignment: .top)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("primaryGreen").opacity(event.isConfirmed ? 0.8 : 0.5))
            )
            .padding(.trailing, 30)
            .offset(x: 30, y: offset + 24)
        
    }
    
    func getCellForEvent(_ event: Booking) -> some View {
        VStack {
            HStack {
                Text("User \(Int.random(in: 1...100))")
                    .foregroundColor(.white)
                Spacer()
            }
        }
    }
    
    var timePickerSheet: some View {
        VStack(alignment: .leading, spacing: 20) {
            DatePicker(
                "Start time",
                selection: $startTime,
                in: Date.now...,
                displayedComponents: .hourAndMinute)
                .padding(.top)
                .tint(Color("primaryGreen"))
                .environment(\.locale, Locale.init(identifier: "en_GB"))
            
            DatePicker(
                "End time",
                selection: $endTime,
                in: startTime.addingTimeInterval(3600)...,
                displayedComponents: .hourAndMinute
            )
                .tint(Color("primaryGreen"))
                .environment(\.locale, Locale.init(identifier: "en_GB"))
            
            Spacer()
            
            
            Button {
                //TODO: ERROR HANDLING
                guard let court = viewModel.selectedCourt else { return }
                viewModel.createABooking(startTime: startTime, endTime: endTime, court: court)
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text("Confirm")
                }
            }
            .disabled(viewModel.isLoading)
            .buttonStyle(PrimaryButtonStyle(backgroundColor: Color("primaryGreen").opacity(viewModel.isLoading ? 0.5 : 1)))
            
            
            Spacer()
            
        }
        .padding()
        .toast($viewModel.toast)
    }
}

struct BookACourtView_Previews: PreviewProvider {
    static var previews: some View {
        BookACourtView()
    }
}

protocol BookACourtVMDependencies {
    var createBookingUseCase: CreateABookingUseCase { get }
    var getAllCourtsUseCase: GetAllCourtsUseCase { get }
}

extension BookACourtView {
    final class ViewModel: ObservableObject {
        let dependencies: BookACourtVMDependencies
        @Published var isLoading = false
        @Published var hasCompleted = false
        @Published var toast: Toast.State = .hide
        private var cancellable: AnyCancellable?
        @Published var courts = [Court]()
        @Published var errorDescription: String?
        private var subscribers = Set<AnyCancellable>()
        @Published var selectedCourt: Court?
        @Published var selectedDate = Date()


        init(dependencies: BookACourtVMDependencies = AppDependenciesContainer.shared) {
            self.dependencies = dependencies
        }
        
        func createABooking(startTime: Date, endTime: Date, court: Court) {
            isLoading = true
            
            let booking = Booking(
                courtId: court.id,
                userId: "",
                startDate: startTime,
                endDate: endTime,
                title: UUID().uuidString,
                isConfirmed: false
            )
            
            cancellable = dependencies.createBookingUseCase.create(booking)
                .sink { completion in
                    if case .failure = completion {
                        self.isLoading = false
                        self.toast = .show(.error("There's an overlap with an existing booking. Please choose another time."))
                    }
                } receiveValue: { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.hasCompleted = true
                        self.isLoading = false
                    }
                }
        }

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
                    if !courts.isEmpty {
                        self?.selectedCourt = self?.courts.first
                    }
                }
                .store(in: &subscribers)
        }
    }
}
