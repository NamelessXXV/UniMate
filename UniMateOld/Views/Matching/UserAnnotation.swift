//
//  UserAnnotation.swift
//  UniMate
//
//  Created by Sheky Cheung on 22/11/2024.
//

import SwiftUI

struct UserAnnotation: View {
    let user: UserLocation
    
    var body: some View {
        VStack(spacing: 0) {
            if let photoURL = user.photoURL, !photoURL.isEmpty {
                AsyncImage(url: URL(string: photoURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
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
                .padding(4)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 2)
        }
    }
}
