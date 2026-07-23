import Foundation
import SwiftData

@Model
public final class SkillNode {
    public var id: UUID
    public var name: String
    public var skillDescription: String
    public var category: String // "Academia", "Focus", "Health", "Time Magic"
    public var tier: Int
    public var iconName: String
    public var isUnlocked: Bool
    public var xpCost: Int
    public var prerequisiteNodeNames: [String]
    public var buffDescription: String
    
    public init(
        name: String,
        skillDescription: String,
        category: String,
        tier: Int,
        iconName: String,
        xpCost: Int,
        prerequisiteNodeNames: [String] = [],
        buffDescription: String,
        isUnlocked: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.skillDescription = skillDescription
        self.category = category
        self.tier = tier
        self.iconName = iconName
        self.xpCost = xpCost
        self.prerequisiteNodeNames = prerequisiteNodeNames
        self.buffDescription = buffDescription
        self.isUnlocked = isUnlocked
    }
}
