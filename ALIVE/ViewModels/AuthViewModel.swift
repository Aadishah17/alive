import SwiftUI
import SwiftData
import Combine

public final class AuthViewModel: ObservableObject {
    @Published public var usernameInput: String = ""
    @Published public var selectedClass: CharacterClass = .engineer
    @Published public var isCreatingCharacter: Bool = false
    @Published public var errorMessage: String?
    
    public init() {}
    
    public func createCharacter(context: ModelContext, authService: AuthService) {
        guard !usernameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter a hero username."
            return
        }
        
        let newProfile = UserProfile(
            username: usernameInput.trimmingCharacters(in: .whitespacesAndNewlines),
            characterClass: selectedClass,
            level: 1,
            currentXP: 0,
            streakDays: 1
        )
        newProfile.lastQuestRefreshDate = Date()
        
        context.insert(newProfile)

        // Seed the first playable quest board before committing the new hero.
        let dailyQuests = QuestEngine.defaultDailyQuests()
        let weeklyQuests = QuestEngine.defaultWeeklyQuests()
        (dailyQuests + weeklyQuests).forEach { context.insert($0) }
        SkillTreeSeedFactory.defaultNodes().forEach { context.insert($0) }

        do {
            try PersistenceService.save(context)
            WidgetSnapshotService.refresh(
                profile: newProfile,
                pendingQuestCount: dailyQuests.count + weeklyQuests.count
            )
            authService.loginMockUser(profile: newProfile)
        } catch {
            errorMessage = "Your hero could not be saved. Please try again."
        }
    }
}
