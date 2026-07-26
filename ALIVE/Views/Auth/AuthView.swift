import SwiftUI
import SwiftData

public struct AuthView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var authService: AuthService
    @Query private var userProfiles: [UserProfile]
    
    public init() {}
    
    public var body: some View {
        ZStack {
            ALIVEColor.backgroundDark.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // App Logo Header
                ZStack {
                    Circle()
                        .fill(ALIVEColor.neonCyan.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .blur(radius: 10)
                    
                    Image(systemName: "bolt.shield.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(ALIVEColor.goldGradient)
                }
                
                VStack(spacing: 8) {
                    Text("A L I V E")
                        .font(.system(size: 40, weight: .black, design: .monospaced))
                        .foregroundColor(ALIVEColor.textPrimary)
                    
                    Text("RPG STUDENT PRODUCTIVITY & ACADEMIC ENGINE")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(ALIVEColor.neonCyan)
                        .tracking(2)
                }
                
                Spacer()
                
                if let profile = userProfiles.first {
                    // Quick Login Card for Existing Hero
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            Image(systemName: profile.avatarIdentifier)
                                .font(.system(size: 36))
                                .foregroundColor(profile.characterClass.themeColor)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(profile.username)
                                    .font(.headline)
                                    .foregroundColor(ALIVEColor.textPrimary)
                                Text("Level \(profile.level) \(profile.characterClass.rawValue)")
                                    .font(.subheadline)
                                    .foregroundColor(ALIVEColor.rpgGold)
                            }
                            Spacer()
                        }
                        .glassCard()
                        
                        Button {
                            authService.authenticateWithDeviceOwnerAuthentication { success in
                                if success {
                                    authService.loginMockUser(profile: profile)
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "lock.open.fill")
                                    .font(.title2)
                                Text("UNLOCK ALIVE")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ALIVEColor.neonCyan)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }

                        if let error = authService.authErrorMessage {
                            Text(error)
                                .font(.footnote)
                                .foregroundColor(ALIVEColor.healthRed)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal)
                } else {
                    // New Hero Welcome
                    VStack(spacing: 16) {
                        NavigationLink(destination: CharacterCreationView()) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("CREATE NEW HERO")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ALIVEColor.goldGradient)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                        
                        Button {
                            MockDataGenerator.seedInitialData(context: modelContext)
                            if let seeded = try? modelContext.fetch(FetchDescriptor<UserProfile>()).first {
                                authService.loginMockUser(profile: seeded)
                            }
                        } label: {
                            Text("DEMO MODE (QUICK SEED)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(ALIVEColor.neonCyan)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}
