//
//  UserLocation.swift
//  UniMate
//
//  Created by Sheky Cheung on 22/11/2024.
//

import Foundation
import CoreLocation

struct UserLocation: Codable, Identifiable {
    let id: String
    let username: String
    let photoURL: String?
    let location: LocationCoordinate
    let lastUpdated: Date
    let isActive: Bool
    
    struct LocationCoordinate: Codable {
        let latitude: Double
        let longitude: Double
        
        var clLocation: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case photoURL
        case location
        case lastUpdated
        case isActive
    }
}

// Extension for the existing User model
extension User {
    func toUserLocation(coordinate: CLLocationCoordinate2D) -> UserLocation {
        UserLocation(
            id: id,
            username: username,
            photoURL: nil, // Add photo URL if available
            location: UserLocation.LocationCoordinate(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            ),
            lastUpdated: Date(),
            isActive: true
        )
    }
}
