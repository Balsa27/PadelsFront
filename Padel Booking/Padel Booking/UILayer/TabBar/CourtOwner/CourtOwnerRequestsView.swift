import SwiftUI
import Combine

struct CourtOwnerRequestsView: View {
    @StateObject var viewModel = ViewModel()
    @Environment(\.safeAreaInsets) private var safeAreaInsets

    var body: some View {
        VStack {
            HStack(spacing: 20) {
                Text("Upcoming Requests")
                
                Spacer()

                Menu {
                    Section("Group by: ") {
                        if viewModel.grouping == .byDate {
                            Button {
                                withAnimation {
                                    viewModel.grouping = .byCourt
                                }
                            }
                        label: {
                            Label("Court", systemSymbol: .tennisRacket)
                        }
                        } else {
                            Button {
                                withAnimation {
                                    viewModel.grouping = .byDate
                                }}
                        label: {
                            Label("Date", systemSymbol: .calendar)
                        }
                        }
                    }

                } label: {
                    Label("", systemSymbol: .line3Horizontal)
                }
            }
            .padding(.top, safeAreaInsets.top + 10)
            .padding([.bottom, .leading, .trailing])
            .background(Color("tabBarBackgroundColor"))
            
            courtAndDatePickerView
            
            if viewModel.grouping == .byCourt {
                courtGroupedRequestsList
            } else {
                dateGroupedRequestsList
            }
        }
        .refreshable(action: { viewModel.getAllCourts() })
        .ignoresSafeArea(edges: .top)
        .onAppear {
            if viewModel.courts.isEmpty {
                viewModel.getAllCourts()
            }
        }
    }
    
    var courtAndDatePickerView: some View {
        HStack {

            if viewModel.grouping == .byDate {
                Menu(viewModel.selectedCourt?.name ?? "Select a court") {
                    if let _ = viewModel.selectedCourt {
                        Button("All courts") {
                            withAnimation {
                                viewModel.selectedCourt = nil
                            }
                        }
                    }
                    ForEach(viewModel.courts, id: \.self) { court in
                        Button {
                            viewModel.selectedCourt = court
                        } label: {
                            Label(court.name, systemSymbol: courtHasUnconfirmedBookings(court) ? .tennisballCircle : nil )
                                .lineLimit(1)
                            //                                if ! {
                            //                                    Text("\(viewModel.bookings.filter { $0.courtId == court.id && !$0.isConfirmed }.count)")
                            //                                }
                        }
                    }
                    //                        .onAppear { print("COURT \(court.name) COUNT OF UNCONFIRMED \(viewModel.bookings.filter { $0.courtId == court.id && !$0.isConfirmed }.count)") }
                }
            } else {

                if viewModel.shouldUseDateFiltering {
                    DatePicker(
                        selection: $viewModel.selectedDate,
                        in: Date()...,
                        displayedComponents: .date) { }
                        .labelsHidden()
                } else {
                    Button("Select a date") {
                        withAnimation {
                            viewModel.shouldUseDateFiltering = true
                        }
                    }
                }
            }

            Spacer()
        }
        .padding()
    }

    var courtGroupedRequestsList: some View {
        List {
            ForEach(viewModel.filteredCourtGroupedBookings.reversed(), id: \.courtId) { section in
                Section(header: Text(viewModel.courts.first(where: { $0.id ==  section.courtId })?.name ?? "Court" )) {
                    ForEach(section.bookings) { booking in
                        BookingCell(
                            booking: booking,
                            acceptAction: { _ in viewModel.acceptBooking(booking) },
                            rejectAction: { _ in viewModel.rejectBooking(booking) }
                        )
                        .listRowInsets(EdgeInsets())
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
    }

    var dateGroupedRequestsList: some View {
        List {
            ForEach(viewModel.filteredDateGroupedBookings.reversed(), id: \.date) { section in
                Section(header: Text(section.date.formatted(date: .abbreviated, time: .omitted))) {
                    ForEach(section.bookings) { booking in
                        BookingCell(
                            booking: booking,
                            acceptAction: { _ in viewModel.acceptBooking(booking) },
                            rejectAction: { _ in viewModel.rejectBooking(booking) }
                        )
                        .listRowInsets(EdgeInsets())
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
    }

    struct BookingCell: View {
        var booking: Booking
        let acceptAction: (Booking) -> Void
        let rejectAction: (Booking) -> Void

        var body: some View {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("Time: \(timeAndDateFormatter.string(from: booking.startDate)) to \(timeAndDateFormatter.string(from: booking.endDate))")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("Booked by: \(booking.username)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("Court ID: \(booking.courtId)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    Text("Date: \(dateFormatter.string(from: booking.startDate))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }


                HStack(spacing: 20) {
                    Button("Reject", action: { rejectAction(booking) } )
                        .buttonStyle(SecondaryButtonStyle(buttonHeight: 40, foregroundColor: .red))

                    Button("Accept", action: { acceptAction(booking) })
                        .buttonStyle(PrimaryButtonStyle(buttonHeight: 40))
                }
            }
            .padding()
        }

        private var timeAndDateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            return formatter
        }

        private var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter
        }
    }

    func courtHasUnconfirmedBookings(_ court: Court) -> Bool {
        !viewModel.bookings.filter({ $0.courtId == court.id && !$0.isConfirmed }).isEmpty
    }
}

struct CourtOwnerRequestsView_Previews: PreviewProvider {
    static var previews: some View {
        CourtOwnerRequestsView()
    }
}

protocol CourtOwnerRequestsVMDependencies {
    var acceptBookingUseCase: AcceptBookingUseCase { get }
    var rejectBookingsUseCase: RejectBookingUseCase { get }
    var getAllCourtsUseCase: GetAllCourtsUseCase { get }
}

extension CourtOwnerRequestsView {
    final class ViewModel: ObservableObject {
        
        let dependencies: CourtOwnerRequestsVMDependencies
        @Published var courts = [Court]()
        @Published var isLoading = false
        @Published var errorDescription: String?
        private var subscribers = Set<AnyCancellable>()
        @Published var selectedCourt: Court?
        @Published var selectedDate = Date()
        @Published var bookings = [Booking]()
        @Published var shouldUseDateFiltering = false
        @Published var grouping: Grouping = .byCourt

        
        struct CourtGroupedBookingSection {
            var courtId: String
            var bookings: [Booking]
        }

        struct DateGroupedBookingSection {
            var date: Date
            var bookings: [Booking]
        }


        enum Grouping {
            case byCourt
            case byDate
        }

        var filteredCourtGroupedBookings: [CourtGroupedBookingSection] {
            var _bookings = bookings

            if shouldUseDateFiltering {
                _bookings = bookings.filter { $0.startDate.hasSameDayAs(selectedDate) }
            }

            if let selectedCourt {
                _bookings = _bookings.filter { $0.courtId == selectedCourt.id }
            }


            let grouped = Dictionary(
                grouping: _bookings.sorted { $0.startDate > $1.startDate },
                by: \.courtId
            )

            return grouped.map { CourtGroupedBookingSection(courtId: $0.key, bookings: $0.value) }
        }

        var filteredDateGroupedBookings: [DateGroupedBookingSection] {
            var _bookings = bookings

            if shouldUseDateFiltering {
                _bookings = bookings.filter { $0.startDate.hasSameDayAs(selectedDate) }
            }

            if let selectedCourt {
                _bookings = _bookings.filter { $0.courtId == selectedCourt.id }
            }

            let grouped =  Dictionary(
                grouping: _bookings.sorted { $0.startDate > $1.startDate },
                by: \.startDate
            )

            return grouped.map { DateGroupedBookingSection(date: $0.key, bookings: $0.value) }
        }

        init(dependencies: CourtOwnerRequestsVMDependencies = AppDependenciesContainer.shared) {
            self.dependencies = dependencies
        }
        
        func acceptBooking(_ booking: Booking) {
            dependencies.acceptBookingUseCase.accept(booking)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print(error.localizedDescription)
                    }
                } receiveValue: { [weak self] _ in
                    if let index = self?.bookings.firstIndex(of: booking) {
                        self?.bookings.remove(at: index)
                    }
                }
                .store(in: &subscribers)
        }
        
        func rejectBooking(_ booking: Booking) {
            dependencies.rejectBookingsUseCase.reject(booking)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print(error.localizedDescription)
                    }
                } receiveValue: { [weak self] _ in
                    if let index = self?.bookings.firstIndex(of: booking) {
                        self?.bookings.remove(at: index)
                    }
                }
                .store(in: &subscribers)
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

                    self?.bookings = courts
                        .flatMap { $0.bookings }
                        .filter { $0.startDate >= Date() }
                }
                .store(in: &subscribers)
        }
    }
}
