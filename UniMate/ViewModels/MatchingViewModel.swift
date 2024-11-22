//
//  MatchingViewModel.swift
//  UniMate
//
//  Created by Sheky Cheung on 22/11/2024.
//

import Firebase
import CoreLocation
import MapKit

class MatchingViewModel: ObservableObject {
    @Published var activeUsers: [UserLocation] = []
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    private let database = Database.database().reference()
    private var usersHandle: DatabaseHandle?
    
    func startObservingUsers() {
        usersHandle = database.child("live_locations").observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            var users: [UserLocation] = []
            let currentTime = Date().timeIntervalSince1970 * 1000
            
            for child in snapshot.children {
                guard let snapshot = child as? DataSnapshot,
                      let data = try? JSONSerialization.data(withJSONObject: snapshot.value as Any),
                      var user = try? JSONDecoder().decode(UserLocation.self, from: data) else {
                    continue
                }
                
                // Filter out inactive users and old locations (older than 15 seconds)
                if user.isActive && currentTime - user.lastUpdated.timeIntervalSince1970 * 1000 <= 15000 {
                    users.append(user)
                }
            }
            
            DispatchQueue.main.async {
                self.activeUsers = users
            }
        }
    }
    
    func stopObservingUsers() {
        if let handle = usersHandle {
            database.removeObserver(withHandle: handle)
            usersHandle = nil
        }
    }
    
    func updateRegion(for location: CLLocation) {
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
}
