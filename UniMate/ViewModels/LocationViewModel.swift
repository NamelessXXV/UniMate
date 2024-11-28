//
//  LocationView.swift
//  UniMate
//
//  Created by Cheung Yan Shek 3036065575 on 22/11/2024.
//
import SwiftUI
import FirebaseDatabase
import FirebaseAuth
import CoreLocation

// ViewModel to handle most of the MatchingView backend
class LocationViewModel: NSObject, ObservableObject {
    @Published var currentLocation: CLLocation?
    @Published var nearbyUsers: [UserLocation] = []
    
    private let locationManager = CLLocationManager()
    private let database: Database
    private let ref: DatabaseReference
    private var updateTimer: Timer?
    private var scanTimer: Timer?
    private let updateInterval: TimeInterval = 5
    private var user: User?
    
    override init() {
        database = Database.database(url: "https://unimate-demo-default-rtdb.asia-southeast1.firebasedatabase.app")
        ref = database.reference()
        
        super.init()
        
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startLocationUpdates() {
        // Get initial location once
        locationManager.requestLocation()
        startPeriodicUpdates()
    }
    
    // Start periodic updates for location
    private func startPeriodicUpdates() {
        // Start timer for updating timestamp and location in Firebase
        updateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            guard let self = self,
                  let location = self.currentLocation else { return }
            self.updateLocation(location, timestampOnly: false)
        }
        
        // Start timer for scanning other users
        scanTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            self?.scanNearbyUsers()
        }
        
        // Initial scan
        scanNearbyUsers()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        updateTimer?.invalidate()
        updateTimer = nil
        scanTimer?.invalidate()
        scanTimer = nil
        stopObservingNearbyUsers()
        
        // Mark user as inactive when stopping
        if let userId = Auth.auth().currentUser?.uid {
            ref.child("live_locations").child(userId).updateChildValues(["isActive": false])
        }
    }
    
    // Major function to load users on the map
    private func scanNearbyUsers() {
        ref.child("live_locations").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self,
                  let locationsDict = snapshot.value as? [String: [String: Any]] else { return }
            
            let currentTime = Date().timeIntervalSince1970 * 1000
            let users = locationsDict.compactMap { (userId, userData) -> UserLocation? in
                guard let locationData = userData["location"] as? [String: Any],
                      let lat = locationData["latitude"] as? Double,
                      let lon = locationData["longitude"] as? Double,
                      let username = userData["username"] as? String,
                      let lastUpdatedTimestamp = userData["lastUpdated"] as? TimeInterval,
                      let isActive = userData["isActive"] as? Bool else {
                    return nil
                }
                
                // Filter out inactive users
                if currentTime - lastUpdatedTimestamp > 30000 {
                    return nil
                }
                
                return UserLocation(
                    id: userId,
                    username: username,
                    photoURL: userData["photoURL"] as? String,
                    location: UserLocation.LocationCoordinate(
                        latitude: lat,
                        longitude: lon
                    ),
                    lastUpdated: Date(timeIntervalSince1970: lastUpdatedTimestamp / 1000),
                    isActive: isActive
                )
            }
            
            DispatchQueue.main.async {
                self.nearbyUsers = users
            }
        }
    }
    
    private func stopObservingNearbyUsers() {
        ref.child("live_locations").removeAllObservers()
    }
    
    // Function to update currentUser location
    private func updateLocation(_ location: CLLocation, timestampOnly: Bool = false) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        var locationData: [String: Any] = [
            "id": userId, // Add userId to the data
            "lastUpdated": ServerValue.timestamp(),
            "isActive": true
        ]
        
        // Only include location data if not timestamp-only update
        if !timestampOnly {
            locationData["location"] = [
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude
            ]
            
            // Update username and photo URL asynchronously
            Task {
                do {
                    let user = try await FirebaseService.shared.fetchUser(userId: userId)
                    let username = user.username
                    locationData["username"] = username
                    locationData["photoURL"] = user.photoURL ?? ""
                    
                    try await ref.child("live_locations").child(userId).updateChildValues(locationData)
                } catch {
                    print("Error updating location: \(error)")
                }
            }
            
            return
        }
        
        ref.child("live_locations").child(userId).updateChildValues(locationData)
    }
    
    func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .active:
            startLocationUpdates()
        case .background, .inactive:
            stopLocationUpdates()
        @unknown default:
            break
        }
    }
    
    deinit {
        stopLocationUpdates()
    }
}

extension LocationViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        updateLocation(location)
        
        // Stop updating location after getting initial location
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            print("Location access denied")
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
}
