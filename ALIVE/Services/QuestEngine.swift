import Foundation
import SwiftData

public final class QuestEngine {
    
    public static func defaultDailyQuests() -> [Quest] {
        return [
            Quest(
                title: "Deep Work Ritual",
                questDescription: "Complete a 45-minute distraction-free study focus session.",
                category: .daily,
                difficulty: .medium,
                targetProgress: 1,
                statTypeReward: "Focus"
            ),
            Quest(
                title: "Academic Presence",
                questDescription: "Attend all scheduled lectures today without burning a bunk.",
                category: .daily,
                difficulty: .easy,
                targetProgress: 1,
                statTypeReward: "Discipline"
            ),
            Quest(
                title: "Knowledge Synthesis",
                questDescription: "Review flashcards or summarize lecture notes for 30 minutes.",
                category: .daily,
                difficulty: .easy,
                targetProgress: 1,
                statTypeReward: "Intelligence"
            ),
            Quest(
                title: "Stamina Maintenance",
                questDescription: "Take a 15-minute active walking break between study blocks.",
                category: .daily,
                difficulty: .easy,
                targetProgress: 1,
                statTypeReward: "Stamina"
            )
        ]
    }
    
    public static func defaultWeeklyQuests() -> [Quest] {
        return [
            Quest(
                title: "Marathon Scholar",
                questDescription: "Log a total of 10 hours of focus study time this week.",
                category: .weekly,
                difficulty: .hard,
                targetProgress: 10,
                statTypeReward: "Focus"
            ),
            Quest(
                title: "Bunk Fortress",
                questDescription: "Maintain >= 80% attendance across all active courses for 7 days.",
                category: .weekly,
                difficulty: .legendary,
                targetProgress: 7,
                statTypeReward: "Discipline"
            )
        ]
    }
}
