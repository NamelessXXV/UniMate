// ForumViewModel.swift
import Foundation

@MainActor
class ForumViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var comments: [String: [Comment]] = [:] // postId: [Comments]
    @Published var likesCount: [String: Int] = [:] // postId: count
    @Published var likedPosts: Set<String> = [] // Set of postIds liked by current user
    @Published var usernames: [String: String] = [:] // userId: username
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var selectedPost: Post?
    @Published var showingPostDetail = false
    
    private let service = FirebaseService.shared
    
    // MARK: - Posts Management
    func fetchPosts() async {
        isLoading = true
        do {
            self.posts = try await service.fetchPosts()
            await updateLikesInfo()
            
            // Check like status for all posts if user is logged in
            if let userId = try? await service.getCurrentUserId() {
                await checkLikesForAllPosts(userId: userId)
            }
            
            // Fetch usernames for all post authors
            await fetchUsernamesForPosts()
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func updateLikesInfo() async {
        await withTaskGroup(of: Void.self) { group in
            for post in posts {
                group.addTask {
                    await self.fetchLikesCount(for: post.id)
                }
            }
        }
    }
    
    private func checkLikesForAllPosts(userId: String) async {
        await withTaskGroup(of: Void.self) { group in
            for post in posts {
                group.addTask {
                    await self.checkIfLiked(postId: post.id, userId: userId)
                }
            }
        }
    }
    
    private func fetchUsernamesForPosts() async {
        let uniqueUserIds = Set(posts.map { $0.authorId })
        await withTaskGroup(of: Void.self) { group in
            for userId in uniqueUserIds {
                group.addTask {
                    await self.fetchUsername(for: userId)
                }
            }
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
    
    // MARK: - Username Management
    private func fetchUsername(for userId: String) async {
        if usernames[userId] != nil { return }
        
        do {
            let username = try await service.fetchUsername(userId: userId)
            usernames[userId] = username
        } catch {
            print("Error fetching username: \(error.localizedDescription)")
            usernames[userId] = "User"
        }
    }
    
    func getUsername(for userId: String) -> String {
        return usernames[userId] ?? "User"
    }
    
    // MARK: - Likes Management
    func toggleLike(postId: String, userId: String) async {
        do {
            let wasLiked = likedPosts.contains(postId)
            
            // Optimistically update UI
            if wasLiked {
                likedPosts.remove(postId)
                likesCount[postId] = (likesCount[postId] ?? 1) - 1
            } else {
                likedPosts.insert(postId)
                likesCount[postId] = (likesCount[postId] ?? 0) + 1
            }
            
            // Update backend
            if wasLiked {
                try await service.unlikePost(postId: postId, userId: userId)
            } else {
                try await service.likePost(postId: postId, userId: userId)
            }
            
            // Fetch actual count to ensure accuracy
            await fetchLikesCount(for: postId)
            self.errorMessage = nil
        } catch {
            // Revert optimistic update if error occurs
            if likedPosts.contains(postId) {
                likedPosts.remove(postId)
                likesCount[postId] = (likesCount[postId] ?? 1) - 1
            } else {
                likedPosts.insert(postId)
                likesCount[postId] = (likesCount[postId] ?? 0) + 1
            }
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
                self.likedPosts.insert(postId)
            } else {
                self.likedPosts.remove(postId)
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
            
            // Fetch usernames for comment authors
            let commentAuthorIds = Set(fetchedComments.map { $0.authorId })
            await withTaskGroup(of: Void.self) { group in
                for authorId in commentAuthorIds {
                    group.addTask {
                        await self.fetchUsername(for: authorId)
                    }
                }
            }
            
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
    
    // MARK: - Post Selection
    func selectPost(_ post: Post) {
        self.selectedPost = post
        self.showingPostDetail = true
    }
    
    func clearSelectedPost() {
        self.selectedPost = nil
        self.showingPostDetail = false
    }
}
