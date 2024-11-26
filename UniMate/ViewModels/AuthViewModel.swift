// ViewModels/AuthViewModel.swift
import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var errorMessage: String?
    
    private let service = FirebaseService.shared
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    init() {
        setupAuthStateHandler()
    }
    
    deinit {
        if let handler = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }
    
    private func setupAuthStateHandler() {
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            guard let self = self else { return }
            
            if let firebaseUser = firebaseUser {
                Task {
                    do {
                        // Fetch the user document from Firestore
                        let db = Firestore.firestore()
                        let userDoc = try await db.collection("users").document(firebaseUser.uid).getDocument()
                        
                        if let userData = userDoc.data() {
                            self.currentUser = User(
                                id: firebaseUser.uid,
                                email: userData["email"] as? String ?? "",
                                username: userData["username"] as? String ?? "",
                                fullName: userData["fullName"] as? String ?? "",
                                photoURL: userData["photoURL"] as? String ?? "",
                                bio: userData["bio"] as? String ?? "",
                                tags: userData["tags"] as? [String] ?? []
                            )
                            self.isAuthenticated = true
                        } else {
                            self.isAuthenticated = false
                            self.currentUser = nil
                        }
                    } catch {
                        print("Error fetching user data: \(error.localizedDescription)")
                        self.isAuthenticated = false
                        self.currentUser = nil
                    }
                }
            } else {
                self.isAuthenticated = false
                self.currentUser = nil
            }
        }
    }
    
    func signIn(email: String, password: String) {
        Task {
            do {
                let user = try await service.signIn(email: email, password: password)
                self.currentUser = user
                self.isAuthenticated = true
                self.errorMessage = nil
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func signUp(email: String, password: String, username: String) {
        Task {
            do {
                let user = try await service.signUp(email: email, password: password, username: username)
                self.currentUser = user
                self.isAuthenticated = true
                self.errorMessage = nil
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func signOut() {
        do {
            try service.signOut()
            self.isAuthenticated = false
            self.currentUser = nil
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
