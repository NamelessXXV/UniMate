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
            VStack(spacing: 0) {
                // Search bar
                searchBar
                
                // Category filter
                categoryFilter
                
                // Main content
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        postsList
                    }
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
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search posts...", text: $viewModel.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
    }
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(PostCategory.allCases) { category in
                    CategoryButton(
                        category: category,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        Task {
                            await viewModel.changeCategory(category)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    private var postsList: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(viewModel.filteredPosts) { post in
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

struct CategoryButton: View {
    let category: PostCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: category.icon)
                Text(category.rawValue)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}
