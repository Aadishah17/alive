import SwiftUI
import SwiftData

public struct SkillTreeCanvasView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var skills: [SkillNode]
    @Query private var profiles: [UserProfile]
    
    @State private var selectedSkill: SkillNode?
    
    public init() {}
    
    public var body: some View {
        ZStack {
            ALIVEColor.backgroundDark.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Skill Tree Header
                VStack(spacing: 4) {
                    Text("HERO SKILL TREE")
                        .font(.system(size: 20, weight: .black, design: .monospaced))
                        .foregroundColor(ALIVEColor.neonCyan)
                    
                    Text("Invest total earned XP to unlock permanent study and attendance perks.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.top, 10)
                
                ScrollView([.horizontal, .vertical]) {
                    VStack(spacing: 40) {
                        // Group skills by Tier
                        ForEach(1...3, id: \.self) { tier in
                            VStack(spacing: 10) {
                                Text("TIER \(tier)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(ALIVEColor.rpgGold)
                                
                                HStack(spacing: 30) {
                                    ForEach(skills.filter { $0.tier == tier }) { skill in
                                        SkillNodeCircleView(skill: skill) {
                                            selectedSkill = skill
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(40)
                }
            }
        }
        .sheet(item: $selectedSkill) { skill in
            if let profile = profiles.first {
                SkillNodeDetailView(
                    skill: skill,
                    allSkills: skills,
                    profile: profile
                ) {
                    selectedSkill = nil
                }
            }
        }
        .navigationTitle("SKILL TREE")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SkillNodeCircleView: View {
    let skill: SkillNode
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(skill.isUnlocked ? ALIVEColor.neonCyan.opacity(0.2) : ALIVEColor.glassSurface)
                        .frame(width: 64, height: 64)
                    
                    Circle()
                        .stroke(skill.isUnlocked ? ALIVEColor.neonCyan : Color.gray.opacity(0.4), lineWidth: 2)
                        .frame(width: 68, height: 68)
                    
                    Image(systemName: skill.iconName)
                        .font(.title2)
                        .foregroundColor(skill.isUnlocked ? ALIVEColor.neonCyan : .gray)
                }
                .shadow(color: skill.isUnlocked ? ALIVEColor.neonCyan.opacity(0.5) : .clear, radius: 10)
                
                Text(skill.name)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(skill.isUnlocked ? .white : .gray)
                    .multilineTextAlignment(.center)
                    .frame(width: 90)
            }
        }
        .buttonStyle(.plain)
    }
}
