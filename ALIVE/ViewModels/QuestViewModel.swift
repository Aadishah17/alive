import SwiftUI
import SwiftData
import Combine

public final class QuestViewModel: ObservableObject {
    @Published public var selectedFilter: QuestCategory = .daily
    @Published public var completionErrorMessage: String?
    
    public init() {}
    
    @discardableResult
    public func completeQuest(quest: Quest, profile: UserProfile, context: ModelContext) -> Bool {
        do {
            guard try QuestProgressEngine.complete(
                quest: quest,
                profile: profile,
                context: context
            ) != nil else {
                return false
            }

            completionErrorMessage = nil
            HapticManager.shared.triggerNotification(type: .success)
            return true
        } catch {
            completionErrorMessage = "That quest could not be claimed. Please try again."
            return false
        }
    }
}
