import Foundation
import LocalAuthentication
import Combine

public final class AuthService: ObservableObject {
    @Published public var isAuthenticated: Bool = false
    @Published public var currentUserProfile: UserProfile?
    @Published public var authErrorMessage: String?
    
    public init() {}
    
    public func authenticateWithDeviceOwnerAuthentication(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        let policy: LAPolicy = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            ? .deviceOwnerAuthenticationWithBiometrics
            : .deviceOwnerAuthentication

        guard context.canEvaluatePolicy(policy, error: &error) else {
            DispatchQueue.main.async {
                self.authErrorMessage = error?.localizedDescription ?? "Device authentication is unavailable."
                completion(false)
            }
            return
        }

        let reason = "Authenticate to access your ALIVE RPG Character Profile."
        context.evaluatePolicy(policy, localizedReason: reason) { success, authenticationError in
            DispatchQueue.main.async {
                if success {
                    self.isAuthenticated = true
                    self.authErrorMessage = nil
                    completion(true)
                } else {
                    self.authErrorMessage = authenticationError?.localizedDescription ?? "Authentication failed."
                    completion(false)
                }
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
