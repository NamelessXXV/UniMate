//
//  UserRow.swift
//  UniMate
//
//  Created by Sheky Cheung on 22/11/2024.
//
import SwiftUI
import CoreLocation

struct UserRow: View {
    let user: UserLocation
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .font(.title)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text(user.username)
                    .font(.headline)
                if let currentLocation = LocationViewModel().currentLocation {
                    let userCLLocation = CLLocation(
                        latitude: user.location.latitude,
                        longitude: user.location.longitude
                    )
                    Text("\(String(format: "%.1f", userCLLocation.distance(from: currentLocation) / 1000)) km away")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
