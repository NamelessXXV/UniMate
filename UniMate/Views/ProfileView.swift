//
//  ProfileView.swift
//  Ma Lok Yan Paris
//  3036067963
//
import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    let userId: String
    @StateObject var viewModel = UserViewModel()
    @State private var showingChat = false
    @State private var editedUsername = ""
    @State private var editedEmail = ""
    @State private var editedFullName = ""
    @State private var editedBio = ""
    @State private var editedTags = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    
    private var isCurrentUser: Bool {
        userId == Auth.auth().currentUser?.uid
    }
    
    var body: some View {
        
        NavigationStack {
            if let user = viewModel.user {
                ScrollView {
                    VStack(spacing: 10) {
                        Color.clear.frame(height: 20)
                        
                        // Top Bar
                        HStack {
                            Spacer()
                            if isCurrentUser {
                                Button(action: {
                                    if viewModel.isEditing {
                                        // Save changes
                                        Task {
                                            try? await viewModel.updateUserProfile(
                                                email: editedEmail,
                                                username: editedUsername,
                                                fullName: editedFullName,
                                                photo: selectedImage,
                                                bio: editedBio,
                                                tags: editedTags.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                                            )
                                            await viewModel.fetchUser(userId: userId)
                                        }
                                    } else {
                                        // Initialize editing values
                                        editedUsername = user.username
                                        editedEmail = user.email
                                        editedFullName = user.fullName ?? ""
                                        editedBio = user.bio ?? ""
                                        editedTags = user.tags?.joined(separator: ", ") ?? ""
                                    }
                                    viewModel.isEditing.toggle()
                                }) {
                                    Text(viewModel.isEditing ? "Save" : "Edit")
                                        .foregroundColor(.blue)
                                }
                                .padding()
                            }
                        }
                        
                        // Profile editing view
                        if viewModel.isEditing {
                            Button(action: { showImagePicker = true }) {
                                if let selected = selectedImage {
                                    Image(uiImage: selected)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 200, height: 200)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                } else if let photoURL = user.photoURL {
                                    AsyncImage(url: URL(string: photoURL)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                    }
                                    .frame(width: 200, height: 200)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                }
                            }
                        } else {
                            // Normal profile view
                            if let photoURL = user.photoURL {
                                AsyncImage(url: URL(string: photoURL)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                }
                                .frame(width: 200, height: 200)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 15) {
                            if viewModel.isEditing {
                                // Editing Form
                                VStack(alignment: .leading) {
                                    TextField("Username", text: $editedUsername)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    TextField("Email", text: $editedEmail)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    TextField("Full Name", text: $editedFullName)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    TextField("Bio", text: $editedBio)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    TextField("Tags (comma-separated)", text: $editedTags)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            } else {
                                // Normal profile view
                                Text(user.username)
                                    .font(.title)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .center)
                                
                                if isCurrentUser {  // only show email and full name if current user
                                    Text(user.email)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    if let fullName = user.fullName {
                                        Text(fullName)
                                            .font(.title2)
                                    }
                                }
                                
                                if let tags = user.tags, !tags.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(tags, id: \.self) { tag in
                                                Text(tag)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(Color.blue.opacity(0.3))
                                                    .cornerRadius(15)
                                            }
                                        }
                                    }
                                }
                                
                                if let bio = user.bio {
                                    Text(bio)
                                        .font(.body)
                                        .padding(.vertical)
                                }
                                
                                if !isCurrentUser {
                                    Button(action: { showingChat = true }) {
                                        HStack {
                                            Image(systemName: "message.fill")
                                            Text("Message")
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                    }
                                    .padding(.top)
                                }
                            }
                            if isCurrentUser {
                                Button(action: {
                                    do {
                                        try Auth.auth().signOut()
                                    } catch {
                                        print("Error signing out: \(error)")
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                        Text("Logout")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                                .padding(.top, 20)
                            }
                            Text("UniMate\nv0.7.4release\nELEC3644 Group 7")
                                .foregroundColor(.gray)
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .padding()
                    }
                }
            } else {
                ProgressView()
            }
        }
        .sheet(isPresented: $showingChat) {
            NavigationView {
                ChatView(currentUserId: Auth.auth().currentUser?.uid ?? "", otherUserId: userId)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .task() {
                await viewModel.fetchUser(userId: userId)
        }.onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
}
