// Views/Main/MainTabView.swift
import SwiftUI
import FirebaseAuth

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var locationViewModel = LocationViewModel()
    @StateObject private var userViewModel = UserViewModel()
    
    var body: some View {
        TabView {
            ForumView()
                .tabItem {
                    Label("Forum", systemImage: "bubble.left.and.bubble.right")  // or "text.bubble"
                }
            NavigationStack {
                MatchingView()
            }
                .tabItem {
                    Label("Match", systemImage: "figure.2.and.child.holdinghands")
                }

            ChatListView()
                .tabItem {
                    Label("Chats", systemImage: "message.and.waveform")  // or "message.and.waveform"
                }
            
            if let userId = Auth.auth().currentUser?.uid {
                NavigationStack {
                    ProfileView(userId: userId)
                }
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
            }
        }
        .environmentObject(locationViewModel)
    }
}

//#Preview {
//    MainTabView()
//        .environmentObject(AuthViewModel())
//}
