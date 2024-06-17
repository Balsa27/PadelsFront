import SwiftUI
import SkeletonUI
import Combine

struct UserBookingsView: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject var  appState: AppState
    @State var isBookingDetailsViewPresented = false
    @State var isBookACourtViewPresented = false
    @StateObject var viewModel = ViewModel()

    var bottomPadding: CGFloat {
        switch appState.toast {
        case .hide:
            return 10
        case .show:
            return 70
        }
    }

    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            VStack(alignment: .leading, spacing: 0) {
                headerView
                
                if viewModel.bookings.isEmpty {
                    ContentUnavailableView {
                        Label("No bookings", systemSymbol: .calendar)
                    } description: {
                        Text("Create your first booking!")
                    } actions: {
                        Button("Book a court") { isBookACourtViewPresented = true }
                            .buttonStyle(PrimaryButtonStyle(minWidth: 250))
                    }
                } else {
                    CustomSegmentedControl(selectedIndex: $viewModel.selectedHeaderIndex, titles: viewModel.headers)
                        .padding(.top)
                    bookingsList
                        .padding(.bottom, bottomPadding)
                }
                
                Spacer()
            }
            
            if !viewModel.bookings.isEmpty && appState.toast == .hide {
                Text("Book a court")
                    .primaryButtonTextStyle()
                    .padding()
                    .onTapGesture {
                        withAnimation {
                            isBookACourtViewPresented = true
                        }
                    }
            }
        }
        .ignoresSafeArea(edges: .top)
        .fullScreenCover(isPresented: $isBookACourtViewPresented) {
            BookACourtView()
        }
        .onAppear(perform: viewModel.getAllCourts)
    }

    var headerView: some View {
        HStack {
            Text("Hello, user")
            
            Spacer()
            
            Image(systemSymbol: .personCircleFill)
                .font(.title)
                .padding(.trailing, 30)
        }
        .padding(.top, safeAreaInsets.top + 10)
        .padding([.leading, .bottom])
        .background(Color("primaryGreen"))
        .foregroundColor(.white)
    }
    
    var bookingsList: some View {
        List {
            if !viewModel.filteredBookings.flatMap(\.bookings).filter({ $0.timeFrame == .upcoming }).isEmpty {
                Section(header: Text("Upcoming bookings: ")) {
                    ForEach(viewModel.filteredBookings) { section in
                        ForEach(section.bookings.filter { $0.timeFrame == .upcoming }) { booking in
                            NavigationLink {
                                UserBookingDetailsView(booking: booking)
                            } label: {
                                VStack(alignment: .leading, spacing: 20) {
                                    Text("Court: ")
                                        .bold()
                                    +
                                    Text("\(viewModel.courts.first(where: { $0.id == booking.courtId })?.name ?? "")")

                                    Text("Time: ")
                                        .bold()
                                    +
                                    Text("\(getHourMinuteFormat(date: booking.startDate)) - \(getHourMinuteFormat(date:booking.endDate))")
                                }
                            }
                            .skeleton(with: viewModel.isLoading, shape: .rectangle)
                            .listRowInsets(EdgeInsets())
                            .padding()
                            .frame(minHeight: 70)
                        }
                    }
                }
            }

            if !viewModel.filteredBookings.flatMap(\.bookings).filter({ $0.timeFrame == .pending }).isEmpty {
                Section(header: Text("Pending bookings: ")) {
                    ForEach(viewModel.filteredBookings) { section in
                        Section(header: Text(section.date.formatted(date: .abbreviated, time: .omitted))) {
                            ForEach(section.bookings.filter { $0.timeFrame == .pending }) { booking in
                                NavigationLink {
                                    UserBookingDetailsView(booking: booking)
                                } label: {
                                        VStack(alignment: .leading, spacing: 20) {
                                            Text("Court: \(viewModel.courts.first(where: { $0.id == booking.courtId })?.name ?? "")")

                                            Text("Time: \(getHourMinuteFormat(date: booking.startDate)) - \(getHourMinuteFormat(date:booking.endDate))")
                                        }
                                }
                                .listRowInsets(EdgeInsets())
                                .skeleton(with: viewModel.isLoading, shape: .rectangle)
                                .padding()
                                .frame(minHeight: 70)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
    }
    
    func getDayMonthYearFormat(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM, d, yyyy"

        return dateFormatter.string(from: date)
    }
    
    func getHourMinuteFormat(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter.string(from: date)
    }
}


#Preview {
    UserBookingsView()
}

protocol UserBookingsVMDependencies {
    var getAllCourtsUseCase: GetAllCourtsUseCase { get }
}

extension UserBookingsView {
    final class ViewModel: ObservableObject {

        let dependencies: UserBookingsVMDependencies
        @Published var isLoading = false
        @Published var courts = [Court]()
        @Published var bookings = [DateGroupedBookingSection]()
        @Published var errorDescription: String? = nil
        @Published var headers = [DateHeaderUIModel]()
        @Published var selectedHeaderIndex: Int = 0

        var filteredBookings: [DateGroupedBookingSection] {
            bookings.filter {
                $0.date.hasSameDayAs(headers[selectedHeaderIndex].date) }
        }

        struct DateHeaderUIModel {
            let isToday: Bool
            let title: String
            let date: Date
        }

        struct DateGroupedBookingSection: Identifiable {
            var id: UUID = UUID()

            var date: Date
            var bookings: [Booking]
        }

        private var subscribers = Set<AnyCancellable>()

        init(dependencies: UserBookingsVMDependencies = AppDependenciesContainer.shared) {
            self.dependencies = dependencies
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

                    let bookings: [Booking] = courts
                            .map { $0.bookings }
                            .flatMap { $0 }
                            .filter { $0.userId == "ae3648da-489b-4ee5-b9ae-fca848ed27ec" }
                            .sorted { $0.startDate.compare($1.startDate) == .orderedAscending }

                    let grouped = Dictionary(grouping: bookings) { booking in
                        Calendar.current.startOfDay(for: booking.startDate)
                    }

                    self?.bookings = grouped.map {
                        DateGroupedBookingSection(date: $0.key, bookings: $0.value)
                    }
                    .sorted { $0.date.compare($1.date) == .orderedAscending }

                    self?.setupHeaders(dates: self?.bookings.map(\.date) ?? [])

                    self?.isLoading = false
                }
                .store(in: &subscribers)

        }

        private func setupHeaders(dates: [Date]) {

            headers = dates.map { date in
                let title = date.formatted(with: "dd.MM")
                let isToday = Calendar.current.isDateInToday(date)
                return DateHeaderUIModel(isToday: isToday, title: title, date: date)
            }
        }
    }
}

fileprivate extension Booking {
    enum TimeFrame {
        case pending
        case upcoming
    }

    var timeFrame: TimeFrame {
        isConfirmed ? .pending : .upcoming
    }
}
