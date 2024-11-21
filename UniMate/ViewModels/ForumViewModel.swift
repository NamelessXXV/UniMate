import SwiftUI

struct AuthView: View {
    @StateObject private var authManager = AuthManager()
    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering = false
    
    var body: some View {
        if authManager.isAuthenticated {
            HomeView(authManager: authManager)
        } else {
            NavigationView {
                VStack(spacing: 20) {
                    Text("UniMate")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    TextField("Email (@connect.hku.hk)", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if !authManager.errorMessage.isEmpty {
                        Text(authManager.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Button(action: {
                        if isRegistering {
                            authManager.register(email: email, password: password)
                        } else {
                            authManager.login(email: email, password: password)
                        }
                    }) {
                        Text(isRegistering ? "Register" : "Login")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    if !isRegistering {
                        Button(action: {
                            authManager.authenticateWithFaceID()
                        }) {
                            Text("Login with Face ID")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    
                    Button(action: {
                        isRegistering.toggle()
                    }) {
                        Text(isRegistering ? "Already have an account? Login" : "New user? Register")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
            }
        }
    }
}
