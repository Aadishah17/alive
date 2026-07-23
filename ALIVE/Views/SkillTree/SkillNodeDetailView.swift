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
            Color.black.opacity(0.8).ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(skill.isUnlocked ? ALIVEColor.neonCyan.opacity(0.2) : Color.gray.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: skill.iconName)
                        .font(.system(size: 36))
                        .foregroundColor(skill.isUnlocked ? ALIVEColor.neonCyan : .gray)
                }
                
                VStack(spacing: 6) {
                    Text(skill.name)
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                    
                    Text("TIER \(skill.tier) • \(skill.category.uppercased())")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(ALIVEColor.rpgGold)
                }
                
                Text(skill.skillDescription)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Active Perk Buff
                VStack(spacing: 4) {
                    Text("PASSIVE BUFF")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(ALIVEColor.neonCyan)
                    Text(skill.buffDescription)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding()
                .glassCard(borderColor: ALIVEColor.neonCyan)
                
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
                            Text("UNLOCK FOR \(skill.xpCost) XP")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ALIVEColor.goldGradient)
                        .foregroundColor(.black)
                        .cornerRadius(14)
                    }
                }
                
                Button("CLOSE", action: onDismiss)
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }
}
