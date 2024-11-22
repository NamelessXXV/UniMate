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
                    List(viewModel.posts) { post in
                        PostRowView(post: post, viewModel: viewModel) // Pass viewModel here
                            .onTapGesture {
                                selectedPost = post
                                showingComments = true
                            }
                    }
                    .refreshable {
                        Task {
                            await viewModel.fetchPosts()
                        }
                    }
                }
            }
            .navigationTitle("Forum")
            .toolbar {
                Button("New Post") {
                    showingNewPost = true
                }
            }
            .sheet(isPresented: $showingNewPost) {
                NewPostView(
                    viewModel: viewModel,
                    isPresented: $showingNewPost,
                    title: $newPostTitle,
                    content: $newPostContent
                )
            }
            .sheet(isPresented: $showingComments) {
                if let post = selectedPost {
                    CommentsView(
                        viewModel: viewModel,
                        post: post,
                        isPresented: $showingComments
                    )
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchPosts()
            }
        }
    }
}
