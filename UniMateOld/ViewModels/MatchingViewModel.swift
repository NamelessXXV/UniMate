//
//  MatchingViewModel.swift
//  UniMate
//
//  Created by Sheky Cheung on 22/11/2024.
//

import Firebase
import FirebaseDatabase
import CoreLocation
import MapKit
import Combine

class MatchingViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    private var hasInitialRegion = false
    
    func updateRegion(for location: CLLocation) {
        // Only set initial region once
        if !hasInitialRegion {
            region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            hasInitialRegion = true
        }
    }
}
