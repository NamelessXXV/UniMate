// Views/Main/ForumView.swift
import SwiftUI

struct ForumView: View {
    @StateObject private var viewModel = ForumViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingNewPost = false
    @State private var newPostTitle = ""
    @State private var newPostContent = ""
    @State private var selectedPost: Post?
    @State private var showingComments = false
    @State private var newCommentContent = ""
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    postsList
                }
            }
            .navigationTitle("Forum")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    newPostButton
                }
            }
            .sheet(isPresented: $showingNewPost) {
                newPostSheet
            }
            .sheet(isPresented: $showingComments) {
                commentsSheet
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchPosts()
            }
        }
    }
    
    private var postsList: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(viewModel.posts) { post in
                    PostRowView(post: post, viewModel: viewModel)
                        .padding(.vertical, 1)
                        .background(Color(UIColor.systemBackground))
                }
            }
            .background(Color(UIColor.systemGray5))
        }
        .refreshable {
            Task {
                await viewModel.fetchPosts()
            }
        }
        .background(Color(UIColor.systemGray6))
    }
    
    private var newPostButton: some View {
        Button("New Post") {
            showingNewPost = true
        }
    }
    
    private var newPostSheet: some View {
        NewPostView(
            viewModel: viewModel,
            isPresented: $showingNewPost,
            title: $newPostTitle,
            content: $newPostContent
        )
    }
    
    private var commentsSheet: some View {
        Group {
            if let post = selectedPost {
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
}

#Preview {
    ForumView()
        .environmentObject(AuthViewModel())
}
