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
                photoURL = try await uploadImageToCloudinary(photo)
                print("✅ Successfully uploaded image, URL: \(photoURL ?? "nil")")
            } catch {
                print("⚠️ Failed to upload image: \(error), continuing with other updates")
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
    
    private func uploadImageToCloudinary(_ image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw NSError(domain: "ImageUpload", code: 400,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
        }
        
        // Create unique filename
        let filename = "profile_\(UUID().uuidString)"
        
        // Create form data
        let boundary = UUID().uuidString
        var body = Data()
        
        // Add upload preset to form data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(CloudinaryConfig.uploadPreset)\r\n".data(using: .utf8)!)
        
        // Add public_id (filename) to form data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"public_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(filename)\r\n".data(using: .utf8)!)
        
        // Add file data to form data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename).jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Create upload request
        guard let url = URL(string: CloudinaryConfig.uploadURL) else {
            throw NSError(domain: "ImageUpload", code: 400,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid upload URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        // Perform upload
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "ImageUpload", code: 500,
                          userInfo: [NSLocalizedDescriptionKey: "Upload failed"])
        }
        
        guard let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let secureUrl = jsonResponse["secure_url"] as? String else {
            throw NSError(domain: "ImageUpload", code: 500,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        return secureUrl
    }
}

struct CloudinaryConfig {
    static let cloudName = "shekyc" // Replace with your cloud name
    static let uploadPreset = "unimate" // Replace with your preset name
    
    static var uploadURL: String {
        return "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload"
    }
}
