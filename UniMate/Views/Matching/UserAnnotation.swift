//
//  UserAnnotation.swift
//  UniMate
//
//  Created by Sheky Cheung on 22/11/2024.
//

import SwiftUI

struct UserAnnotation: View {
    let user: UserLocation
    @State private var showProfile = false
    
    var body: some View {
        Button(action: {
            showProfile = true
        }) {
            VStack(spacing: 0) {
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
                    .background(Circle().fill(Color.white))
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
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .shadow(radius: 2)
                    )
            }
        }
        .sheet(isPresented: $showProfile) {
            NavigationView {
                ProfileView(userId: user.id)
            }
        }
    }
}
