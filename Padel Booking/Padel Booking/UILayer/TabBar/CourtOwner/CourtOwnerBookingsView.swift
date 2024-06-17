import SwiftUI
import Combine

struct CourtOwnerBookingsView: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @StateObject var viewModel = ViewModel()
    @State var isAlertPresented = false
    let date: Date = .dateFrom(9, 5, 2023)
    let hourHeight = 50.0
    @State var isLoading = true
    
    var body: some View {
        VStack {
            HStack {
                Text("Hello, Courtowner")
                
                Spacer()
                
                Image(systemSymbol: .personCircleFill)
                    .font(.title)
                    .padding(.trailing, 30)
            }
            .padding(.top, safeAreaInsets.top + 10)
            .padding([.bottom, .leading])
            .background(Color("tabBarBackgroundColor"))
            
            courtAndDatePickerView
            
            Divider()
            
            calendarView
            
            Spacer()
            
        }
        .onAppear {
            if viewModel.courts.isEmpty {
                viewModel.getAllCourts()
            }
        }
        .ignoresSafeArea(edges: .top)
    }
    
    var courtAndDatePickerView: some View {

        GeometryReader { geometry in
            HStack {
                Menu(viewModel.selectedCourt?.name ?? "Select a court") {
                    ForEach(viewModel.courts, id: \.id) { court in
                        Button {
                            viewModel.selectedCourt = court
                        } label: {
                            Text(court.name)
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                                .frame(width: geometry.size.width / 2)
                        }
                    }
                }

                Spacer()

                DatePicker(
                    selection: $viewModel.selectedDate,
                    displayedComponents: .date) { }
                    .labelsHidden()
            }
        }
        .padding()
        .frame(maxHeight: 70)
    }

    func goToNextCourt() {
        guard let selectedCourt = viewModel.selectedCourt, let index = viewModel.courts.firstIndex(of: selectedCourt) else { return }
        let newIndex = (index + 1) % viewModel.courts.count
        withAnimation {
            viewModel.selectedCourt =  viewModel.courts[newIndex]
        }
    }

    func goToPreviousCourt() {
        guard let selectedCourt = viewModel.selectedCourt, let index = viewModel.courts.firstIndex(of: selectedCourt) else { return }
        let newIndex = (index - 1) % viewModel.courts.count
        withAnimation {
            viewModel.selectedCourt =  viewModel.courts[newIndex]
        }

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
                    
                    ForEach(viewModel.filteredBookings) { event in
                        eventCell(event)
                    }
                }
            }
            .gesture(DragGesture(
                minimumDistance: 50, coordinateSpace: .local
            )
                .onEnded { value in
                    // Determine swipe direction
                    if value.translation.width < 0 {
                        // Swiped left
                        goToNextCourt()
                    } else if value.translation.width > 0 {
                        // Swiped right
                        goToPreviousCourt()
                    }
                }
            )
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
                Text(event.username)
                    .foregroundColor(.white)
                Spacer()
                
                Menu {
                    if !event.isConfirmed {
                        Button {
                            viewModel.acceptBooking(booking: event)
                        } label: {
                            Label("Accept", systemImage: "checkmark")
                        }
                    }
                    
                    Button(role: .destructive) {
                        isAlertPresented = true
                    } label: {
                        Label("Cancel", systemImage: "trash")
                    }
                    Button {
                        
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }

                } label: {
                    Label("", systemImage: "ellipsis")
                        .foregroundColor(.white)
                }
            }
        }
        .alert(isPresented: $isAlertPresented) {
            Alert(
                title: Text("Booking Cancelation"),
                primaryButton: Alert.Button.destructive(
                    Text("Cancel the booking"),
                    action: { viewModel.removeBooking(booking: event) }
                ),
                secondaryButton: Alert.Button.default(Text("Dismiss"))
            )
        }
    }
}

struct CourtOwnerBookingsView_Previews: PreviewProvider {
    static var previews: some View {
        CourtOwnerBookingsView()
    }
}

protocol CourtOwnerBookingsVMDependencies {
    var cancelBookingUseCase: CancelBookingUseCase { get }
    var acceptBookingUseCase: AcceptBookingUseCase { get }
    var getAllCourtsUseCase: GetAllCourtsUseCase { get }
    var getAllPendingBookingsUseCase: GetAllPendingBookingsUseCase { get }
}

extension CourtOwnerBookingsView {
    final class ViewModel: ObservableObject {
        let dependencies: CourtOwnerBookingsVMDependencies
        @Published var courts = [Court]()
        @Published var isLoading = false
        @Published var errorDescription: String?
        private var subscribers = Set<AnyCancellable>()
        @Published var selectedCourt: Court?
        @Published var selectedDate = Date()
        @Published var allBookings = [Booking]()

        var filteredBookings: [Booking] {
            var bookings = allBookings.filter {
                $0.startDate.hasSameDayAs(selectedDate)
            }

            if let selectedCourt {
                bookings = bookings.filter { $0.courtId == selectedCourt.id }
            }

            return bookings
        }

        init(dependencies: CourtOwnerBookingsVMDependencies = AppDependenciesContainer.shared) {
            self.dependencies = dependencies
        }
        
        func removeBooking(booking: Booking) {
            dependencies.cancelBookingUseCase.cancel(booking: booking)
        }
        
        func acceptBooking(booking: Booking) {
            dependencies.acceptBookingUseCase.accept(booking)
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

                    self?.allBookings = courts
                        .map { $0.bookings }
                        .flatMap { $0 }

                }
                .store(in: &subscribers)
        }
    }
}
