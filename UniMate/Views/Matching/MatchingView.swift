//
//  MatchingView.swift
//  UniMate
//
//  Created by Sheky Cheung on 22/11/2024.
//

import SwiftUI
import MapKit

struct MatchingView: View {
    @StateObject private var locationViewModel = LocationViewModel()
    @StateObject private var matchingViewModel = MatchingViewModel()
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $matchingViewModel.region,
                showsUserLocation: true,
                annotationItems: locationViewModel.nearbyUsers) { user in
                MapAnnotation(coordinate: user.location.clLocation) {
                    UserAnnotation(user: user)
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                            .background(Circle().fill(Color.white))
                    }
                    .padding()
                    
                    Spacer()
                }
                
                Spacer()
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
                // Update region through view model
                matchingViewModel.updateRegion(for: location)
            }
        }
        .onChange(of: scenePhase) { newPhase in
            locationViewModel.handleScenePhaseChange(newPhase)
        }
    }
}
