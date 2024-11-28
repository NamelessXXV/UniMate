//
//  MainTabView.swift
//  Ma Lok Yan Paris
//  3036067963
//
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
                    Label("Forum", systemImage: "bubble.left.and.bubble.right")
                }
            NavigationStack {
                MatchingView()
            }
                .tabItem {
                    Label("Match", systemImage: "figure.2.and.child.holdinghands")
                }

            ChatListView()
                .tabItem {
                    Label("Chats", systemImage: "message.and.waveform")
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

