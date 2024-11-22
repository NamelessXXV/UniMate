// Views/Main/PostRowView.swift
import SwiftUI

struct PostRowView: View {
    let post: Post
    @ObservedObject var viewModel: ForumViewModel // Change to @ObservedObject
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(post.title)
                .font(.headline)
            Text(post.content)
                .font(.body)
            HStack {
                Text(post.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: {
                    if let userId = authViewModel.currentUser?.id {
                        Task {
                            await viewModel.toggleLike(postId: post.id, userId: userId)
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: viewModel.likedPosts.contains(post.id) ? "heart.fill" : "heart")
                        Text("\(viewModel.likesCount[post.id] ?? 0)")
                    }
                }
                
                Button(action: {
                    // Show comments
                }) {
                    Image(systemName: "bubble.right")
                }
            }
        }
        .padding(.vertical, 4)
    }
}
