import SwiftUI
import MapKit

struct CourtLocationPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.safeAreaInsets) private var safeAreaInsets

    @State private var region = MKCoordinateRegion(
        center: .courtLocation,
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    @State private var pinLocation: CLLocationCoordinate2D?
    @State private var selectedAddress = ""
    
    @Binding var courtLocation: CourtLocation?
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            MapReader { reader in
                Map {
                    if let pinLocation {
                        Marker("Court Location", coordinate: pinLocation)
                    }
                }
                .onTapGesture { screenCoord in
                    pinLocation = reader.convert(screenCoord, from: .local)
                }
            }
            
            if let pinLocation {
                Button(action: {
                    lookupAddress(coordinates: pinLocation) }) {
                    Text("Use this location")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                        .padding(safeAreaInsets)
                }
            }
        }
        .ignoresSafeArea()
    }

    func lookupAddress(coordinates: CLLocationCoordinate2D) {
            let geocoder = CLGeocoder()
            let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)

            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let placemark = placemarks?.first {
                    let courtLocation = CourtLocation(
                        street: placemark.thoroughfare ?? "",
                        city: placemark.locality ?? "",
                        state: placemark.administrativeArea ?? "",
                        country: placemark.country ?? "",
                        zipCode: placemark.postalCode ?? ""
                    )
                    self.courtLocation = courtLocation
                    withAnimation {
                        dismiss()
                    }
                }
            }
        }
}

#Preview {
    CourtLocationPickerView(courtLocation: .constant(nil))
}

extension MKCoordinateRegion {
    func location(from point: CGPoint) -> CLLocationCoordinate2D {
        let mapWidth = 0.1
        let mapHeight = 0.1

        let lon = center.longitude - mapWidth / 2 + mapWidth * Double(point.x / UIScreen.main.bounds.width)
        let lat = center.latitude + mapHeight / 2 - mapHeight * Double(point.y / UIScreen.main.bounds.height)

        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}
