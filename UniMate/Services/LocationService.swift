//
//  LocationService.swift
//  UniMate
//
//  Created by Sheky Cheung on 22/11/2024.
//

import CoreLocation
import Firebase
import FirebaseDatabase
import FirebaseAuth
import SwiftUI

class LocationService: NSObject, ObservableObject {
    private let locationManager: CLLocationManager
    private let database = Database.database().reference()
    private var locationTimer: Timer?
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus
    
    override init() {
        locationManager = CLLocationManager()
        authorizationStatus = locationManager.authorizationStatus
        
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        startLocationTimer()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        stopLocationTimer()
        setUserInactive()
    }
    
    private func startLocationTimer() {
        locationTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.uploadLocation()
        }
    }
    
    private func stopLocationTimer() {
        locationTimer?.invalidate()
        locationTimer = nil
    }
    
    private func uploadLocation() {
        guard let location = currentLocation,
              let uid = Auth.auth().currentUser?.uid else { return }
        
        let locationRef = database.child("live_locations").child(uid)
        let locationData: [String: Any] = [
            "location": [
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude
            ],
            "lastUpdated": ServerValue.timestamp(),
            "username": UserDefaults.standard.string(forKey: "username") ?? "Unknown",
            "photoURL": UserDefaults.standard.string(forKey: "photoURL") ?? "",
            "isActive": true
        ]
        
        locationRef.setValue(locationData)
    }
    
    private func setUserInactive() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let locationRef = database.child("live_locations").child(uid)
        locationRef.child("isActive").setValue(false)
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            self.currentLocation = locations.last
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}
