//
//  MatchingView.swift
//  UniMate
//
//  Created by Sheky Cheung on 22/11/2024.
//

import SwiftUI
import MapKit
import FirebaseAuth

struct MatchingView: View {
    @StateObject private var locationViewModel = LocationViewModel()
    @StateObject private var matchingViewModel = MatchingViewModel()
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.scenePhase) var scenePhase
    @State private var selectedUser: UserLocation?
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $matchingViewModel.region,
                showsUserLocation: true,
                annotationItems: locationViewModel.nearbyUsers) { user in
                MapAnnotation(coordinate: user.location.clLocation) {
                    UserAnnotation(user: user.id == Auth.auth().currentUser?.uid ?
                        UserLocation(id: user.id, username: "You", photoURL: user.photoURL, location: user.location, lastUpdated: user.lastUpdated, isActive: user.isActive) :
                        user)
                        .allowsHitTesting(true)
                }
            }
            .edgesIgnoringSafeArea(.all)
            .allowsHitTesting(true)
            
            VStack {
                Text("Matched Users")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
//                    .background(Color.white.opacity(0.9))
                    .shadow(color: Color.black.opacity(0.4), radius: 7, x: 0, y: 2)
                
                Spacer()
                
                // Nearby users list
                VStack {
                    if !filteredNearbyUsers.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(filteredNearbyUsers, id: \.id) { user in
                                    Button(action: {
                                        selectedUser = user
                                    }) {
                                        VStack {
                                            if let photoURL = user.photoURL, !photoURL.isEmpty {
                                                AsyncImage(url: URL(string: photoURL)) { image in
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                } placeholder: {
                                                    Image(systemName: "person.circle.fill")
                                                        .resizable()
                                                        .foregroundColor(.blue)
                                                }
                                                .frame(width: 40, height: 40)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                            } else {
                                                Image(systemName: "person.circle.fill")
                                                    .resizable()
                                                    .frame(width: 40, height: 40)
                                                    .foregroundColor(.blue)
                                                    .background(Circle().fill(Color.white))
                                            }
                                            
                                            Text(user.username)
                                                .font(.caption)
                                                .foregroundColor(.black)
                                        }
                                        .padding(.vertical, 8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(15)
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
            }
        }
        .sheet(item: $selectedUser) { user in
            NavigationView {
                ProfileView(userId: user.id)
            }
        }
        .onAppear {
            locationViewModel.startLocationUpdates()
        }
        .onDisappear {
            locationViewModel.stopLocationUpdates()
        }
        .onChange(of: locationViewModel.currentLocation) { location in
            if let location = location {
                matchingViewModel.updateRegion(for: location)
            }
        }
        .onChange(of: scenePhase) { newPhase in
            locationViewModel.handleScenePhaseChange(newPhase)
        }
    }
    
    private var filteredNearbyUsers: [UserLocation] {
        locationViewModel.nearbyUsers.filter { user in
            user.id != Auth.auth().currentUser?.uid
        }
    }
}

