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
        
        context.insert(newProfile)
        try? context.save()
        
        // Seed initial quests and skills for new character
        let dailyQuests = QuestEngine.defaultDailyQuests()
        let weeklyQuests = QuestEngine.defaultWeeklyQuests()
        (dailyQuests + weeklyQuests).forEach { context.insert($0) }
        
        authService.loginMockUser(profile: newProfile)
    }
}
