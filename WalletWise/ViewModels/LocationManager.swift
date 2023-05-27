//
//  LocationManager.swift
//  WalletWise
//
//  Created by Ninad Tashildar on 4/18/23.
//

import MapKit
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    @Published var region = MKCoordinateRegion()
    @Published var markers: [Location] = []
    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        //searchNearbyBanksAndATMs()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.last.map {
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
            )
        }
    }

    func searchNearbyBanksAndATMs() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Bank ATM"
        request.region = region

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("Error searching for Banks and ATMs: \(error?.localizedDescription ?? "unknown error")")
                return
            }

            DispatchQueue.main.async {
                self.markers = response.mapItems.map { item in
                    Location(
                        name: item.name ?? "",
                        coordinate: item.placemark.coordinate
                    )
                }
            }
        }
    }
}
