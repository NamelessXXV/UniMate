//
//  CommentRowView.swift
//  UniMate
//
//  Created by Sheky Cheung on 22/11/2024.
//
import SwiftUI

struct CommentRowView: View {
    let comment: Comment
    let username: String
    let userPhotoURL: String?
    
    var body: some View {
        NavigationLink(destination: ProfileView(userId: comment.authorId)) {
            HStack(alignment: .top, spacing: 10) {
                // Profile Picture
                if let photoURL = userPhotoURL, let url = URL(string: photoURL) {
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
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(username)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(comment.content)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text(comment.timestamp.formatted())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }
}
