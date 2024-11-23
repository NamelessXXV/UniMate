// Views/Main/PostRowView.swift
import SwiftUI

struct PostRowView: View {
    let post: Post
    @ObservedObject var viewModel: ForumViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingComments = false
    @State private var offset: CGFloat = 0
    @State private var isSwiped = false
    
    private let swipeThreshold: CGFloat = 50
    
    var body: some View {
        ZStack {
            // Background color when swiping
            HStack {
                Spacer()
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.white)
                    Text("Like")
                        .foregroundColor(.white)
                }
                .padding(.trailing)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.red)
            .opacity(offset < 0 ? Double(-offset/100) : 0)
            
            // Main content
            HStack(alignment: .top, spacing: 12) {
                // Left side content (Author, timestamp, title)
                VStack(alignment: .leading, spacing: 8) {
                    // Author and timestamp
                    HStack {
                        Text(viewModel.getUsername(for: post.authorId))
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("·")
                        
                        Text(post.timestamp, style: .relative)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // Title
                    Text(post.title)
                        .font(.headline)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Right side icons in a single row
                HStack(spacing: 16) {
                    // Like button with count
                    HStack(spacing: 4) {
                        Text("\(viewModel.likesCount[post.id] ?? 0)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Image(systemName: viewModel.likedPosts.contains(post.id) ? "heart.fill" : "heart")
                            .foregroundColor(viewModel.likedPosts.contains(post.id) ? .red : .gray)
                    }
                    
                    // Comment count
                    HStack(spacing: 4) {
                        Text("\((viewModel.comments[post.id] ?? []).count)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Image(systemName: "bubble.right")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
            .background(Color(UIColor.systemBackground))
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        // Only allow left swipe
                        if gesture.translation.width < 0 {
                            self.offset = gesture.translation.width
                        }
                    }
                    .onEnded { gesture in
                        withAnimation(.spring()) {
                            if -gesture.translation.width >= swipeThreshold {
                                // Like action
                                if let userId = authViewModel.currentUser?.id {
                                    Task {
                                        await viewModel.toggleLike(postId: post.id, userId: userId)
                                    }
                                }
                            }
                            self.offset = 0
                        }
                    }
            )
            .onTapGesture {
                showingComments.toggle()
            }
        }
        .task {
            if let userId = authViewModel.currentUser?.id {
                await viewModel.checkIfLiked(postId: post.id, userId: userId)
            }
            await viewModel.fetchComments(for: post.id)
        }
        .sheet(isPresented: $showingComments) {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    CommentsView(
                        viewModel: viewModel,
                        post: post,
                        isPresented: $showingComments
                    )
                }
            } else {
                NavigationView {
                    CommentsView(
                        viewModel: viewModel,
                        post: post,
                        isPresented: $showingComments
                    )
                }
            }
        }
    }
}
