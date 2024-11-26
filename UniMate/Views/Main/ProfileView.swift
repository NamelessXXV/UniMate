//
//  ProfileView.swift
//  UniMate
//
//  Created by Sheky Cheung on 22/11/2024.
//
import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    let userId: String
    @StateObject private var viewModel = UserViewModel()
    @State private var showingChat = false
    @State private var editedUsername = ""
    @State private var editedEmail = ""
    @State private var editedFullName = ""
    @State private var editedBio = ""
    @State private var editedTags = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @Environment(\.presentationMode) var presentationMode
    
    private var isCurrentUser: Bool {
        userId == Auth.auth().currentUser?.uid
    }
    
    var body: some View {
        Group {
            if let user = viewModel.user {
                ScrollView {
                    VStack(spacing: 20) {
                        // Add some padding at the top
                        Color.clear.frame(height: 20)  // This ensures space at the top
                        
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
                        
                        // Profile Image
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
                            // Regular profile image display
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
                                // Display Mode
                                Text(user.username)
                                    .font(.title)
                                    .bold()
                                
                                if isCurrentUser {  // Hide email and full name if not current user
                                    Text(user.email)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
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
                                                    .background(Color.blue.opacity(0.1))
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
        .task {
            await viewModel.fetchUser(userId: userId)
        }
    }
}

// Add ImagePicker struct for handling image selection
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// Views/Main/ProfileView.swift
//import SwiftUI
//
//struct ProfileView: View {
//    @EnvironmentObject var authViewModel: AuthViewModel
//
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("User Information")) {
//                    HStack {
//                        Text("Username")
//                        Spacer()
//                        Text(authViewModel.currentUser?.username ?? "")
//                            .foregroundColor(.gray)
//                    }
//
//                    HStack {
//                        Text("Email")
//                        Spacer()
//                        Text(authViewModel.currentUser?.email ?? "")
//                            .foregroundColor(.gray)
//                    }
//                }
//
//                Section {
//                    Button(action: {
//                        authViewModel.signOut()
//                    }) {
//                        Text("Sign Out")
//                            .foregroundColor(.red)
//                    }
//                }
//            }
//            .navigationTitle("Profile")
//        }
//    }
//}
//
//#Preview {
//    ProfileView()
//        .environmentObject(AuthViewModel())
//}
