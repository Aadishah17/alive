import SwiftUI
import SwiftData

public struct LevelUpModalView: View {
    @Environment(\.modelContext) private var modelContext
    let profile: UserProfile
    let onDismiss: () -> Void
    @StateObject private var viewModel = ProfileViewModel()
    
    public var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            
            ParticleEffectView(particleCount: 40)
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(ALIVEColor.rpgGold.opacity(0.3))
                        .frame(width: 100, height: 100)
                        .blur(radius: 20)
                    
                    Image(systemName: "crown.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(ALIVEColor.goldGradient)
                }
                
                VStack(spacing: 8) {
                    Text("LEVEL UP!")
                        .font(.system(size: 36, weight: .black, design: .monospaced))
                        .foregroundColor(ALIVEColor.rpgGold)
                    
                    Text("HERO HAS REACHED LEVEL \(profile.level)")
                        .font(.headline)
                        .foregroundColor(ALIVEColor.neonCyan)
                }
                
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
                
                Button(action: onDismiss) {
                    Text("CLAIM & CONTINUE")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ALIVEColor.goldGradient)
                        .foregroundColor(.black)
                        .cornerRadius(14)
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
}

struct StatAllocateRow: View {
    let title: String
    let current: Int
    let icon: String
    let color: Color
    let onPlus: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .foregroundColor(.white)
            Spacer()
            Text("\(current)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Button(action: onPlus) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundColor(ALIVEColor.neonCyan)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}
