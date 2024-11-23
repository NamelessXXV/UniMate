//
//  LocationView.swift
//  UniMate
//
//  Created by Sheky Cheung on 22/11/2024.
//
import SwiftUI
import FirebaseDatabase
import FirebaseAuth
import CoreLocation

class LocationViewModel: NSObject, ObservableObject {
    private let ref = Database.database(url: "https://unimate-demo-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    @Published var nearbyUsers: [UserLocation] = []
    
    override init() {
        super.init()
        setupLocationManager()
        observeNearbyUsers()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func updateLocation(_ location: CLLocation) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let locationData: [String: Any] = [
            "location": [
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude
            ],
            "lastUpdated": ServerValue.timestamp(),
            "isActive": true,
            "username": Auth.auth().currentUser?.displayName ?? "Unknown"
        ]
        
        ref.child("live_locations").child(userId).setValue(locationData)
    }
    
    private func observeNearbyUsers() {
        let locationsRef = ref.child("live_locations") 
        locationsRef.removeAllObservers()
        
        locationsRef.getData { [weak self] error, snapshot in
            guard let self = self,
                  let snapshot = snapshot,
                  let locationsDict = snapshot.value as? [String: [String: Any]] else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let users = locationsDict.compactMap { (userId, data) -> UserLocation? in
                guard userId != Auth.auth().currentUser?.uid,
                      let lat = data["latitude"] as? Double,
                      let lon = data["longitude"] as? Double,
                      let username = data["username"] as? String,
                      let lastUpdatedTimestamp = data["lastUpdated"] as? TimeInterval,
                      let isActive = data["isActive"] as? Bool else {
                    return nil
                }
                
                let photoURL = data["photoURL"] as? String
                let lastUpdated = Date(timeIntervalSince1970: lastUpdatedTimestamp / 1000)
                
                return UserLocation(
                    id: userId,
                    username: username,
                    photoURL: photoURL,
                    location: UserLocation.LocationCoordinate(
                        latitude: lat,
                        longitude: lon
                    ),
                    lastUpdated: lastUpdated,
                    isActive: isActive
                )
            }
            
            DispatchQueue.main.async {
                self.nearbyUsers = users
            }
        }
    }
}

extension LocationViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.currentLocation = location
            self.updateLocation(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location access denied")
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
}
