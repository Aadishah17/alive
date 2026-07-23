import Foundation
import LocalAuthentication
import Combine

public final class AuthService: ObservableObject {
    @Published public var isAuthenticated: Bool = false
    @Published public var currentUserProfile: UserProfile?
    @Published public var authErrorMessage: String?
    
    public init() {}
    
    public func authenticateWithBiometrics(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access your ALIVE RPG Character Profile."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isAuthenticated = true
                        self.authErrorMessage = nil
                        completion(true)
                    } else {
                        self.authErrorMessage = authenticationError?.localizedDescription ?? "Authentication Failed"
                        completion(false)
                    }
                }
            }
        } else {
            // Fallback for Simulator or devices without biometrics
            DispatchQueue.main.async {
                self.isAuthenticated = true
                completion(true)
            }
        }
    }
    
    public func loginMockUser(profile: UserProfile) {
        self.currentUserProfile = profile
        self.isAuthenticated = true
    }
    
    public func logout() {
        self.isAuthenticated = false
        self.currentUserProfile = nil
    }
}
