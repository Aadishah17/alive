import SwiftUI
import SwiftData

public struct QuestCardView: View {
    @Environment(\.modelContext) private var modelContext
    let quest: Quest
    let profile: UserProfile
    @StateObject private var viewModel = QuestViewModel()
    @State private var showParticleFx: Bool = false
    @State private var checkmarkScale: CGFloat = 0
    @State private var cardAppeared = false

    private var awardedXP: Int {
        Int(Double(quest.xpReward) * XPEngine.streakMultiplier(forStreak: profile.streakDays))
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Quest Completion Checkbox Button
            Button {
                if !quest.isCompleted {
                    let didComplete = viewModel.completeQuest(
                        quest: quest,
                        profile: profile,
                        context: modelContext
                    )
                    
                    if didComplete {
                        showParticleFx = true
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            checkmarkScale = 1
                        }
                        Task { @MainActor in
                            try? await Task.sleep(for: .milliseconds(1_300))
                            guard !Task.isCancelled else { return }
                            showParticleFx = false
                        }
                    }
                }
            } label: {
                ZStack {
                    Circle()
                        .stroke(quest.isCompleted ? ALIVEColor.staminaGreen : ALIVEColor.neonCyan, lineWidth: 2)
                        .frame(width: 28, height: 28)
                    
                    if quest.isCompleted {
                        Circle()
                            .fill(ALIVEColor.staminaGreen.opacity(0.15))
                            .frame(width: 28, height: 28)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(ALIVEColor.staminaGreen)
                            .scaleEffect(checkmarkScale)
                    }
                }
            }
            .padding(.top, 2)
            
            // Quest Description & Details
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(quest.title)
                        .font(.headline)
                        .strikethrough(quest.isCompleted, color: ALIVEColor.textMuted)
                        .foregroundColor(quest.isCompleted ? ALIVEColor.textMuted : ALIVEColor.textPrimary)
                    
                    Spacer()
                    
                    // Difficulty Badge
                    Text(quest.difficulty.rawValue.uppercased())
                        .font(.system(size: 8, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(difficultyColor.opacity(0.12))
                        .foregroundColor(difficultyColor)
                        .cornerRadius(6)
                }
                
                Text(quest.questDescription)
                    .font(.caption)
                    .foregroundColor(ALIVEColor.textSecondary)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    // Reward XP
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .foregroundColor(ALIVEColor.rpgGold)
                        Text("+\(awardedXP) XP")
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
        .opacity(cardAppeared ? 1 : 0)
        .offset(x: cardAppeared ? 0 : 20)
        .onAppear {
            // Set initial checkmark state for already-completed quests
            if quest.isCompleted {
                checkmarkScale = 1
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.1)) {
                cardAppeared = true
            }
        }
        .alert(
            "Couldn't claim this quest",
            isPresented: Binding(
                get: { viewModel.completionErrorMessage != nil },
                set: { if !$0 { viewModel.completionErrorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {
                viewModel.completionErrorMessage = nil
            }
        } message: {
            Text(viewModel.completionErrorMessage ?? "Please try again.")
        }
    }
    
    private var difficultyColor: Color {
        switch quest.difficulty {
        case .easy: return ALIVEColor.staminaGreen
        case .medium: return ALIVEColor.rpgGold
        case .hard: return ALIVEColor.xpViolet
        case .legendary: return ALIVEColor.healthRed
        }
    }
}
