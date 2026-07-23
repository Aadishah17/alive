import Foundation
import SwiftData

public struct XPResult {
    public let xpGained: Int
    public let didLevelUp: Bool
    public let newLevel: Int
    public let statPointsEarned: Int
}

public final class XPEngine {
    
    /// Calculate base XP required for any given level
    public static func requiredXP(forLevel level: Int) -> Int {
        return Int(100.0 * pow(Double(level), 1.4))
    }
    
    /// Calculate streak bonus multiplier (e.g. 5 day streak = 1.25x XP)
    public static func streakMultiplier(forStreak days: Int) -> Double {
        let bonus = min(Double(days) * 0.05, 0.50) // Max +50% bonus
        return 1.0 + bonus
    }
    
    /// Process XP gain and return outcome detailing if a level up occurred
    @discardableResult
    public static func addXP(
        amount: Int,
        to profile: UserProfile,
        source: String,
        context: ModelContext? = nil
    ) -> XPResult {
        let multiplier = streakMultiplier(forStreak: profile.streakDays)
        let totalGained = Int(Double(amount) * multiplier)
        
        profile.currentXP += totalGained
        profile.totalXPEarned += totalGained
        
        var leveledUp = false
        var newLevel = profile.level
        var statPointsEarned = 0
        
        while profile.currentXP >= profile.requiredXPForNextLevel {
            profile.currentXP -= profile.requiredXPForNextLevel
            profile.level += 1
            newLevel = profile.level
            statPointsEarned += 2
            profile.unallocatedStatPoints += 2
            leveledUp = true
        }
        
        if let context = context {
            let tx = XPTransaction(source: source, amount: totalGained, timestamp: Date())
            context.insert(tx)
        }
        
        return XPResult(
            xpGained: totalGained,
            didLevelUp: leveledUp,
            newLevel: newLevel,
            statPointsEarned: statPointsEarned
        )
    }
}
