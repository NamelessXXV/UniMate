// Views/Forum/PostDetailView.swift
import SwiftUI

struct PostDetailView: View {
    @ObservedObject var viewModel: ForumViewModel
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Author info with navigation
            NavigationLink(destination: ProfileView(userId: post.authorId)) {
                HStack(alignment: .center, spacing: 10) {
                    // Profile Picture
                    if false, /*FirebaseService.shared.fetchUser(userId: post.authorId).photoURL,*/
                       let url = URL(string: "") {
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
                    
                    Text(viewModel.getUsername(for: post.authorId))
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
            
            Text(post.title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(post.content)
                .font(.body)
            
            Text(post.timestamp, style: .relative)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
