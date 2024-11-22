import Firebase
import FirebaseAuth
import FirebaseFirestore

class FirebaseService {
    static let shared = FirebaseService()
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Authentication Methods
    func signIn(email: String, password: String) async throws -> User {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            print("Firebase Auth successful for UID: \(result.user.uid)")
            
            do {
                let user = try await fetchUser(userId: result.user.uid)
                print("Firestore user data fetched successfully")
                return user
            } catch {
                print("Error fetching user data: \(error.localizedDescription)")
                return User(
                    id: result.user.uid,
                    email: email,
                    username: email.components(separatedBy: "@").first ?? "User"
                )
            }
        } catch {
            print("Firebase Auth error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func signUp(email: String, password: String, username: String) async throws -> User {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            print("User created with UID: \(result.user.uid)")
            
            let user = User(id: result.user.uid, email: email, username: username)
            
            try await createUserInDatabase(user)
            print("User data stored in Firestore")
            
            return user
        } catch {
            print("SignUp error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    // MARK: - User Methods
    private func fetchUser(userId: String) async throws -> User {
        let document = try await db.collection("users").document(userId).getDocument()
        guard document.exists else {
            throw NSError(domain: "FirebaseService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User document not found"])
        }
        
        guard
            let data = document.data(),
            let id = data["id"] as? String,
            let email = data["email"] as? String,
            let username = data["username"] as? String
        else {
            throw NSError(domain: "FirebaseService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid user data format"])
        }
        
        return User(id: id, email: email, username: username)
    }
    
    private func createUserInDatabase(_ user: User) async throws {
        let userRef = db.collection("users").document(user.id)
        try await userRef.setData([
            "id": user.id,
            "email": user.email,
            "username": user.username
        ])
    }
    
    // MARK: - Post Methods
    func createPost(title: String, content: String, userId: String) async throws {
        let postRef = db.collection("posts").document()
        
        let post = Post(
            id: postRef.documentID,
            authorId: userId,
            title: title,
            content: content,
            timestamp: Date()
        )
        
        try await postRef.setData([
            "id": post.id,
            "authorId": post.authorId,
            "title": post.title,
            "content": post.content,
            "timestamp": Timestamp(date: post.timestamp)
        ])
    }
    
    func fetchPosts() async throws -> [Post] {
        let snapshot = try await db.collection("posts")
            .order(by: "timestamp", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            let data = document.data()
            guard
                let id = data["id"] as? String,
                let authorId = data["authorId"] as? String,
                let title = data["title"] as? String,
                let content = data["content"] as? String,
                let timestamp = data["timestamp"] as? Timestamp
            else {
                return nil
            }
            
            return Post(
                id: id,
                authorId: authorId,
                title: title,
                content: content,
                timestamp: timestamp.dateValue()
            )
        }
    }
    
    func deletePost(postId: String) async throws {
        // Delete all comments for the post
        let commentsSnapshot = try await db.collection("posts").document(postId)
            .collection("comments").getDocuments()
        for document in commentsSnapshot.documents {
            try await document.reference.delete()
        }
        
        // Delete all likes for the post
        let likesSnapshot = try await db.collection("posts").document(postId)
            .collection("likes").getDocuments()
        for document in likesSnapshot.documents {
            try await document.reference.delete()
        }
        
        // Delete the post itself
        try await db.collection("posts").document(postId).delete()
    }
    
    func updatePost(postId: String, title: String, content: String) async throws {
        try await db.collection("posts").document(postId).updateData([
            "title": title,
            "content": content,
            "timestamp": Timestamp(date: Date())
        ])
    }
    
    // MARK: - Likes Methods
    func likePost(postId: String, userId: String) async throws {
        let like = Like(
            id: userId, // Using userId as the like document ID
            postId: postId,
            userId: userId,
            timestamp: Date()
        )
        
        try await db.collection("posts").document(postId)
            .collection("likes").document(userId)
            .setData([
                "id": like.id,
                "postId": like.postId,
                "userId": like.userId,
                "timestamp": Timestamp(date: like.timestamp)
            ])
    }
    
    func unlikePost(postId: String, userId: String) async throws {
        try await db.collection("posts").document(postId)
            .collection("likes").document(userId).delete()
    }
    
    func isPostLikedByUser(postId: String, userId: String) async throws -> Bool {
        let document = try await db.collection("posts").document(postId)
            .collection("likes").document(userId).getDocument()
        return document.exists
    }
    
    func getLikesCount(postId: String) async throws -> Int {
        let snapshot = try await db.collection("posts").document(postId)
            .collection("likes").getDocuments()
        return snapshot.documents.count
    }
    
    func fetchLikes(postId: String) async throws -> [Like] {
        let snapshot = try await db.collection("posts").document(postId)
            .collection("likes")
            .order(by: "timestamp", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            let data = document.data()
            guard
                let id = data["id"] as? String,
                let postId = data["postId"] as? String,
                let userId = data["userId"] as? String,
                let timestamp = data["timestamp"] as? Timestamp
            else {
                return nil
            }
            
            return Like(
                id: id,
                postId: postId,
                userId: userId,
                timestamp: timestamp.dateValue()
            )
        }
    }
    
    // MARK: - Comments Methods
    func addComment(postId: String, userId: String, content: String) async throws {
        let commentRef = db.collection("posts").document(postId)
            .collection("comments").document()
        
        let comment = Comment(
            id: commentRef.documentID,
            postId: postId,
            authorId: userId,
            content: content,
            timestamp: Date()
        )
        
        try await commentRef.setData([
            "id": comment.id,
            "postId": comment.postId,
            "authorId": comment.authorId,
            "content": comment.content,
            "timestamp": Timestamp(date: comment.timestamp)
        ])
    }
    
    func fetchComments(postId: String) async throws -> [Comment] {
        let snapshot = try await db.collection("posts").document(postId)
            .collection("comments")
            .order(by: "timestamp", descending: false)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            let data = document.data()
            guard
                let id = data["id"] as? String,
                let postId = data["postId"] as? String,
                let authorId = data["authorId"] as? String,
                let content = data["content"] as? String,
                let timestamp = data["timestamp"] as? Timestamp
            else {
                return nil
            }
            
            return Comment(
                id: id,
                postId: postId,
                authorId: authorId,
                content: content,
                timestamp: timestamp.dateValue()
            )
        }
    }
    
    func deleteComment(postId: String, commentId: String) async throws {
        try await db.collection("posts").document(postId)
            .collection("comments").document(commentId).delete()
    }
    
    func updateComment(postId: String, commentId: String, content: String) async throws {
        try await db.collection("posts").document(postId)
            .collection("comments").document(commentId)
            .updateData([
                "content": content,
                "timestamp": Timestamp(date: Date())
            ])
    }
}
