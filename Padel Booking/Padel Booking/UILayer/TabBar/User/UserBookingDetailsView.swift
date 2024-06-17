import SwiftUI
import CoreLocation
import Foundation

struct UserBookingDetailsView: View {
    let images = ["logo", "logo1", "logo2"]
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var booking: Booking
    @StateObject var viewModel = ViewModel()
    @ObservedObject var locationViewModel = LocationViewModel()
    @State var isDetailSheetPresented = false
    @State var updatedStartTime: Date?
    @State var updatedEndTime: Date?
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject var  appState: AppState
    @State var isRoutingViewPresented = false
    
    let text =
    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text, Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy textLorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text, Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy textLorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text, Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text"
    
    var body: some View {
        VStack {
            headerView
            
            bookingDetailsView
            VStack(alignment: .leading) {
                MapView()
                getRoutingButton
                    .padding(.horizontal)
            }
            
            Spacer()
            
            bottomButtonsView
            
        }
        .ignoresSafeArea(edges: .top)
        .toolbar(.hidden)
        .sheet(isPresented: $isDetailSheetPresented) {
            timePickerSheet
                .presentationDetents([.height(300)])
        }
        .actionSheet(isPresented: $isRoutingViewPresented) {
                   ActionSheet(
                       title: Text("Selection"),
                       message: Text("Select Navigation App"),
                       buttons: [
                           .default(Text("Apple Maps")) { openAppleMaps() },
                           .default(Text("Google Maps")) { openGoogleMaps() },
                           .cancel()
                       ]
                   )
               }
    }
    
    var headerView: some View {
        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
            TabView {
                ForEach(0..<images.count, id: \.self) { index in
                    Image(images[index])
                        .resizable()
                        .scaledToFill()
                        .padding(.top, safeAreaInsets.top)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(maxHeight: 300)
            
            HStack {
                Spacer()
                
                Image(systemSymbol: .xmark)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .onTapGesture {
                        withAnimation {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .offset(x: -25, y: 50)
                
            }
        }
    }
    
    var bookingDetailsView: some View  {
        HStack {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top) {
                    Text("Court1")
                        .fontDesign(.monospaced)
                        .font(.title3)
                        .bold()
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("20€/60min")
                        Text("28€/90min")
                    }
                    .font(.headline)
                }
                .padding(.vertical)
                
                HStack(spacing: 10) {
                    Image(systemSymbol: .calendar)
                        .fontDesign(.monospaced)
                        .font(.headline)
                        .bold()
                    
                    Text(getDayMonthYearFormat(date: booking.startDate))
                        .fontDesign(.rounded)
                        .font(.subheadline)
                    Spacer()
                }
                
                HStack(spacing: 10) {
                    Image(systemSymbol: .clock)
                        .fontDesign(.monospaced)
                        .font(.headline)
                        .bold()
                    Text("\(getHourMinuteFormat(date: booking.startDate)) - \(getHourMinuteFormat(date:booking.endDate))")
                        .fontDesign(.rounded)
                        .font(.subheadline)
                    Spacer()
                }
                
            }
            .padding()
            
            Spacer()
        }
        .foregroundColor(.black)
        .frame(minHeight: 70)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    var getRoutingButton: some View {
        Button("Get routing") {
            isRoutingViewPresented = true
        }
    }

    private func openAppleMaps() {
        let urlString = "http://maps.apple.com/?daddr=\(CLLocationCoordinate2D.courtLocation.latitude),\(CLLocationCoordinate2D.courtLocation.longitude)&dirflg=d"
           if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
               UIApplication.shared.open(url)
           }
       }

       private func openGoogleMaps() {
           let urlString = "comgooglemaps://?daddr=\(CLLocationCoordinate2D.courtLocation.latitude),\(CLLocationCoordinate2D.courtLocation.longitude)&directionsmode=driving"
           if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
               UIApplication.shared.open(url)
           }
       }
    
    var bottomButtonsView: some View {
        Button(role: .destructive, action: {
            viewModel.cancelBooking(booking: booking)
            withAnimation {
                presentationMode.wrappedValue.dismiss()
            }
            
            appState.showToast(withMessage: "Booking canceled")
        }) {
            Text("Cancel Booking")
        }
        .buttonStyle(PrimaryButtonStyle(backgroundColor: .red))
        .padding()
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
    
    var timePickerSheet: some View {
        VStack(alignment: .leading, spacing: 20) {
            DatePicker(
                "Start time",
                selection: Binding(
                    get: { updatedStartTime ?? booking.startDate },
                    set: { newValue, _ in
                        updatedStartTime = newValue
                        updatedEndTime = newValue.addingTimeInterval(3600)
                    }
                ),
                in: booking.startDate...,
                displayedComponents: .hourAndMinute
                )
            .tint(Color("primaryGreen"))
                .environment(\.locale, Locale.init(identifier: "en_GB"))
                
            DatePicker(
                "End time",
                selection: Binding(
                    get: { updatedEndTime ?? booking.endDate },
                    set: { newValue, _ in
                        updatedEndTime = newValue
                    }
                ),
                in: (updatedStartTime ?? booking.startDate) .addingTimeInterval(3600)...,
                displayedComponents: .hourAndMinute)
                .padding(.top)
                .tint(Color("primaryGreen"))
                .environment(\.locale, Locale.init(identifier: "en_GB"))
            
            Spacer()
            
            
            Button {
                if let _ = updatedStartTime ?? updatedEndTime  {
                    let newBooking = Booking(
                        id: booking.id,
                        courtId: booking.courtId,
                        userId: "",
                        startDate: updatedStartTime ?? booking.startDate,
                        endDate: updatedEndTime ?? booking.endDate,
                        title: booking.title,
                        isConfirmed: booking.isConfirmed
                    )
                    
                    viewModel.editBooking(id: booking.id, newBooking: newBooking)
                    
                    booking = newBooking
                    
                    withAnimation {
                        isDetailSheetPresented = false
                    }
                }
                
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text("Confirm")
                }
            }
            .disabled(viewModel.isLoading || (updatedStartTime == nil && updatedEndTime == nil))
            .buttonStyle(
                PrimaryButtonStyle(
                    backgroundColor: Color("primaryGreen").opacity(
                        (viewModel.isLoading || (updatedStartTime == nil && updatedEndTime == nil)) ? 0.5 : 1))
            )
            
            Spacer()
            
        }
        .padding()
        .toast($viewModel.toast)
    }
}

#Preview {
    UserBookingDetailsView(booking: Booking(courtId: UUID().uuidString, userId: "", startDate: Date(), endDate: Date().addingTimeInterval(7200), title: "Title", isConfirmed: false))
}

protocol UserBookingsDetailVMDependencies {
    var cancelBookingUseCase: CancelBookingUseCase { get }
    var editBookingUseCase: EditBookingUseCase { get }
}


extension UserBookingDetailsView {
    final class ViewModel: ObservableObject {
        let dependencies: UserBookingsDetailVMDependencies
        @State var toast: Toast.State = .hide
        @Published var isLoading = false
        
        init(dependencies: UserBookingsDetailVMDependencies = AppDependenciesContainer.shared) {
            self.dependencies = dependencies
        }
        
        
        func cancelBooking(booking: Booking) {
            dependencies.cancelBookingUseCase.cancel(booking: booking)
        }
        
        func editBooking(id: String, newBooking: Booking) {
            dependencies.editBookingUseCase.replace(id: id, with: newBooking)
        }
    }
}

// View model for handling location services
class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLocation: CLLocationCoordinate2D?
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.userLocation = location.coordinate
        }
    }
}

