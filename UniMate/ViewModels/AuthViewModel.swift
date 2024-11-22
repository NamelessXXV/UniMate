// ViewModels/AuthViewModel.swift
import Foundation
import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var errorMessage: String?
    
    private let service = FirebaseService.shared
    
    init() {
        // Check if user is already signed in
        if Auth.auth().currentUser != nil {
            isAuthenticated = true
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
