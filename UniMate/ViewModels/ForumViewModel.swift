import Foundation
import FirebaseFirestore

@MainActor
class ForumViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var comments: [String: [Comment]] = [:]
    @Published var likesCount: [String: Int] = [:]
    @Published var likedPosts: Set<String> = []
    @Published var usernames: [String: String] = [:]
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var selectedPost: Post?
    @Published var showingPostDetail = false
    @Published var searchText = ""
    @Published var isSearching = false
    @Published var selectedCategory: PostCategory = .all
    @Published var userPhotos: [String: String] = [:]
    
    private let service = FirebaseService.shared
    
    var filteredPosts: [Post] {
        var filtered = posts
        
        if selectedCategory != .all {
            filtered = filtered.filter { $0.postCategory == selectedCategory } // Use postCategory instead of category
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { post in
                post.title.localizedCaseInsensitiveContains(searchText) ||
                post.content.localizedCaseInsensitiveContains(searchText) ||
                (usernames[post.authorId] ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered.sorted { $0.timestamp > $1.timestamp }
    }
    // MARK: - User management
    func fetchUserPhoto(userId: String) async {
        do {
            let user = try await FirebaseService.shared.fetchUser(userId: userId)
            DispatchQueue.main.async {
                self.userPhotos[userId] = user.photoURL
            }
        } catch {
            print("Error fetching user photo: \(error)")
        }
    }
    
    // MARK: - Posts Management
    func fetchPosts() async {
        isLoading = true
        do {
            self.posts = try await service.fetchPosts(forCategory: selectedCategory)
            print("Fetched \(posts.count) posts")
            
            await updateLikesInfo()
            
            if let userId = service.getCurrentUserId() {
                await checkLikesForAllPosts(userId: userId)
            }
            
            await fetchUsernamesForPosts()
            self.errorMessage = nil
        } catch {
            print("Error fetching posts: \(error.localizedDescription)")
            self.errorMessage = "Failed to load posts: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    private func updateLikesInfo() async {
        await withTaskGroup(of: Void.self) { group in
            for post in posts {
                guard let postId = post.id else {
                    print("Warning: Post without ID encountered")
                    continue
                }
                group.addTask {
                    await self.fetchLikesCount(for: postId)
                }
            }
        }
    }
    
    private func checkLikesForAllPosts(userId: String) async {
        await withTaskGroup(of: Void.self) { group in
            for post in posts {
                guard let postId = post.id else {
                    print("Warning: Post without ID encountered")
                    continue
                }
                group.addTask {
                    await self.checkIfLiked(postId: postId, userId: userId)
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
    
    func createPost(title: String, content: String, userId: String, category: PostCategory) async {
        do {
            print("Creating post with title: \(title), category: \(category)")
            // Convert PostCategory to String using rawValue
            let newPost = try await service.createPostWithCategory(
                title: title,
                content: content,
                userId: userId,
                category: category.rawValue // Convert to String here
            )
            
            // Verify post creation
            print("Post created with ID: \(newPost.id ?? "nil")")
            
            // Immediately append the new post to local array
            posts.append(newPost)
            
            // Fetch updated posts list
            await fetchPosts()
            
            self.errorMessage = nil
        } catch {
            print("Error creating post: \(error.localizedDescription)")
            self.errorMessage = "Failed to create post: \(error.localizedDescription)"
        }
    }
    
    func changeCategory(_ category: PostCategory) async {
        selectedCategory = category
        await fetchPosts()
    }
    
    func deletePost(postId: String) async {
        do {
            try await service.deletePost(postId: postId)
            posts.removeAll { $0.id == postId }
            await fetchPosts()
            self.errorMessage = nil
        } catch {
            print("Error deleting post: \(error.localizedDescription)")
            self.errorMessage = "Failed to delete post: \(error.localizedDescription)"
        }
    }
    
    func updatePost(postId: String, title: String, content: String) async {
        do {
            try await service.updatePost(postId: postId, title: title, content: content)
            if let index = posts.firstIndex(where: { $0.id == postId }) {
                posts[index].title = title
                posts[index].content = content
            }
            await fetchPosts()
            self.errorMessage = nil
        } catch {
            print("Error updating post: \(error.localizedDescription)")
            self.errorMessage = "Failed to update post: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Username Management
    private func fetchUsername(for userId: String) async {
        if usernames[userId] != nil { return }
        
        do {
            let username = try await service.fetchUsername(userId: userId)
            usernames[userId] = username
        } catch {
            print("Error fetching username for \(userId): \(error.localizedDescription)")
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
            
            // Optimistic update
            if wasLiked {
                likedPosts.remove(postId)
                likesCount[postId] = (likesCount[postId] ?? 1) - 1
            } else {
                likedPosts.insert(postId)
                likesCount[postId] = (likesCount[postId] ?? 0) + 1
            }
            
            try await service.toggleLike(postId: postId, userId: userId, isLiked: !wasLiked)
            await fetchLikesCount(for: postId)
            
        } catch {
            // Revert optimistic update on failure
            print("Error toggling like: \(error.localizedDescription)")
            if likedPosts.contains(postId) {
                likedPosts.remove(postId)
                likesCount[postId] = (likesCount[postId] ?? 1) - 1
            } else {
                likedPosts.insert(postId)
                likesCount[postId] = (likesCount[postId] ?? 0) + 1
            }
            self.errorMessage = "Failed to update like: \(error.localizedDescription)"
        }
    }
    
    func fetchLikesCount(for postId: String) async {
        do {
            let count = try await service.getLikesCount(postId: postId)
            likesCount[postId] = count
        } catch {
            print("Error fetching likes count for \(postId): \(error.localizedDescription)")
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
            print("Error checking like status for post \(postId): \(error.localizedDescription)")
        }
    }
    
    // MARK: - Comments Management
    func fetchComments(for postId: String) async {
        do {
            let fetchedComments = try await service.fetchComments(postId: postId)
            comments[postId] = fetchedComments
            
            let commentAuthorIds = Set(fetchedComments.map { $0.authorId })
            await withTaskGroup(of: Void.self) { group in
                for authorId in commentAuthorIds {
                    group.addTask {
                        await self.fetchUsername(for: authorId)
                    }
                }
            }
            
        } catch {
            print("Error fetching comments for post \(postId): \(error.localizedDescription)")
            self.errorMessage = "Failed to load comments: \(error.localizedDescription)"
        }
    }
    
    func addComment(postId: String, userId: String, content: String) async {
        do {
            try await service.addComment(postId: postId, userId: userId, content: content)
            await fetchComments(for: postId)
        } catch {
            print("Error adding comment: \(error.localizedDescription)")
            self.errorMessage = "Failed to add comment: \(error.localizedDescription)"
        }
    }
    
    func deleteComment(postId: String, commentId: String) async {
        do {
            try await service.deleteComment(postId: postId, commentId: commentId)
            await fetchComments(for: postId)
        } catch {
            print("Error deleting comment: \(error.localizedDescription)")
            self.errorMessage = "Failed to delete comment: \(error.localizedDescription)"
        }
    }
    
    func updateComment(postId: String, commentId: String, content: String) async {
        do {
            try await service.updateComment(postId: postId, commentId: commentId, content: content)
            await fetchComments(for: postId)
        } catch {
            print("Error updating comment: \(error.localizedDescription)")
            self.errorMessage = "Failed to update comment: \(error.localizedDescription)"
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
