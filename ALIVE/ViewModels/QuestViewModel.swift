import SwiftUI
import SwiftData
import Combine

public final class QuestViewModel: ObservableObject {
    @Published public var selectedFilter: QuestCategory = .daily
    
    public init() {}
    
    public func completeQuest(quest: Quest, profile: UserProfile, context: ModelContext) {
        guard !quest.isCompleted else { return }
        
        quest.isCompleted = true
        quest.completionDate = Date()
        quest.currentProgress = quest.targetProgress
        
        // Award XP via XPEngine
        _ = XPEngine.addXP(
            amount: quest.xpReward,
            to: profile,
            source: "Quest: \(quest.title)",
            context: context
        )
        
        // Stat reward boost
        switch quest.statTypeReward {
        case "Intelligence": profile.intelligence += 1
        case "Focus": profile.focus += 1
        case "Stamina": profile.stamina += 1
        case "Discipline": profile.discipline += 1
        default: break
        }
        
        HapticManager.shared.triggerNotification(type: .success)
        try? context.save()
    }
}
