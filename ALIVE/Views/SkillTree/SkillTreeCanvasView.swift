import SwiftUI
import SwiftData

public struct SkillTreeCanvasView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var skills: [SkillNode]
    @Query private var profiles: [UserProfile]
    
    @State private var selectedSkill: SkillNode?
    @State private var appeared = false
    
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
                        .foregroundColor(ALIVEColor.textSecondary)
                }
                .padding(.top, 10)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : -10)
                
                ScrollView([.horizontal, .vertical]) {
                    ZStack {
                        // Draw connecting lines between prerequisite nodes
                        SkillTreeConnectionLines(skills: skills)
                        
                        VStack(spacing: 40) {
                            // Group skills by Tier
                            ForEach(1...3, id: \.self) { tier in
                                VStack(spacing: 10) {
                                    Text("TIER \(tier)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(ALIVEColor.rpgGold)
                                        .opacity(appeared ? 1 : 0)
                                    
                                    HStack(spacing: 30) {
                                        ForEach(skills.filter { $0.tier == tier }) { skill in
                                            SkillNodeCircleView(skill: skill, appeared: appeared) {
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
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }
}

/// Draws lines connecting prerequisite nodes to their dependents.
private struct SkillTreeConnectionLines: View {
    let skills: [SkillNode]
    
    var body: some View {
        Canvas { context, size in
            // Layout: Tier 1 at y=50, Tier 2 at y=140, Tier 3 at y=230
            // Horizontal centering based on skills per tier
            let tierYPositions: [Int: CGFloat] = [1: 70, 2: 150, 3: 230]
            
            for skill in skills {
                for prereqName in skill.prerequisiteNodeNames {
                    if let prereq = skills.first(where: { $0.name == prereqName }) {
                        let fromTierSkills = skills.filter { $0.tier == prereq.tier }
                        let toTierSkills = skills.filter { $0.tier == skill.tier }
                        
                        let fromIndex = fromTierSkills.firstIndex(where: { $0.id == prereq.id }) ?? 0
                        let toIndex = toTierSkills.firstIndex(where: { $0.id == skill.id }) ?? 0
                        
                        let fromX = tierNodeX(index: fromIndex, count: fromTierSkills.count, totalWidth: size.width)
                        let toX = tierNodeX(index: toIndex, count: toTierSkills.count, totalWidth: size.width)
                        
                        let fromY = tierYPositions[prereq.tier, default: 50] + 34
                        let toY = tierYPositions[skill.tier, default: 150] - 34
                        
                        var path = Path()
                        path.move(to: CGPoint(x: fromX, y: fromY))
                        path.addCurve(
                            to: CGPoint(x: toX, y: toY),
                            control1: CGPoint(x: fromX, y: fromY + 30),
                            control2: CGPoint(x: toX, y: toY - 30)
                        )
                        
                        let isActive = prereq.isUnlocked
                        context.stroke(
                            path,
                            with: .color(isActive ? ALIVEColor.neonCyan.opacity(0.5) : ALIVEColor.textMuted.opacity(0.2)),
                            style: StrokeStyle(lineWidth: isActive ? 2 : 1, dash: isActive ? [] : [5, 5])
                        )
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
    
    private func tierNodeX(index: Int, count: Int, totalWidth: CGFloat) -> CGFloat {
        let spacing: CGFloat = 98
        let totalNodeWidth = CGFloat(count) * spacing
        let startX = (totalWidth - totalNodeWidth) / 2 + spacing / 2
        return startX + CGFloat(index) * spacing
    }
}

struct SkillNodeCircleView: View {
    let skill: SkillNode
    var appeared: Bool = false
    let onTap: () -> Void
    @State private var glowPulse = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                ZStack {
                    // Glow ring for unlocked nodes
                    if skill.isUnlocked {
                        Circle()
                            .fill(ALIVEColor.neonCyan.opacity(glowPulse ? 0.2 : 0.08))
                            .frame(width: 76, height: 76)
                            .blur(radius: 6)
                    }
                    
                    Circle()
                        .fill(skill.isUnlocked ? ALIVEColor.neonCyan.opacity(0.15) : ALIVEColor.glassSurface)
                        .frame(width: 64, height: 64)
                    
                    Circle()
                        .stroke(skill.isUnlocked ? ALIVEColor.neonCyan : ALIVEColor.textMuted.opacity(0.4), lineWidth: 2)
                        .frame(width: 68, height: 68)
                    
                    Image(systemName: skill.iconName)
                        .font(.title2)
                        .foregroundColor(skill.isUnlocked ? ALIVEColor.neonCyan : ALIVEColor.textMuted)
                }
                .shadow(color: skill.isUnlocked ? ALIVEColor.neonCyan.opacity(0.3) : .clear, radius: 8)
                
                Text(skill.name)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(skill.isUnlocked ? ALIVEColor.textPrimary : ALIVEColor.textMuted)
                    .multilineTextAlignment(.center)
                    .frame(width: 90)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(appeared ? 1 : 0.7)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(skill.tier) * 0.15), value: appeared)
        .onAppear {
            if skill.isUnlocked {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    glowPulse = true
                }
            }
        }
    }
}
