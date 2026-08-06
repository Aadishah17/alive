import SwiftUI
import SwiftData

public struct AuthView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var authService: AuthService
    @Query private var userProfiles: [UserProfile]
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    @State private var titleOffset: CGFloat = 30
    @State private var titleOpacity: Double = 0
    @State private var buttonOffset: CGFloat = 40
    @State private var buttonOpacity: Double = 0
    @State private var glowPulse: Bool = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            ALIVEColor.backgroundDark.ignoresSafeArea()
            
            // Floating ambient particles
            AuthParticleField()
            
            VStack(spacing: 30) {
                Spacer()
                
                // App Logo Header with entrance animation
                ZStack {
                    // Outer glow ring
                    Circle()
                        .fill(ALIVEColor.neonCyan.opacity(0.08))
                        .frame(width: 160, height: 160)
                        .blur(radius: 20)
                        .scaleEffect(glowPulse ? 1.15 : 0.95)
                    
                    // Inner glow
                    Circle()
                        .fill(ALIVEColor.rpgGold.opacity(0.12))
                        .frame(width: 120, height: 120)
                        .blur(radius: 15)
                        .scaleEffect(glowPulse ? 1.05 : 0.9)
                    
                    // Shield icon
                    Image(systemName: "bolt.shield.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(ALIVEColor.goldGradient)
                        .shadow(color: ALIVEColor.rpgGold.opacity(0.4), radius: 12)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                
                VStack(spacing: 8) {
                    Text("A L I V E")
                        .font(.system(size: 40, weight: .black, design: .monospaced))
                        .foregroundColor(ALIVEColor.textPrimary)
                    
                    Text("RPG STUDENT PRODUCTIVITY & ACADEMIC ENGINE")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(ALIVEColor.neonCyan)
                        .tracking(2)
                }
                .offset(y: titleOffset)
                .opacity(titleOpacity)
                
                Spacer()
                
                Group {
                    if let profile = userProfiles.first {
                        // Quick Login Card for Existing Hero
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(profile.characterClass.themeColor.opacity(0.15))
                                        .frame(width: 52, height: 52)
                                    Image(systemName: profile.avatarIdentifier)
                                        .font(.system(size: 28))
                                        .foregroundColor(profile.characterClass.themeColor)
                                }
                                
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
                                HapticManager.shared.triggerImpact(style: .medium)
                                authService.loginMockUser(profile: profile)
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
                                .shadow(color: ALIVEColor.neonCyan.opacity(0.3), radius: 8, y: 4)
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
                                .shadow(color: ALIVEColor.rpgGold.opacity(0.3), radius: 8, y: 4)
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
                }
                .offset(y: buttonOffset)
                .opacity(buttonOpacity)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.1)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                titleOffset = 0
                titleOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.7)) {
                buttonOffset = 0
                buttonOpacity = 1.0
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }
}

/// Floating ambient particles that drift across the auth screen background.
private struct AuthParticleField: View {
    @State private var floaters: [AuthFloater] = []
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(floaters) { floater in
                    Circle()
                        .fill(floater.color.opacity(floater.opacity))
                        .frame(width: floater.size, height: floater.size)
                        .blur(radius: floater.size * 0.3)
                        .position(floater.position)
                }
            }
            .onAppear {
                spawnFloaters(in: geo.size)
            }
        }
        .allowsHitTesting(false)
    }
    
    private func spawnFloaters(in size: CGSize) {
        floaters = (0..<12).map { _ in
            AuthFloater(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                ),
                size: CGFloat.random(in: 20...80),
                opacity: Double.random(in: 0.03...0.08),
                color: [ALIVEColor.neonCyan, ALIVEColor.xpViolet, ALIVEColor.rpgGold].randomElement()!
            )
        }
        
        // Slowly drift particles
        withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
            for i in floaters.indices {
                floaters[i].position.x += CGFloat.random(in: -40...40)
                floaters[i].position.y += CGFloat.random(in: -30...30)
            }
        }
    }
}

private struct AuthFloater: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var opacity: Double
    var color: Color
}
