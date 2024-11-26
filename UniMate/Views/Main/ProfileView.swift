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
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Group {
            if let user = viewModel.user {
                ScrollView {
                    VStack(spacing: 20) {
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
                            .shadow(radius: 7)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 200, height: 200)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text(user.username)
                                .font(.title)
                                .bold()
                            
                            if let fullName = user.fullName {
                                Text(fullName)
                                    .font(.title2)
                            }
                            
                            if let bio = user.bio {
                                Text(bio)
                                    .font(.body)
                                    .padding(.vertical)
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
                            
                            if userId != Auth.auth().currentUser?.uid {
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
        .task {
            await viewModel.fetchUser(userId: userId)
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
