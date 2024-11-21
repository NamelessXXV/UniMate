// Services/FirebaseService.swift
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
        let result = try await auth.signIn(withEmail: email, password: password)
        let user = try await fetchUser(userId: result.user.uid)
        return user
    }
    
    func signUp(email: String, password: String, username: String) async throws -> User {
        let result = try await auth.createUser(withEmail: email, password: password)
        let user = User(id: result.user.uid, email: email, username: username)
        try await createUserInDatabase(user)
        return user
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    // MARK: - User Methods
    private func fetchUser(userId: String) async throws -> User {
        let document = try await db.collection("users").document(userId).getDocument()
        return try document.data(as: User.self)
    }
    
    private func createUserInDatabase(_ user: User) async throws {
        try db.collection("users").document(user.id).setData(from: user)
    }
    
    // MARK: - Post Methods
    func createPost(title: String, content: String, userId: String) async throws {
        let post = Post(
            id: UUID().uuidString,
            authorId: userId,
            title: title,
            content: content,
            timestamp: Date()
        )
        try db.collection("posts").document(post.id).setData(from: post)
    }
    
    func fetchPosts() async throws -> [Post] {
        let snapshot = try await db.collection("posts")
            .order(by: "timestamp", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Post.self) }
    }
}
