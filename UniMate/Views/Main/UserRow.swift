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
        NavigationLink(destination: ProfileView(userId: user.id)) {
            HStack {
                if let photoURL = user.photoURL, let url = URL(string: photoURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                        .frame(width: 40, height: 40)
                }
                
                VStack(alignment: .leading) {
                    Text(user.username)
                        .font(.headline)
                        .foregroundColor(.primary)
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
}
#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
