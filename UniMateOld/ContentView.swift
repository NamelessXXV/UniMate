// ContentView.swift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                NavigationStack {
                    LoginView()
                }
            }
        }
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
        .onAppear {
            // Check authentication state when view appears
            #if DEBUG
            print("ContentView appeared - Auth State: \(authViewModel.isAuthenticated)")
            #endif
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
