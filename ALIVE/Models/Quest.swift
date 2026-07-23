import Foundation
import SwiftData

public enum QuestCategory: String, Codable, CaseIterable {
    case daily = "Daily Quest"
    case weekly = "Weekly Boss"
    case mainQuest = "Main Story"
    case epicGoal = "Epic Goal"
}

public enum QuestDifficulty: String, Codable, CaseIterable {
    case easy = "Novice"
    case medium = "Adept"
    case hard = "Master"
    case legendary = "Legendary"
    
    public var xpReward: Int {
        switch self {
        case .easy: return 50
        case .medium: return 120
        case .hard: return 250
        case .legendary: return 500
        }
    }
}

@Model
public final class Quest {
    public var id: UUID
    public var title: String
    public var questDescription: String
    public var xpReward: Int
    public var categoryRaw: String
    public var difficultyRaw: String
    public var isCompleted: Bool
    public var completionDate: Date?
    public var currentProgress: Int
    public var targetProgress: Int
    public var statTypeReward: String // "Intelligence", "Focus", "Stamina", "Discipline"
    
    public var category: QuestCategory {
        get { QuestCategory(rawValue: categoryRaw) ?? .daily }
        set { categoryRaw = newValue.rawValue }
    }
    
    public var difficulty: QuestDifficulty {
        get { QuestDifficulty(rawValue: difficultyRaw) ?? .medium }
        set { difficultyRaw = newValue.rawValue }
    }
    
    public init(
        title: String,
        questDescription: String,
        category: QuestCategory = .daily,
        difficulty: QuestDifficulty = .medium,
        targetProgress: Int = 1,
        statTypeReward: String = "Focus"
    ) {
        self.id = UUID()
        self.title = title
        self.questDescription = questDescription
        self.categoryRaw = category.rawValue
        self.difficultyRaw = difficulty.rawValue
        self.xpReward = difficulty.xpReward
        self.isCompleted = false
        self.completionDate = nil
        self.currentProgress = 0
        self.targetProgress = targetProgress
        self.statTypeReward = statTypeReward
    }
}
