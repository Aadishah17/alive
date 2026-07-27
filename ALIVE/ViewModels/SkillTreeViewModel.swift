import SwiftUI
import SwiftData
import Combine

public final class SkillTreeViewModel: ObservableObject {
    @Published public var selectedSkill: SkillNode?
    @Published public var unlockErrorMessage: String?
    
    public init() {}
    
    public func canUnlock(skill: SkillNode, allSkills: [SkillNode], profile: UserProfile) -> (canUnlock: Bool, reason: String?) {
        if skill.isUnlocked {
            return (false, "Skill is already mastered!")
        }
        
        if profile.totalXPEarned < skill.xpCost {
            return (false, "Requires \(skill.xpCost) total XP (Short \(skill.xpCost - profile.totalXPEarned) XP)")
        }
        
        // Check prerequisites
        for prereqName in skill.prerequisiteNodeNames {
            if let prereq = allSkills.first(where: { $0.name == prereqName }), !prereq.isUnlocked {
                return (false, "Prerequisite '\(prereqName)' must be unlocked first.")
            }
        }
        
        return (true, nil)
    }
    
    public func unlockSkill(skill: SkillNode, allSkills: [SkillNode], profile: UserProfile, context: ModelContext) {
        let (allowed, reason) = canUnlock(skill: skill, allSkills: allSkills, profile: profile)
        
        guard allowed else {
            unlockErrorMessage = reason
            HapticManager.shared.triggerNotification(type: .error)
            return
        }
        
        skill.isUnlocked = true

        do {
            try PersistenceService.save(context)
            unlockErrorMessage = nil
            HapticManager.shared.triggerNotification(type: .success)
        } catch {
            unlockErrorMessage = "That skill could not be unlocked. Please try again."
            HapticManager.shared.triggerNotification(type: .error)
        }
    }
}
