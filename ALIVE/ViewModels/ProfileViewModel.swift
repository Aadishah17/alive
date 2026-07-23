import SwiftUI
import SwiftData
import Combine

public final class ProfileViewModel: ObservableObject {
    @Published public var showLevelUpEffect: Bool = false
    @Published public var levelUpMessage: String = ""
    
    public init() {}
    
    public func allocateStatPoint(stat: String, profile: UserProfile, context: ModelContext) {
        guard profile.unallocatedStatPoints > 0 else { return }
        
        switch stat {
        case "Intelligence": profile.intelligence += 1
        case "Stamina": profile.stamina += 1
        case "Focus": profile.focus += 1
        case "Discipline": profile.discipline += 1
        default: break
        }
        
        profile.unallocatedStatPoints -= 1
        HapticManager.shared.triggerImpact(style: .light)
        try? context.save()
    }
    
    public func awardXP(amount: Int, source: String, profile: UserProfile, context: ModelContext) {
        let result = XPEngine.addXP(amount: amount, to: profile, source: source, context: context)
        
        if result.didLevelUp {
            showLevelUpEffect = true
            levelUpMessage = "LEVEL UP! You reached Level \(result.newLevel)! +\(result.statPointsEarned) Stat Points"
            HapticManager.shared.levelUpHaptic()
        } else {
            HapticManager.shared.triggerNotification(type: .success)
        }
        
        try? context.save()
    }
}
