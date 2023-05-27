//
//  LocationModel.swift
//  WalletWise
//
//  Created by Ninad Tashildar on 4/22/23.
//

import Foundation
import MapKit

struct Location: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
}
