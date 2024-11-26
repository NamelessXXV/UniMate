// Views/Main/MainTabView.swift
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var locationViewModel = LocationViewModel()
    
    var body: some View {
        TabView {
            ForumView()
                .tabItem {
                    Label("Forum", systemImage: "message")
                }
            
            MatchingView()
                .tabItem {
                    Label("Match", systemImage: "figure.2.and.child.holdinghands")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .environmentObject(locationViewModel)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
