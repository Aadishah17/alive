import Foundation
import SwiftData

public struct QuestCompletionOutcome: Sendable, Equatable {
    public let title: String
    public let xpGained: Int
    public let didLevelUp: Bool
    public let newLevel: Int
}

/// Domain-level quest completion. Views and App Intents call this single path so
/// completion, XP, stat rewards, and persistence cannot drift apart.
public enum QuestProgressEngine {
    @discardableResult
    public static func complete(
        quest: Quest,
        profile: UserProfile,
        context: ModelContext
    ) throws -> QuestCompletionOutcome? {
        guard !quest.isCompleted else {
            return nil
        }

        quest.isCompleted = true
        quest.completionDate = Date()
        quest.currentProgress = quest.targetProgress

        let xpResult = XPEngine.addXP(
            amount: quest.xpReward,
            to: profile,
            source: "Quest: \(quest.title)",
            context: context
        )
        applyStatReward(quest.statTypeReward, to: profile)

        try PersistenceService.save(context)

        let pendingQuestCount = (try? context.fetch(FetchDescriptor<Quest>()))?
            .filter { !$0.isCompleted }
            .count ?? 0
        WidgetSnapshotService.refresh(profile: profile, pendingQuestCount: pendingQuestCount)

        return QuestCompletionOutcome(
            title: quest.title,
            xpGained: xpResult.xpGained,
            didLevelUp: xpResult.didLevelUp,
            newLevel: xpResult.newLevel
        )
    }

    private static func applyStatReward(_ reward: String, to profile: UserProfile) {
        switch reward {
        case "Intelligence":
            profile.intelligence += 1
        case "Focus":
            profile.focus += 1
        case "Stamina":
            profile.stamina += 1
        case "Discipline":
            profile.discipline += 1
        default:
            break
        }
    }
}
