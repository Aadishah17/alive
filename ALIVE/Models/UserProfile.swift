import Foundation
import SwiftData

@Model
public final class UserProfile {
    public var id: UUID
    public var username: String
    public var characterClassRaw: String
    public var level: Int
    public var currentXP: Int
    public var totalXPEarned: Int
    public var streakDays: Int
    public var lastActiveDate: Date
    public var intelligence: Int
    public var stamina: Int
    public var focus: Int
    public var discipline: Int
    public var unallocatedStatPoints: Int
    public var avatarIdentifier: String
    public var createdAt: Date
    
    public var characterClass: CharacterClass {
        get { CharacterClass(rawValue: characterClassRaw) ?? .scholar }
        set { characterClassRaw = newValue.rawValue }
    }
    
    public var requiredXPForNextLevel: Int {
        return Int(100.0 * pow(Double(level), 1.4))
    }
    
    public var xpProgressFraction: Double {
        guard requiredXPForNextLevel > 0 else { return 0 }
        return Double(currentXP) / Double(requiredXPForNextLevel)
    }
    
    public init(
        username: String,
        characterClass: CharacterClass,
        level: Int = 1,
        currentXP: Int = 0,
        streakDays: Int = 1,
        avatarIdentifier: String = "person.crop.circle.fill"
    ) {
        self.id = UUID()
        self.username = username
        self.characterClassRaw = characterClass.rawValue
        self.level = level
        self.currentXP = currentXP
        self.totalXPEarned = currentXP
        self.streakDays = streakDays
        self.lastActiveDate = Date()
        
        let stats = characterClass.baseStats
        self.intelligence = stats.intelligence
        self.stamina = stats.stamina
        self.focus = stats.focus
        self.discipline = stats.discipline
        self.unallocatedStatPoints = 0
        self.avatarIdentifier = avatarIdentifier
        self.createdAt = Date()
    }
}
