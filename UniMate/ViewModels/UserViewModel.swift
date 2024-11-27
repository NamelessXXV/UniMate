//
//  UserViewModel.swift
//  UniMate
//
//  Created by Sheky Cheung on 26/11/2024.
//
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage

class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var isEditing = false
    @Published var isLoading = false
    @Published var error: Error?
    private let db = Firestore.firestore()
    
    func fetchUser(userId: String) async {
        guard !userId.isEmpty else {
            print("❌ Empty userId provided")
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        print("📥 Fetching user with ID: \(userId)")
        do {
            let fetchedUser = try await FirebaseService.shared.fetchUser(userId: userId)
            DispatchQueue.main.async {
                self.user = fetchedUser
                self.isLoading = false
                print("✅ Successfully fetched user: \(fetchedUser)")
            }
        } catch {
            DispatchQueue.main.async {
                self.error = error
                self.isLoading = false
                print("❌ Error fetching user: \(error)")
            }
        }
    }
    
    func loadImageFromURL(_ urlString: String) async -> UIImage? {
        print("🖼️ Loading image from URL: \(urlString)")
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL string")
            return nil
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else {
                print("❌ Failed to create UIImage from data")
                return nil
            }
            print("✅ Successfully loaded image")
            return image
        } catch {
            print("❌ Error loading image: \(error)")
            return nil
        }
    }
    
    func updateUserProfile(
        email: String,
        username: String,
        fullName: String?,
        photo: UIImage?,
        bio: String?,
        tags: [String]?
    ) async throws {
        print("🔄 Starting profile update")
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ User not authenticated")
            throw NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        // 1. Handle photo upload if provided
        var photoURL: String? = nil
        if let photo = photo {
            print("📸 Attempting to upload new profile photo")
            do {
                let imageData = photo.jpegData(compressionQuality: 0.7)
                
                if let imageData = photo.jpegData(compressionQuality: 0.7) {
                    // Create a unique path for the image
                    let storageRef = Storage.storage().reference()
                    let imagePath = "user_photos/\(userId)/profile_\(UUID().uuidString).jpg"
                    let imageRef = storageRef.child(imagePath)
                    
                    print("📤 Uploading image to path: \(imagePath)")
                    
                    // Upload the image
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpeg"
                    
                    _ = try await imageRef.putDataAsync(imageData, metadata: metadata)
                    photoURL = try await imageRef.downloadURL().absoluteString
                    print("✅ Successfully uploaded image, URL: \(photoURL ?? "nil")")
                }
            } catch {
                print("⚠️ Failed to upload image: \(error), continuing with other updates")
                // Continue execution despite photo upload failure
            }
        }
        
        // 2. Update Firestore document
        print("📝 Preparing user data update")
        let userData: [String: Any] = [
            "email": email,
            "username": username,
            "fullName": fullName ?? NSNull(),
            "bio": bio ?? NSNull(),
            "tags": tags ?? [],
            "photoURL": photoURL ?? (user?.photoURL ?? NSNull()), // Keep existing photoURL if upload failed
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        do {
            try await db.collection("users").document(userId).setData(userData, merge: true)
            print("✅ Successfully updated user profile")
        } catch {
            print("❌ Failed to update Firestore document: \(error)")
            throw error
        }
    }
}
