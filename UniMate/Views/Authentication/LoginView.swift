// Views/Authentication/LoginView.swift
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    
    var body: some View {
        VStack(spacing: 0) { // Changed spacing to 0
            // Image section
            Image("hku") // Add your image to Assets.xcassets
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 300) // Adjust height as needed
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
                    
                    // Forgot password link
                    HStack {
                        Spacer()
                        Button("Forgot password?") {
                            // Add forgot password action
                        }
                        .foregroundColor(.green)
                        .font(.footnote)
                    }
                    .padding(.horizontal)
                    
                    // Login button
                    Button(action: {
                        authViewModel.signIn(email: email, password: password)
                    }) {
                        Text("Login")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    // Register link
                    HStack {
                        Text("Not a member?")
                            .foregroundColor(.gray)
                        NavigationLink("Register now", destination: SignUpView())
                            .foregroundColor(.green)
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
        .ignoresSafeArea(.all, edges: .top) // This makes the image extend to the top edge
    }
}
