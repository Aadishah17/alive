import SwiftUI
import SwiftData

public struct SkillNodeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let skill: SkillNode
    let allSkills: [SkillNode]
    let profile: UserProfile
    let onDismiss: () -> Void
    @StateObject private var viewModel = SkillTreeViewModel()
    
    public var body: some View {
        ZStack {
            ALIVEColor.backgroundDark.ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(skill.isUnlocked ? ALIVEColor.neonCyan.opacity(0.15) : ALIVEColor.glassSurface)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: skill.iconName)
                        .font(.system(size: 36))
                        .foregroundColor(skill.isUnlocked ? ALIVEColor.neonCyan : ALIVEColor.textMuted)
                }
                
                VStack(spacing: 6) {
                    Text(skill.name)
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundColor(ALIVEColor.textPrimary)
                    
                    Text("TIER \(skill.tier) • \(skill.category.uppercased())")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(ALIVEColor.rpgGold)
                }
                
                Text(skill.skillDescription)
                    .font(.subheadline)
                    .foregroundColor(ALIVEColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Active Perk Buff
                VStack(spacing: 4) {
                    Text("UNLOCKED BENEFIT")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(ALIVEColor.neonCyan)
                    Text(skill.buffDescription)
                        .font(.headline)
                        .foregroundColor(ALIVEColor.textPrimary)
                }
                .padding()
                .glassCard(borderColor: ALIVEColor.neonCyan.opacity(0.3))
                
                if let error = viewModel.unlockErrorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(ALIVEColor.healthRed)
                }
                
                if skill.isUnlocked {
                    Text("SKILL MASTERED & ACTIVE")
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundColor(ALIVEColor.staminaGreen)
                } else {
                    Button {
                        viewModel.unlockSkill(skill: skill, allSkills: allSkills, profile: profile, context: modelContext)
                    } label: {
                        HStack {
                            Image(systemName: "lock.open.fill")
                            Text("UNLOCK AT \(skill.xpCost) TOTAL XP")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ALIVEColor.goldGradient)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                }
                
                Button("CLOSE", action: onDismiss)
                    .foregroundColor(ALIVEColor.textSecondary)
            }
            .padding()
        }
    }
}
