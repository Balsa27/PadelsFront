import Foundation
import MapKit
import SwiftUI

struct MapView: View {
    @StateObject private var locationViewModel = LocationViewModel()

    
    var body: some View {
        ZStack {
            Map(coordinateRegion: .constant(MKCoordinateRegion(center: .courtLocation, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))),
                showsUserLocation: true,
                annotationItems: [CLLocationCoordinate2D.courtLocation]) { location in
                MapPin(coordinate: location, tint: .red)
            }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                }
                .padding()
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

extension CLLocationCoordinate2D: Identifiable {
    public var id: String {
        "\(latitude),\(longitude)"
    }
}

extension CLLocationCoordinate2D {
    static let courtLocation = CLLocationCoordinate2D(latitude: 42.372048, longitude: 18.757911)
}
