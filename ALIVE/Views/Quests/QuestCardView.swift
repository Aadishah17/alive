import SwiftUI
import SwiftData

public struct QuestCardView: View {
    @Environment(\.modelContext) private var modelContext
    let quest: Quest
    let profile: UserProfile
    @StateObject private var viewModel = QuestViewModel()
    @State private var showParticleFx: Bool = false
    
    public var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Quest Completion Checkbox Button
            Button {
                if !quest.isCompleted {
                    showParticleFx = true
                    viewModel.completeQuest(quest: quest, profile: profile, context: modelContext)
                }
            } label: {
                ZStack {
                    Circle()
                        .stroke(quest.isCompleted ? ALIVEColor.staminaGreen : ALIVEColor.neonCyan, lineWidth: 2)
                        .frame(width: 28, height: 28)
                    
                    if quest.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(ALIVEColor.staminaGreen)
                    }
                }
            }
            .padding(.top, 2)
            
            // Quest Description & Details
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(quest.title)
                        .font(.headline)
                        .strikethrough(quest.isCompleted, color: .gray)
                        .foregroundColor(quest.isCompleted ? .gray : .white)
                    
                    Spacer()
                    
                    // Difficulty Badge
                    Text(quest.difficulty.rawValue.uppercased())
                        .font(.system(size: 8, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(ALIVEColor.glassSurface)
                        .foregroundColor(ALIVEColor.rpgGold)
                        .cornerRadius(6)
                }
                
                Text(quest.questDescription)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    // Reward XP
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .foregroundColor(ALIVEColor.rpgGold)
                        Text("+\(quest.xpReward) XP")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(ALIVEColor.rpgGold)
                    }
                    
                    // Stat Boost
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle")
                            .foregroundColor(ALIVEColor.neonCyan)
                        Text("+1 \(quest.statTypeReward)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(ALIVEColor.neonCyan)
                    }
                }
            }
        }
        .overlay(
            Group {
                if showParticleFx {
                    ParticleEffectView(particleCount: 20)
                }
            }
        )
        .glassCard(borderColor: quest.isCompleted ? ALIVEColor.staminaGreen.opacity(0.4) : ALIVEColor.neonCyan.opacity(0.2))
    }
}
