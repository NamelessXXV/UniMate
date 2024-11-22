//
//  MatchingView.swift
//  UniMate
//
//  Created by Sheky Cheung on 22/11/2024.
//

import SwiftUI
import MapKit

struct MatchingView: View {
    @StateObject private var viewModel = MatchingViewModel()
    @StateObject private var locationService = LocationService()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: viewModel.activeUsers) { user in
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
            locationService.requestLocationPermission()
            locationService.startUpdatingLocation()
            viewModel.startObservingUsers()
        }
        .onDisappear {
            locationService.stopUpdatingLocation()
            viewModel.stopObservingUsers()
        }
        .onChange(of: locationService.currentLocation) { location in
            if let location = location {
                viewModel.updateRegion(for: location)
            }
        }
    }
}
