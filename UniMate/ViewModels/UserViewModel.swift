//
//  UserViewModel.swift
//  UniMate
//
//  Created by Sheky Cheung on 26/11/2024.
//
import SwiftUI

class UserViewModel: ObservableObject {
    @Published var user: User?
    
    func fetchUser(userId: String) async {
        do {
            let fetchedUser = try await FirebaseService.shared.fetchUser(userId: userId)
            DispatchQueue.main.async {
                self.user = fetchedUser
            }
        } catch {
            print("Error fetching user: \(error)")
        }
    }
}
