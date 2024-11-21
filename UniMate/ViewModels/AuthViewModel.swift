import Foundation
import FirebaseAuth
import LocalAuthentication

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var errorMessage = ""
    
    func validateEmail(_ email: String) -> Bool {
        return email.hasSuffix("@connect.hku.hk")
    }
    
    func register(email: String, password: String) {
        guard validateEmail(email) else {
            errorMessage = "Please use your @connect.hku.hk email"
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            self?.isAuthenticated = true
            UserDefaults.standard.set(email, forKey: "userEmail")
        }
    }
    
    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            self?.isAuthenticated = true
            UserDefaults.standard.set(email, forKey: "userEmail")
        }
    }
    
    func authenticateWithFaceID() {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            errorMessage = "Face ID not available"
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                             localizedReason: "Log in with Face ID") { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    if let email = UserDefaults.standard.string(forKey: "userEmail") {
                        self?.isAuthenticated = true
                    }
                } else {
                    self?.errorMessage = "Face ID authentication failed"
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
        } catch {
            errorMessage = "Error signing out"
        }
    }
}
