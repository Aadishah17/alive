import Foundation
import SwiftData
import SwiftUI

public enum RarityTier: String, Codable, CaseIterable {
    case common = "Common"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    
    public var badgeColor: Color {
        switch self {
        case .common: return Color.gray
        case .rare: return ALIVEColor.neonCyan
        case .epic: return ALIVEColor.xpViolet
        case .legendary: return ALIVEColor.rpgGold
        }
    }
}

@Model
public final class Achievement {
    public var id: UUID
    public var title: String
    public var achievementDescription: String
    public var badgeIcon: String
    public var rarityRaw: String
    public var isUnlocked: Bool
    public var unlockedDate: Date?
    
    public var rarity: RarityTier {
        get { RarityTier(rawValue: rarityRaw) ?? .common }
        set { rarityRaw = newValue.rawValue }
    }
    
    public init(
        title: String,
        achievementDescription: String,
        badgeIcon: String,
        rarity: RarityTier = .common,
        isUnlocked: Bool = false
    ) {
        self.id = UUID()
        self.title = title
        self.achievementDescription = achievementDescription
        self.badgeIcon = badgeIcon
        self.rarityRaw = rarity.rawValue
        self.isUnlocked = isUnlocked
        self.unlockedDate = isUnlocked ? Date() : nil
    }
}
