// ViewModels/ForumViewModel.swift
import Foundation

@MainActor
class ForumViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var comments: [String: [Comment]] = [:] // postId: [Comments]
    @Published var likesCount: [String: Int] = [:] // postId: count
    @Published var likedPosts: Set<String> = [] // Set of postIds liked by current user
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let service = FirebaseService.shared
    
    func fetchPosts() async {
        isLoading = true
        do {
            self.posts = try await service.fetchPosts()
            await updateLikesInfo()
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func updateLikesInfo() async {
        for post in posts {
            await fetchLikesCount(for: post.id)
        }
    }
    
    func createPost(title: String, content: String, userId: String) async {
        do {
            try await service.createPost(title: title, content: content, userId: userId)
            await fetchPosts()
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func deletePost(postId: String) async {
        do {
            try await service.deletePost(postId: postId)
            await fetchPosts()
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func updatePost(postId: String, title: String, content: String) async {
        do {
            try await service.updatePost(postId: postId, title: title, content: content)
            await fetchPosts()
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Likes Management
    func toggleLike(postId: String, userId: String) async {
        do {
            let isLiked = try await service.isPostLikedByUser(postId: postId, userId: userId)
            if isLiked {
                try await service.unlikePost(postId: postId, userId: userId)
                likedPosts.remove(postId)
            } else {
                try await service.likePost(postId: postId, userId: userId)
                likedPosts.insert(postId)
            }
            await fetchLikesCount(for: postId)
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func fetchLikesCount(for postId: String) async {
        do {
            let count = try await service.getLikesCount(postId: postId)
            likesCount[postId] = count
        } catch {
            print("Error fetching likes count: \(error.localizedDescription)")
        }
    }
    
    func checkIfLiked(postId: String, userId: String) async {
        do {
            let isLiked = try await service.isPostLikedByUser(postId: postId, userId: userId)
            if isLiked {
                likedPosts.insert(postId)
            } else {
                likedPosts.remove(postId)
            }
        } catch {
            print("Error checking like status: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Comments Management
    func fetchComments(for postId: String) async {
        do {
            let fetchedComments = try await service.fetchComments(postId: postId)
            comments[postId] = fetchedComments
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func addComment(postId: String, userId: String, content: String) async {
        do {
            try await service.addComment(postId: postId, userId: userId, content: content)
            await fetchComments(for: postId)
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func deleteComment(postId: String, commentId: String) async {
        do {
            try await service.deleteComment(postId: postId, commentId: commentId)
            await fetchComments(for: postId)
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func updateComment(postId: String, commentId: String, content: String) async {
        do {
            try await service.updateComment(postId: postId, commentId: commentId, content: content)
            await fetchComments(for: postId)
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
