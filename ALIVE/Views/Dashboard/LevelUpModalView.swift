import SwiftUI
import SwiftData

public struct LevelUpModalView: View {
    @Environment(\.modelContext) private var modelContext
    let profile: UserProfile
    let onDismiss: () -> Void
    @StateObject private var viewModel = ProfileViewModel()
    @State private var crownScale: CGFloat = 0.3
    @State private var crownOpacity: Double = 0
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    @State private var cardOffset: CGFloat = 50
    @State private var cardOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var glowRadius: CGFloat = 0
    
    public var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            
            ParticleEffectView(particleCount: 50)
            
            VStack(spacing: 24) {
                // Crown icon with scale-in entrance
                ZStack {
                    // Radiating glow rings
                    Circle()
                        .fill(ALIVEColor.rpgGold.opacity(0.15))
                        .frame(width: 140, height: 140)
                        .blur(radius: 25)
                        .scaleEffect(glowRadius > 0 ? 1.3 : 0.8)
                    
                    Circle()
                        .fill(ALIVEColor.rpgGold.opacity(0.25))
                        .frame(width: 100, height: 100)
                        .blur(radius: 15)
                    
                    Image(systemName: "crown.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(ALIVEColor.goldGradient)
                        .shadow(color: ALIVEColor.rpgGold.opacity(0.5), radius: 16)
                }
                .scaleEffect(crownScale)
                .opacity(crownOpacity)
                
                // Title text with scale entrance
                VStack(spacing: 8) {
                    Text("LEVEL UP!")
                        .font(.system(size: 36, weight: .black, design: .monospaced))
                        .foregroundColor(ALIVEColor.rpgGold)
                    
                    Text("HERO HAS REACHED LEVEL \(profile.level)")
                        .font(.headline)
                        .foregroundColor(ALIVEColor.neonCyan)
                }
                .scaleEffect(titleScale)
                .opacity(titleOpacity)
                
                // Stat allocation card with slide-up entrance
                VStack(spacing: 12) {
                    Text("Allocate Stat Points (\(profile.unallocatedStatPoints) Left)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    StatAllocateRow(title: "Intelligence", current: profile.intelligence, icon: "brain.head.profile", color: ALIVEColor.manaBlue) {
                        viewModel.allocateStatPoint(stat: "Intelligence", profile: profile, context: modelContext)
                    }
                    StatAllocateRow(title: "Stamina", current: profile.stamina, icon: "bolt.fill", color: ALIVEColor.staminaGreen) {
                        viewModel.allocateStatPoint(stat: "Stamina", profile: profile, context: modelContext)
                    }
                    StatAllocateRow(title: "Focus", current: profile.focus, icon: "eye.fill", color: ALIVEColor.xpViolet) {
                        viewModel.allocateStatPoint(stat: "Focus", profile: profile, context: modelContext)
                    }
                    StatAllocateRow(title: "Discipline", current: profile.discipline, icon: "shield.fill", color: ALIVEColor.rpgGold) {
                        viewModel.allocateStatPoint(stat: "Discipline", profile: profile, context: modelContext)
                    }
                }
                .glassCard()
                .padding(.horizontal)
                .offset(y: cardOffset)
                .opacity(cardOpacity)
                
                Button(action: onDismiss) {
                    Text("CLAIM & CONTINUE")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ALIVEColor.goldGradient)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .shadow(color: ALIVEColor.rpgGold.opacity(0.4), radius: 8, y: 4)
                }
                .padding(.horizontal)
                .opacity(buttonOpacity)
            }
            .padding()
        }
        .onAppear {
            HapticManager.shared.levelUpHaptic()
            
            // Staggered entrance animations
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.1)) {
                crownScale = 1.0
                crownOpacity = 1.0
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(0.5)) {
                glowRadius = 1.0
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.4)) {
                titleScale = 1.0
                titleOpacity = 1.0
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.7)) {
                cardOffset = 0
                cardOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.4).delay(1.0)) {
                buttonOpacity = 1.0
            }
        }
    }
}

struct StatAllocateRow: View {
    let title: String
    let current: Int
    let icon: String
    let color: Color
    let onPlus: () -> Void
    @State private var didAllocate = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .foregroundColor(ALIVEColor.textPrimary)
            Spacer()
            Text("\(current)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(ALIVEColor.textPrimary)
                .scaleEffect(didAllocate ? 1.3 : 1.0)
            
            Button {
                onPlus()
                // Flash animation on allocation
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    didAllocate = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        didAllocate = false
                    }
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundColor(ALIVEColor.neonCyan)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}
