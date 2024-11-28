// Views/Authentication/LoginView.swift
// Created by Wu Kwun To
// UID: 3036050726
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    
    var body: some View {
        VStack(spacing: 0) { 
            // Image section
            Image("hku")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .clipped()
            
            // Content section
            VStack(spacing: 20) {
                Text("Welcome to UniMate!")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 20)
                
                // Login form
                VStack(spacing: 15) {
                    TextField("Email Address", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .padding(.horizontal)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    
                    // Login button
                    Button(action: {
                        authViewModel.signIn(email: email, password: password)
                    }) {
                        Text("Login")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    // Register link
                    HStack {
                        Text("Not a member?")
                            .foregroundColor(.gray)
                        NavigationLink("Register now", destination: SignUpView())
                            .foregroundColor(.blue)
                    }
                    .font(.footnote)
                }
                
                if let error = authViewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .padding(.vertical)
            
            Spacer()
        }
        .ignoresSafeArea(.all, edges: .top)
        .onTapGesture {
                    UIApplication.shared.endEditing()
                }
    }
}
